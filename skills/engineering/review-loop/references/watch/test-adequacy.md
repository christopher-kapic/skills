# Watch-list: Test adequacy

Attach when the diff adds or changes tests, or when the goal lists acceptance criteria or required tests.

Probe after the coverage table. Confirm the application's contract first; a mismatch with an entry alone is not a finding. Named APIs are leads, not accepted fixes. `verified` closure needs a probe of the property; report a step you cannot run safely as not run. Report `ID: evidence`, a finding, or `ID: n/a`.

- **TA1 Tests reach the production path.** Do tests exercise the real transport, router, SQL, and wiring, rather than a mock that replaces the code under review? **Verify:** trace each acceptance test to the code it claims to cover and list the modules that were substituted.
- **TA2 No tautological doubles.** Would the test fail if the production query or logic were wrong, or does the mock match on query text or return exactly what is expected? **Verify:** mutate the production code in a scratch copy and confirm that the test fails. List tests that survive the mutation under `Low-signal tests` with a harden or delete recommendation.
- **TA3 Fixtures use real values.** Do fixtures use the dependency's real units and defaults (ms or s, real limits)? **Verify:** compare fixture values against library source or defaults.
- **TA4 Regression tests survive fixes.** Does a fix delete or weaken the only test for an earlier defect? **Verify:** list the tests the diff removes or rewrites and map each one to a ledger ID.
- **TA5 Contention tests are concurrent.** Do contention tests start their actors in parallel behind a barrier, and would they fail if the lock were removed? Tests that run serially do not count. **Verify:** inspect the test structure. Remove the guard in a scratch copy and rerun.
- **TA6 Required tests exist.** Does each required crash, SIGKILL, overlap, actor-matrix, and boot test named by the goal exist, and does each run against the production path? **Verify:** map each acceptance criterion to a test name and command.
- **TA7 The gate runs.** Are new suites wired into CI or the verify command? Are tests deterministic, with no dependence on poll timing or nondeterministic probes? **Verify:** find the CI line that invokes each suite. Run it several times.
- **TA8 Reports are measurements.** Do performance or latency claims come from real measurements, not counters or estimates? **Verify:** rerun the command and inspect the raw data.
- **TA9 Tests pass for the right reason.** Does each negative test assert the specific error kind or outcome, so that it can't pass because setup failed, a different error occurred, or the path under test was never reached? **Verify:** check the assertion's specificity. Break the guard under test in a scratch copy: the test must fail. If an unrelated break makes it pass, list it under `Low-signal tests`.
