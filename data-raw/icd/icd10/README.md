# ICD-10 source workflow

## Source labels

CMS is the canonical input for ICD-10-CM diagnoses and ICD-10-PCS procedures
(`src = "cms"`, US fiscal years). CDC also distributes CM order files, but
these are not the mortality classification. Within ICD-10, `src = "cdc"`
means CDC/NCHS mortality codes (`cdc_allvalid.R`, calendar years).
ICD-9 has its own CDC/CMS source handling.

The older `icd10_cm_pcs.R` merger preferred CMS descriptions and headers.
Commit `4fbb956` (November 24, 2025) replaced it with direct CMS input;
`dbf74a9` later removed the obsolete merger. `cdc_icd10_cm.R` remains an
optional historical CM import, not an input to the packaged database. The
package's canonical ICD-10-CM source remains CMS; CDC-hosted CM files are not
merged into the CDC mortality source.

## Selecting and rebuilding releases

`cms-releases.tsv` selects one archive and order-file basename per fiscal
year and code type. Only listed archives are read, directly from their ZIP
members. Additional archives, including the original October FY2026 files,
do not affect selection. Missing archives or missing/ambiguous members fail
explicitly. Directory names inside publisher archives may vary.

The FY2026 entries select the April 1, 2026 update; FY2027 selects the
October 1, 2026 release. FY2022 PCS selects the January 2022 errata
archive, preserving its two additional procedure codes. Each annual table represents the selected release
snapshot, not a union of every release within that year. The package's
integer validity years do not encode within-year effective dates. An April
addition is recorded in that fiscal year; exact discharge-date validation
requires the applicable dated source release.

From this directory:

```sh
gmake download        # explicit network refresh; review changed inputs
gmake                 # rebuild from local sources
```

For downstream ICD tables, comorbidity mappings, and `R/sysdata.rda`, run
`gmake -C data-raw` from the repository root. The parent ICD Makefile always
consults its child Makefiles. Import scripts, the manifest, and selected
source files are dependencies; unchanged builds do not regenerate data.
After adding a new year, update the manifest, download URLs, source review,
NEWS, and source provenance together. Preserve selected archives
in the repository or provide a reproducible download before release.

## CDC mortality coverage

`cdc_allvalid.R` reads the 2009, 2011, 2020, and 2023 releases. It reconstructs
historical years and currently carries the 2023 table forward through 2025.
The carry-forward is an explicit assumption, not a newer mortality release.
Do not extend it using CDC ICD-10-CM files or an upload timestamp alone.

On September 30, 2026, the [CDC directory](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/)
still listed the 2023 CSV/PDF/XLSX files dated December 19, 2024. The remote
CSV was downloaded and verified byte-for-byte identical to the local input
with matching SHA-256 `3b0bd43cf4f1330bcb683ea010e7a9396dc923b11db0be24919481b32ec283fb`.
Its heading specifies 1999–2023. No newer allvalid mortality file was listed,
so no parser or source-data change is needed. Extending mortality coverage
beyond 2025 requires separate evidence of continued applicability. CDC's
final mortality reports state that no ICD-10 codes were added or deleted in
2023 or 2024 ([2023 report](https://www.cdc.gov/nchs/data/nvsr/nvsr74/nvsr74-10.pdf),
[2024 report](https://stacks.cdc.gov/view/cdc/252465/cdc_252465_DS1.pdf)). This
supports the unchanged code set through 2024, but does not establish allvalid
coverage for 2025–2027. We therefore leave the existing carry-forward through
2025 unchanged and do not extend it to 2026 or 2027. Treat 2024–2025 as the
package's documented carry-forward assumption, not as years covered by the
2023 CDC allvalid file; future extensions need year-specific mortality-source
evidence.
