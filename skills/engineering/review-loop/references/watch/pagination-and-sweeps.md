# Watch-list: Pagination, cursors, and sweeps

Attach when the diff touches list endpoints, keyset or offset pagination, cursors, batch scans, outbox or queue polling, or reconcile, garbage-collection, repair, or retention sweeps.

Probe after the coverage table. Confirm the application's contract first; a mismatch with an entry alone is not a finding. Named APIs are leads, not accepted fixes. `verified` closure needs a probe of the property; report a step you cannot run safely as not run. Report `ID: evidence`, a finding, or `ID: n/a`.

- **PS1 Page boundaries are exact.** Does the next page start immediately after the last item returned, with ties in the sort key broken by a unique column? **Verify:** seed ties at the page boundary, page through, and compare with the unpaged result.
- **PS2 Cursors keep the promised consistency.** If the API promises snapshot or revision consistency across pages, does a continuation cursor stay pinned to the first page's snapshot rather than re-pinning to the latest? If it promises only no-skip or no-duplicate traversal, does it keep that under concurrent writes? **Verify:** find the documented contract, then mutate between pages and check against it.
- **PS3 Sort order agrees with the database.** Are keyset comparisons in application code performed in the database's collation and type semantics? **Verify:** page through a corpus of mixed case, accents, symbols, and separators, comparing application order with database order.
- **PS4 Sweeps reach every page.** Do reconcile, garbage-collection, repair, and rebuild sweeps continue past the first page, persisting or advancing the cursor rather than discarding it and restarting from the beginning? **Verify:** seed more rows than one batch and assert that every row is processed across runs.
- **PS5 One bad item does not wedge the rest.** Can one failing, conflicted, or poisoned item block the scan, starve the batch, or hold up the outbox page? **Verify:** make the first item fail permanently and check that the rest progress.
- **PS6 "None exist" means none.** Do existence and all-settled checks cover every candidate, rather than a `LIMIT 1` sample or a filtered subset? **Verify:** seed a matching row outside the sample.
- **PS7 Cursors stay within limits.** Do cursors stay within token or size limits at maximum key lengths, and are tampered cursors rejected? **Verify:** use maximum-length keys and a modified cursor. For authorization before `LIMIT`, see authz-boundaries AB2.
