# Retrieve infrastructure projects

Retrieves infrastructure projects and their nested relationships,
including executors, recipients, funding sources, policy areas, and
point geometries.

## Usage

``` r
get_projects(
  ...,
  page = 1L,
  page_size = 50L,
  all_pages = FALSE,
  page_limit = Inf,
  base_url = .obrasgovr_base_url()
)

obter_projetos(
  ...,
  pagina = 1L,
  tamanho_da_pagina = 50L,
  todas_paginas = FALSE,
  limite_paginas = Inf,
  base_url = .obrasgovr_base_url()
)
```

## Arguments

- ...:

  Named filters accepted by the resource. See the complete list with
  `list_filters("projects")`. Filter names and categorical values are
  kept in Portuguese because they are defined by the ObrasGov API.

- page:

  First page to retrieve, starting at 1.

- page_size:

  Number of records per page, between 1 and 200.

- all_pages:

  If `TRUE`, retrieves successive pages starting at `page`.

- page_limit:

  Maximum number of pages to retrieve when `all_pages` is `TRUE`. Use
  `Inf` to retrieve every available page.

- base_url:

  HTTPS base URL. By default, uses the `obrasgovr.base_url` option or
  the official API environment.

- pagina, tamanho_da_pagina, todas_paginas, limite_paginas:

  Portuguese aliases for `page`, `page_size`, `all_pages`, and
  `page_limit`, respectively. These arguments are available only in the
  Portuguese function alias.

## Value

A tibble. One-to-many relationships are preserved in list-columns. Use
[`result_metadata()`](https://strategicprojects.github.io/obrasgovr/reference/result_metadata.md)
to inspect pagination information.

## See also

Other API resources:
[`get_commitments()`](https://strategicprojects.github.io/obrasgovr/reference/get_commitments.md),
[`get_contracts()`](https://strategicprojects.github.io/obrasgovr/reference/get_contracts.md),
[`get_feasibility_studies()`](https://strategicprojects.github.io/obrasgovr/reference/get_feasibility_studies.md),
[`get_geometries()`](https://strategicprojects.github.io/obrasgovr/reference/get_geometries.md),
[`get_last_update()`](https://strategicprojects.github.io/obrasgovr/reference/get_last_update.md),
[`get_physical_execution()`](https://strategicprojects.github.io/obrasgovr/reference/get_physical_execution.md),
[`get_status_history()`](https://strategicprojects.github.io/obrasgovr/reference/get_status_history.md)

## Examples

``` r
if (interactive()) {
  get_projects(uf_principal = "PE", page_size = 10)
}
```
