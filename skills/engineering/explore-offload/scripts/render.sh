#!/bin/sh
# Render an explore-offload manifest into a line-numbered excerpt bundle. Read-only.
# Usage: sh render.sh [--focus <tag>] <manifest> [cap]   run from the repository root; cap is in characters
#        sh render.sh --tree                             print the working-tree ID for the manifest's `tree` line
# With --focus, renders entries before the first `focus` line plus the sections tagged <tag>.
# Exits 1 when any entry is flagged; the bundle is still written.
set -u
MAX_RANGE=150
MAX_MATCHES=40
TAIL=30
g() { git --no-optional-locks "$@"; }

tree_id() {
  head=$(g rev-parse HEAD 2>/dev/null) || { echo "render.sh: needs a git repository with a commit" >&2; exit 2; }
  { printf '%s\n' "$head"; g diff --binary HEAD
    g ls-files -o --exclude-standard | while IFS= read -r f; do printf '%s\n' "$f"; cat "$f"; done
  } | g hash-object --stdin
}

if [ "${1:-}" = --tree ]; then tree_id; exit 0; fi
want=
if [ "${1:-}" = --focus ]; then want=${2:?usage: render.sh --focus <tag> <manifest> [cap]}; shift 2; fi
manifest=${1:?usage: render.sh [--focus <tag>] <manifest> [cap] | render.sh --tree}
cap=${2:-60000}
case $cap in ''|*[!0-9]*) echo "render.sh: cap must be a number" >&2; exit 2 ;; esac
root=$(pwd -P)
mdir=$(cd "$(dirname "$manifest")" && pwd -P) || exit 2
cr=$(printf '\r')
esc=$(printf '\033')
total=0
problems=0
tree_seen=
section=
focus_seen=
# Core logs that have `log` range entries; a failing run without any shows its tail instead.
ranged_logs=$(awk '$1 == "focus" { exit } $1 == "log" { sub(/:[^:]*$/, "", $2); print $2 }' "$manifest")

problem() { printf '\n==> %s\n' "$*"; problems=$((problems + 1)); }

# Print the header and body if the body fits within the cap; otherwise flag it.
emit() {
  n=$(printf '%s\n' "$2" | wc -c | tr -d ' ')
  [ $((total + n)) -le "$cap" ] || { problem "SKIPPED $1 ($n characters would exceed cap $cap)"; return; }
  printf '\n==> %s\n%s\n' "$1" "$2"
  total=$((total + n))
}

# Remove ANSI color and cursor escape sequences from log text.
strip() { sed "s/${esc}\[[0-9;?]*[A-Za-z]//g"; }

# Number lines $2-$3 of file $1.
lines() { awk -v s="$2" -v e="$3" 'NR >= s && NR <= e { printf "%6d  %s\n", NR, $0 } NR > e { exit }' "$1"; }

# Succeeds if $1 is a regular, non-symlink file whose resolved directory is under $2.
inside() {
  [ -f "$1" ] && [ ! -L "$1" ] || return 1
  d=$(cd "$(dirname "$1")" 2>/dev/null && pwd -P) || return 1
  case $d/ in "$2"/*) return 0 ;; *) return 1 ;; esac
}

# Print $1 as a decimal line number (1-9999999), or fail.
num() {
  case $1 in ''|*[!0-9]*) return 1 ;; esac
  [ ${#1} -le 7 ] || return 1
  n=$(printf '%s' "$1" | sed 's/^0*//')
  [ -n "$n" ] && printf '%s' "$n"
}

# Split $1 into path and range, then set start and end for file $2. Flags and fails on a bad range.
span() {
  len=$(awk 'END { print NR }' "$2")
  if [ -z "$range" ]; then
    start=1 end=$len
  else
    case $range in *-*) s=${range%%-*} e=${range#*-} ;; *) s=$range e=$range ;; esac
    start=$(num "$s") && end=$(num "$e") || { problem "REJECTED $1 (range must be <start>-<end> or <line>)"; return 1; }
    [ "$end" -gt "$len" ] && end=$len
  fi
  [ "$start" -le "$end" ] || { problem "REJECTED $1 (range outside 1-$len)"; return 1; }
  [ $((end - start + 1)) -le "$MAX_RANGE" ] || { problem "REJECTED $1 ($((end - start + 1)) lines; split ranges over $MAX_RANGE)"; return 1; }
}

split_spec() {
  path=$1 range=
  case $1 in *:*)
    case ${1##*:} in *[!0-9-]*) ;; *) path=${1%:*} range=${1##*:} ;; esac ;;
  esac
}

