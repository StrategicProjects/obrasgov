## R CMD check results

0 errors | 0 warnings | 2 notes

The first note identifies this as a new submission.

The second note is local-toolchain-specific: HTML manual validation is skipped
because the installed HTML Tidy is older than the version expected by R-devel.
It does not concern package code or documentation.

## Submission

This is the first CRAN submission of `obrasgov`.

The package accesses a public Brazilian government API. Examples and vignettes
do not require network access during checks. Network behavior is covered by
mocked unit tests; an opt-in live integration test is skipped on CRAN.
