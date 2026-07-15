# obrasgovr

**obrasgovr** provides a modern R interface to the [ObrasGov Open Data
API](https://api-publica.obrasgov.gestao.gov.br/obras/docs), maintained
by the Brazilian federal government. It retrieves data about
infrastructure projects, physical execution, budget commitments,
contracts, geometries, feasibility studies, and the status histories of
suspended or cancelled projects.

## Why use obrasgovr?

The official API is extensive and paginated. Using it directly requires
building URLs, handling HTTP errors, joining pages, and transforming
nested JSON. **obrasgovr** handles those tasks and returns
analysis-ready tibbles without discarding one-to-many relationships. It
is designed for researchers, oversight bodies, public managers, data
journalists, and civil society organizations.

Key features include:

- a consistent English `snake_case` interface, with Portuguese
  compatibility aliases;
- HTTP/2 over TLS negotiation, retries, and a limit of 60 requests per
  minute;
- explicit pagination and retrieval metadata;
- dates converted to `Date` and the update timestamp converted to
  `POSIXct`;
- nested objects preserved as list-columns;
- offline unit tests and optional integration tests against the official
  API.

The API’s filter names, response fields, and categorical values remain
in Portuguese because they are part of the upstream ObrasGov contract.

## Installation

The package is under development and is not yet on CRAN. Install the
GitHub version with:

``` r

install.packages("pak")
pak::pak("StrategicProjects/obrasgovr")
```

## Usage

``` r

library(obrasgovr)

projects_pe <- get_projects(
  uf_principal = "PE",
  situacao = "Em execução",
  page_size = 100
)

projects_pe
result_metadata(projects_pe)
```

Inspect resource and filter names without accessing the internet:

``` r

list_resources()
list_filters("projects")
```

Retrieving multiple pages must be requested explicitly:

``` r

contracts <- get_contracts(
  id_projeto_investimento = "134851.26-07",
  all_pages = TRUE,
  page_limit = 20
)
```

Portuguese aliases remain available for compatibility. They retain the
original Portuguese pagination argument names:

``` r

projetos_pe <- obter_projetos(
  uf_principal = "PE",
  tamanho_da_pagina = 100
)
```

See
[`vignette("obrasgovr")`](https://strategicprojects.github.io/obrasgovr/articles/obrasgovr.md)
for a complete introduction,
[`vignette("end-to-end-workflow")`](https://strategicprojects.github.io/obrasgovr/articles/end-to-end-workflow.md)
for a reproducible multi-resource analysis, and
[`vignette("pagination-and-nested-data")`](https://strategicprojects.github.io/obrasgovr/articles/pagination-and-nested-data.md)
for pagination and list-columns.

## Current API

This package exclusively uses the current environment at
`https://api-publica.obrasgov.gestao.gov.br/obras`. The previous API is
scheduled to be discontinued on August 31, 2026, and is not supported.

## Contributing and conduct

Contributions are welcome. Read
[CONTRIBUTING.md](https://strategicprojects.github.io/obrasgovr/CONTRIBUTING.md)
and the [Code of
Conduct](https://strategicprojects.github.io/obrasgovr/CODE_OF_CONDUCT.md)
before opening an issue or pull request.

## License

MIT © obrasgovr authors.
