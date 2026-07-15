# Pagination and nested data

``` r

library(obrasgovr)
```

## Retrieve one page first

Paginated functions retrieve one page by default. This prevents an
overly broad query from triggering thousands of requests
unintentionally.

``` r

projects <- get_projects(
  uf_principal = "PE",
  page = 1,
  page_size = 200
)

result_metadata(projects)
```

`page` selects the first page, and `page_size` controls how many records
the API can return per page. The supported page size is between 1 and
200.

## Collect a controlled number of pages

Set `all_pages = TRUE` to combine successive pages into one tibble.
During exploration, also set a finite `page_limit` so the maximum number
of requests is visible in the code.

``` r

projects_sample <- get_projects(
  uf_principal = "PE",
  all_pages = TRUE,
  page_limit = 3,
  page_size = 200
)

result_metadata(projects_sample)$pages_retrieved
```

Collection starts at `page`. Therefore, `page = 4` and `page_limit = 3`
retrieve at most pages 4, 5, and 6.

``` r

projects_window <- get_projects(
  uf_principal = "PE",
  page = 4,
  all_pages = TRUE,
  page_limit = 3,
  page_size = 200
)
```

Use `page_limit = Inf` only when the complete result is required.
Requests are performed sequentially, and the package’s retry and
throttling policies remain active.

## Understand nested relationships

A project may have multiple executors, recipients, transferors, policy
areas, funding sources, and geometries. These relationships are
preserved as list-columns instead of being reduced to the first item.

The following API-shaped example is created locally so its
transformations are executed when the vignette is built:

``` r

projects <- tibble::tibble(
  id_projeto_investimento = c("100.00-01", "200.00-02"),
  desc_nome = c("School renovation", "Health unit construction"),
  executores = list(
    list(
      list(nome_organizacao = "Municipality A", cnpj = "00000000000100"),
      list(nome_organizacao = "State Agency", cnpj = "00000000000200")
    ),
    list(
      list(nome_organizacao = "Municipality B", cnpj = "00000000000300")
    )
  )
)

projects
#> # A tibble: 2 × 3
#>   id_projeto_investimento desc_nome                executores
#>   <chr>                   <chr>                    <list>    
#> 1 100.00-01               School renovation        <list [2]>
#> 2 200.00-02               Health unit construction <list [1]>
```

Inspect one cell without changing the project table:

``` r

projects$executores[[1]]
#> [[1]]
#> [[1]]$nome_organizacao
#> [1] "Municipality A"
#> 
#> [[1]]$cnpj
#> [1] "00000000000100"
#> 
#> 
#> [[2]]
#> [[2]]$nome_organizacao
#> [1] "State Agency"
#> 
#> [[2]]$cnpj
#> [1] "00000000000200"
```

## Normalize one nested relationship

Use
[`tidyr::unnest_longer()`](https://tidyr.tidyverse.org/reference/unnest_longer.html)
to create one row per executor and
[`tidyr::unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html)
to turn executor fields into columns.

``` r

executors <- projects |>
  dplyr::select(id_projeto_investimento, executores) |>
  tidyr::unnest_longer(executores) |>
  tidyr::unnest_wider(executores)

executors
#> # A tibble: 3 × 3
#>   id_projeto_investimento nome_organizacao cnpj          
#>   <chr>                   <chr>            <chr>         
#> 1 100.00-01               Municipality A   00000000000100
#> 2 100.00-01               State Agency     00000000000200
#> 3 200.00-02               Municipality B   00000000000300
```

Keeping normalization explicit avoids multiplying unrelated nested
relationships. If executors and funding sources were unnested together,
every executor could be paired with every funding source for the same
project.

## Work across collected pages

Pages are combined before the tibble is returned, so ordinary tidyverse
code does not need to know which page contained a record.

``` r

projects_sample |>
  dplyr::count(situacao, sort = TRUE)
```

## Save data with retrieval context

For reproducible work, store the query, pagination metadata, and API
update timestamp with the data.

``` r

query <- list(
  uf_principal = "PE",
  all_pages = TRUE,
  page_limit = 3,
  page_size = 200
)

provenance <- list(
  query = query,
  pagination = result_metadata(projects_sample),
  source_updated_at = get_last_update()
)

saveRDS(
  list(data = projects_sample, provenance = provenance),
  "projects-pe.rds"
)
```

This bundle records what was requested, how much was retrieved, when the
request ran, and when ObrasGov last updated its source data.
