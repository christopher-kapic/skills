# Watch-list: SQL databases (PostgreSQL, SQLite, Cloudflare D1)

Attach when the diff touches SQL, an ORM (Prisma, Drizzle, Kysely, and similar), migrations, transactions, constraints, or deploy-time SQL scripts. Pair this list with the concurrency lists for race classes; this list covers database mechanics.

Probe after the coverage table. Confirm the application's contract first; a mismatch with an entry alone is not a finding. Named APIs are leads, not accepted fixes. `verified` closure needs a probe of the property; report a step you cannot run safely as not run. Report `ID: evidence`, a finding, or `ID: n/a`.

## General

- **DB1 Unique violations under concurrency.** Does a concurrent unique violation (Prisma `P2002`, Postgres `23505`) map to the idempotent or domain outcome? **Verify:** run concurrent inserts against a real database, not a mock.
- **DB2 Upsert semantics.** Does the ORM compile the upsert to native `INSERT … ON CONFLICT`? If so, the documented conflict or error path may never occur. **Verify:** read the generated SQL (query log) and probe the race.
- **DB3 Read after write.** Does the code act on a separate re-read after a write, where a concurrent writer can change the row in between? **Verify:** find each write followed by a re-read of the same row and construct a concurrent write between them. Leads: `RETURNING` from the conditional write, or a lock that keeps the row stable.
- **DB4 Foreign-key actions.** Does `RESTRICT` or `NO ACTION` on soft-deleted, historical, or terminal children make parents permanently undeletable, and does the delete path return a domain error rather than a 500? Does `CASCADE` delete history that must survive? **Verify:** delete a parent with each child state present.
- **DB5 Deploy-time SQL is idempotent and safe for live rows.** Do backfills, hardening scripts, schema replays, and restores re-run on every deploy without duplicate-object errors and without touching live or in-flight rows? Does a reset drop every schema the restore recreates? **Verify:** run the script twice against a database with in-flight rows. Grep non-application files (`*.sql`, shell) for writers of the changed tables.

## PostgreSQL

- **DB6 Aborted transactions.** After a statement fails inside a transaction, does any code read or retry within that transaction (`25P02`)? **Verify:** find each catch inside a transaction callback. It needs a savepoint or a new transaction.
- **DB7 Implicit locks and deadlocks.** Do foreign-key checks (`FOR KEY SHARE` on the parent) and delete cascades take locks in the opposite order from other writers? **Verify:** run the concurrent delete and child write against real Postgres.
- **DB8 Collation and text.** Does application-side ordering or comparison assume byte or JS order where the column uses ICU or libc collation, which can ignore some characters? Do text columns receive NUL, which Postgres rejects? **Verify:** compare `ORDER BY` output with application order on a mixed corpus.
- **DB9 Time binding.** Are dates bound as `timestamp` or `timestamptz` as intended, and does the application preserve microsecond precision it later compares? **Verify:** round-trip a non-UTC value and a sub-millisecond value.
- **DB10 Catalog checks per version.** Do schema gates that compare catalog text (`pg_indexes.indexdef`, constraint definitions) pass on every supported server major version? **Verify:** run the gate against a real database of each supported version.
- **DB11 Isolation level.** Does code that reads and then writes inside one transaction assume more than the isolation level provides? Read Committed (the default) lets concurrent transactions read the same row and both write. **Verify:** name the level and any `FOR UPDATE` or `FOR SHARE`; under `SERIALIZABLE` or `REPEATABLE READ`, check for retry on `40001`.

## SQLite and Cloudflare D1

- **DB12 Bind-parameter limits.** Do `IN (…)` lists and batch inserts stay within the per-statement bind limit (D1 enforces a much lower limit than SQLite's default)? **Verify:** check the limit in the platform docs, then run at the maximum list size.
- **DB13 FTS5 deletes.** For contentless or external-content FTS5 tables, does the delete path satisfy what SQLite requires for the table's options, so that tokens are actually removed? **Verify:** cite the FTS5 documentation for the table's options, then delete a row and query for its token.
