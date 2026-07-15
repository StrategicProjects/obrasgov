# Contributing to obrasgovr

Thank you for your interest in contributing.

## Before you begin

- For bugs and behavior changes, open an issue describing the case and
  include a minimal reproducible example.
- Never include personal data, credentials, or non-public information.
- Interface changes must use English `snake_case` names and follow the
  [tidyverse style guide](https://style.tidyverse.org/).
- Preserve Portuguese names and values that come directly from the
  upstream ObrasGov API contract.

## Development

1.  Create a fork and a branch for the change.
2.  Install dependencies with
    [`pak::pak()`](https://pak.r-lib.org/reference/pak.html).
3.  Add or update tests in `tests/testthat/`.
4.  Run `devtools::document()`, `devtools::test()`, and
    `devtools::check()`.
5.  Update `NEWS.md` when a change affects users.

Integration tests against the official API are optional and can be
enabled with:

``` sh
OBRASGOVR_LIVE_TESTS=true R -q -e 'devtools::test()'
```

By participating, you agree to follow the [Code of
Conduct](https://strategicprojects.github.io/obrasgovr/CODE_OF_CONDUCT.md).