render_range() {
  spec=$1 reason=$2
  split_spec "$spec"
  case $path in /*) problem "REJECTED $spec (path must be relative)"; return ;; esac
  [ -e "$path" ] || { problem "MISSING $spec"; return; }
  inside "$path" "$root" || { problem "REJECTED $spec (not a regular file inside the repository)"; return; }
  case $path in .git/*|*/.git/*) problem "REJECTED $spec (git metadata)"; return ;; esac
  g check-ignore -q "$path" && { problem "REJECTED $spec (ignored by git)"; return; }
  LC_ALL=C grep -Iq '' "$path" || { problem "REJECTED $spec (binary file)"; return; }
  span "$spec" "$path" || return
  emit "$path:$start-$end  $reason" "$(lines "$path" "$start" "$end")"
}

# Resolve log name $1 beside the manifest into lp, or flag and fail.
log_path() {
  case $1 in /*|*/*) problem "REJECTED log $1 (name a file beside the manifest)"; return 1 ;; esac
  lp=$mdir/$1
  inside "$lp" "$mdir" || { problem "MISSING log $1"; return 1; }
}

render_log_range() {
  spec=${1%%[[:space:]]*}
  reason=$(printf '%s' "${1#"$spec"}" | sed 's/^[[:space:]]*//')
  split_spec "$spec"
  [ -n "$range" ] || { problem "REJECTED log $spec (expected: log <name>:<start>-<end> <why>)"; return; }
  log_path "$path" || return
  span "log $spec" "$lp" || return
  emit "LOG $path:$start-$end  $reason" "$(lines "$lp" "$start" "$end" | strip)"
}

render_test() {
  log=${1%%[[:space:]]*}
  filter=$(printf '%s' "${1#"$log"}" | sed 's/^[[:space:]]*//')
  [ -n "$log" ] && [ -n "$filter" ] || { problem "REJECTED test $1 (expected: test <log> <filter>)"; return; }
  log_path "$log" || return
  inside "$lp.exit" "$mdir" || { problem "MISSING $log.exit"; return; }
  code=$(tr -d ' \r\n' < "$lp.exit")
  case $code in ''|*[!0-9]*) problem "REJECTED $log.exit (not an exit code)"; return ;; esac
  matched=$(strip < "$lp" | grep -cE -- "$filter")
  [ $? -le 1 ] || { problem "REJECTED test $log (invalid filter)"; return; }
  len=$(awk 'END { print NR }' "$lp")
  printf '\n==> TEST %s exit %s, %s of %s lines match /%s/\n' "$lp" "$code" "$matched" "$len" "$filter"
  [ "$code" -eq 0 ] || [ "$matched" -gt 0 ] || problem "FILTER HID FAILURE $log (exit $code, no lines matched)"
  if [ "$matched" -gt 0 ]; then
    shown=$matched
    [ "$shown" -gt "$MAX_MATCHES" ] && shown=$MAX_MATCHES
    emit "MATCHES $log ($shown of $matched)" "$(strip < "$lp" | grep -nE -- "$filter" | head -n "$MAX_MATCHES")"
  fi
  # A failing run shows its tail unless the scout chose log ranges, so a narrow filter cannot hide the failure.
  if [ "$code" -ne 0 ] && ! printf '%s\n' "$ranged_logs" | grep -qxF -- "$log"; then
    s=$((len - TAIL + 1)); [ "$s" -lt 1 ] && s=1
    emit "TAIL $log:$s-$len (exit $code, no log ranges chosen)" "$(lines "$lp" "$s" "$len" | strip)"
  fi
}

while IFS= read -r line || [ -n "$line" ]; do
  line=${line%"$cr"}
  case $line in
    '') continue ;;
    '#'*) printf '%s\n' "$line"; continue ;;
  esac
  kind=${line%%[[:space:]]*}
  rest=$(printf '%s' "${line#"$kind"}" | sed 's/^[[:space:]]*//')
  if [ "$kind" = focus ]; then
    section=$rest
    [ "$section" = "$want" ] && focus_seen=1
    [ -z "$want" ] || [ "$section" = "$want" ] && printf '\n==> FOCUS %s\n' "$section"
    continue
  fi
  case $kind in test|log|tree)
    [ -z "$section" ] || { problem "REJECTED $line (belongs before the first focus line)"; continue; } ;;
  esac
  [ -z "$want" ] || [ -z "$section" ] || [ "$section" = "$want" ] || continue
  case $kind in
    tree)
      tree_seen=1 now=$(tree_id)
      if [ -z "$now" ]; then problem "TREE CHECK FAILED (needs a git repository with a commit)"
      elif [ "$rest" = "$now" ]; then printf '==> TREE %s (current)\n' "$now"
      else problem "STALE tree $rest; current tree is $now"; fi ;;
    test) render_test "$rest" ;;
    log) render_log_range "$rest" ;;
    *) render_range "$kind" "$rest" ;;
  esac
done < "$manifest"

[ -n "$tree_seen" ] || problem "MISSING tree line"
[ -z "$want" ] || [ -n "$focus_seen" ] || printf '\n==> NOTE no section tagged %s; core entries only\n' "$want"
printf '\n==> TOTAL %s characters (cap %s), %s problem entries\n' "$total" "$cap" "$problems"
[ "$problems" -eq 0 ]
