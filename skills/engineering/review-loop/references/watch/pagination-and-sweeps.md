# Watch-list: Pagination, cursors, and sweeps

Attach when the diff touches list endpoints, keyset or offset pagination, cursors, batch scans, outbox or queue polling, or reconcile, garbage-collection, repair, or retention sweeps.

Apply after coverage enumeration, using the common worker brief's reporting format and the supplied evidence rules.

- **PS1 Page boundaries are exact.** Does the next page start immediately after the last item returned, with ties in the sort key broken by a unique column? **Verify:** seed ties at the page boundary, page through, and compare with the unpaged result.
- **PS2 Cursors keep the promised consistency.** If the API promises snapshot or revision consistency across pages, does a continuation cursor stay pinned to the first page's snapshot rather than re-pinning to the latest? If it promises only no-skip or no-duplicate traversal, does it keep that under concurrent writes? **Verify:** find the documented contract, then mutate between pages and check against it.
- **PS3 Sort order agrees with the database.** Are keyset comparisons in application code performed in the database's collation and type semantics? **Verify:** page through a corpus of mixed case, accents, symbols, and separators, comparing application order with database order.
- **PS4 Sweeps reach every page.** Do reconcile, garbage-collection, repair, and rebuild sweeps continue past the first page, persisting or advancing the cursor rather than discarding it and restarting from the beginning? **Verify:** seed more rows than one batch and assert that every row is processed across runs.
- **PS5 Failed items do not wedge later pages.** Can failing, conflicted, or poisoned items block the scan, starve the batch, or hold up the outbox? **Verify:** make the first item and then a full first page fail permanently; check that later eligible rows still progress within the intended budget.
- **PS6 "None exist" means none.** Do existence and all-settled checks cover every candidate, rather than a `LIMIT 1` sample or a filtered subset? **Verify:** seed a matching row outside the sample.
- **PS7 Cursors stay within limits.** Do cursors stay within token or size limits at maximum key lengths, and are tampered cursors rejected? **Verify:** use maximum-length keys and a modified cursor. For authorization before `LIMIT`, see authz-boundaries AB2.
- **PS8 Truncation is not completion.** When a scan reaches a row, page, time, or byte cap, does it preserve continuation or report partial/unknown rather than “complete,” “none,” or “all settled”? **Verify:** place the only relevant row just beyond each cap, exhaust the budget, and inspect both the reported result and the next scan's progress.
