# An end-to-end ObrasGov workflow

``` r

library(obrasgovr)
```

This vignette develops a reproducible workflow for answering a concrete
question: which active infrastructure projects in Pernambuco are
represented in ObrasGov, and what physical execution and contract
records are associated with them?

API calls are shown but not executed during package builds. This keeps
the vignette suitable for CRAN while leaving the examples ready to run
in an interactive R session.

## 1. Define the query explicitly

Keep the filter values and retrieval limits in an object. This makes the
scope easy to review and store with the result.

``` r

project_query <- list(
  uf_principal = "PE",
  situacao = "Em execução",
  page_size = 200,
  all_pages = TRUE,
  page_limit = 5
)

project_query
#> $uf_principal
#> [1] "PE"
#> 
#> $situacao
#> [1] "Em execução"
#> 
#> $page_size
#> [1] 200
#> 
#> $all_pages
#> [1] TRUE
#> 
#> $page_limit
#> [1] 5
```

Before sending the request, confirm that the chosen filters exist:

``` r

available_project_filters <- list_filters("projects")$filter
requested_filters <- c("uf_principal", "situacao")

all(requested_filters %in% available_project_filters)
#> [1] TRUE
```

## 2. Retrieve the project table

Use [`rlang::exec()`](https://rlang.r-lib.org/reference/exec.html) to
pass a named list of arguments to
[`get_projects()`](https://strategicprojects.github.io/obrasgovr/reference/get_projects.md).

``` r

projects <- rlang::exec(get_projects, !!!project_query)

projects |>
  dplyr::select(
    id_projeto_investimento,
    desc_nome,
    situacao,
    dt_inicial_prevista,
    dt_final_prevista
  )
```

Always inspect the metadata after a limited multi-page request. If
`pages_retrieved` equals `page_limit` while `total_pages` is larger, the
result is intentionally incomplete.

``` r

project_metadata <- result_metadata(projects)

project_metadata[c(
  "total_items",
  "total_pages",
  "pages_retrieved",
  "retrieved_at"
)]
```

## 3. Choose project identifiers

Related endpoint queries should be limited to the projects needed for
the analysis. The example below uses the first ten unique identifiers.

``` r

project_ids <- projects |>
  dplyr::distinct(id_projeto_investimento) |>
  dplyr::slice_head(n = 10) |>
  dplyr::pull(id_projeto_investimento)

project_ids
```

## 4. Retrieve related records

Map over identifiers and combine the returned tibbles. Each request is
narrow and its relationship to the project table is explicit.

``` r

physical_execution <- project_ids |>
  purrr::map(function(project_id) {
    get_physical_execution(
      id_projeto_investimento = project_id,
      all_pages = TRUE,
      page_limit = 5
    )
  }) |>
  purrr::list_rbind()
```

The same pattern retrieves contracts:

``` r

contracts <- project_ids |>
  purrr::map(function(project_id) {
    get_contracts(
      id_projeto_investimento = project_id,
      all_pages = TRUE,
      page_limit = 5
    )
  }) |>
  purrr::list_rbind()
```

For a financial analysis, replace
[`get_contracts()`](https://strategicprojects.github.io/obrasgovr/reference/get_contracts.md)
with
[`get_commitments()`](https://strategicprojects.github.io/obrasgovr/reference/get_commitments.md).
Feasibility studies and project status histories follow the same
pattern.

## 5. Join project attributes to related records

The following local example demonstrates the join without contacting the
API. Its column names mirror the ObrasGov response fields used above.

``` r

projects_example <- tibble::tibble(
  id_projeto_investimento = c("100.00-01", "200.00-02"),
  desc_nome = c("School renovation", "Health unit construction"),
  situacao = c("Em execução", "Em execução")
)

execution_example <- tibble::tibble(
  id_projeto_investimento = c("100.00-01", "200.00-02"),
  percentual_execucao_fisica = c(72.5, 35.0),
  dt_atualizacao_execucao = as.Date(c("2026-06-30", "2026-07-10"))
)

contracts_example <- tibble::tibble(
  id_projeto_investimento = c("100.00-01", "100.00-01", "200.00-02"),
  id_contrato = c(11L, 12L, 21L),
  valor_global_contrato = c(1200000, 300000, 2450000)
)
```

Join execution data one row per project:

``` r

project_execution <- projects_example |>
  dplyr::left_join(
    execution_example,
    by = "id_projeto_investimento"
  )

project_execution
#> # A tibble: 2 × 5
#>   id_projeto_investimento desc_nome              situacao percentual_execucao_…¹
#>   <chr>                   <chr>                  <chr>                     <dbl>
#> 1 100.00-01               School renovation      Em exec…                   72.5
#> 2 200.00-02               Health unit construct… Em exec…                   35  
#> # ℹ abbreviated name: ¹​percentual_execucao_fisica
#> # ℹ 1 more variable: dt_atualizacao_execucao <date>
```

Contracts form a one-to-many relationship. Summarize them before joining
when the desired result is one row per project:

``` r

contract_summary <- contracts_example |>
  dplyr::group_by(id_projeto_investimento) |>
  dplyr::summarise(
    contract_count = dplyr::n(),
    total_contract_value = sum(valor_global_contrato, na.rm = TRUE),
    .groups = "drop"
  )

analysis_table <- project_execution |>
  dplyr::left_join(
    contract_summary,
    by = "id_projeto_investimento"
  )

analysis_table
#> # A tibble: 2 × 7
#>   id_projeto_investimento desc_nome              situacao percentual_execucao_…¹
#>   <chr>                   <chr>                  <chr>                     <dbl>
#> 1 100.00-01               School renovation      Em exec…                   72.5
#> 2 200.00-02               Health unit construct… Em exec…                   35  
#> # ℹ abbreviated name: ¹​percentual_execucao_fisica
#> # ℹ 3 more variables: dt_atualizacao_execucao <date>, contract_count <int>,
#> #   total_contract_value <dbl>
```

## 6. Preserve provenance

Save data together with the original query, pagination metadata, package
version, retrieval time, and source update timestamp.

``` r

provenance <- list(
  query = project_query,
  project_metadata = result_metadata(projects),
  source_updated_at = get_last_update(),
  package_version = utils::packageVersion("obrasgovr"),
  saved_at = Sys.time()
)

saveRDS(
  list(
    projects = projects,
    physical_execution = physical_execution,
    contracts = contracts,
    provenance = provenance
  ),
  "obrasgovr-pe-workflow.rds"
)
```

The saved object now contains both the analytical inputs and enough
context to audit or repeat the retrieval later.
