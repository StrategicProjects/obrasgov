# Introduction to obrasgovr

`obrasgovr` provides an R interface to the Brazilian federal
government’s ObrasGov Open Data API. It validates filters locally,
handles HTTP failures, collects paginated results, and returns tibbles
with predictable types.

This vignette walks through the usual sequence: discover a resource,
inspect its filters, make a small query, inspect the result, and
retrieve related data.

``` r

library(obrasgovr)
```

## 1. Discover available resources

Start with
[`list_resources()`](https://strategicprojects.github.io/obrasgovr/reference/list_resources.md).
This function is entirely local and does not contact the API.

``` r

list_resources()
#> # A tibble: 8 × 4
#>   resource            function_name           endpoint                 paginated
#>   <chr>               <chr>                   <chr>                    <lgl>    
#> 1 projects            get_projects            projeto-investimento     TRUE     
#> 2 commitments         get_commitments         empenho                  TRUE     
#> 3 physical_execution  get_physical_execution  execucao-fisica          TRUE     
#> 4 contracts           get_contracts           contrato                 TRUE     
#> 5 geometries          get_geometries          geometria                TRUE     
#> 6 status_history      get_status_history      historico-situacao-canc… TRUE     
#> 7 feasibility_studies get_feasibility_studies estudo-viabilidade       TRUE     
#> 8 last_update         get_last_update         data-atualizacao         FALSE
```

The `function_name` column identifies the function used to query each
resource. All main package functions use English names. The API’s filter
names, response fields, and categorical values remain in Portuguese
because they are part of the official ObrasGov contract.

## 2. Inspect filters before querying

Use
[`list_filters()`](https://strategicprojects.github.io/obrasgovr/reference/list_filters.md)
to see the accepted filter names and their expected types. For example,
projects can be filtered by state, status, registration year, dates, and
several other attributes.

``` r

project_filters <- list_filters("projects")
project_filters[c("filter", "type")]
#> # A tibble: 29 × 2
#>    filter                  type     
#>    <chr>                   <chr>    
#>  1 id_projeto_investimento character
#>  2 projeto_estruturante    character
#>  3 desc_nome               character
#>  4 nr_cep                  character
#>  5 desc_endereco           character
#>  6 desc_projeto            character
#>  7 desc_funcao_social      character
#>  8 desc_meta_global        character
#>  9 dt_inicial_prevista     Date     
#> 10 dt_final_prevista       Date     
#> # ℹ 19 more rows
```

Allowed categorical values are stored in the `allowed_values`
list-column. The following code retrieves the values accepted by the
`situacao` filter:

``` r

project_filters$allowed_values[
  project_filters$filter == "situacao"
][[1]]
#> [1] "Cadastrada"  "Cancelada"   "Concluída"   "Em execução" "Inacabada"  
#> [6] "Paralisada"
```

Dates can be supplied as `Date` values. The package serializes them
using the ISO `YYYY-MM-DD` format expected by the API.

## 3. Retrieve a small first page

Begin with a narrow query and a small `page_size`. Network calls are not
run when this vignette is built, so installation and CRAN checks do not
depend on the external service.

``` r

projects_pe <- get_projects(
  uf_principal = "PE",
  situacao = "Em execução",
  dt_cadastro = as.Date("2024-01-01"),
  page_size = 25
)

projects_pe
```

The returned object is a tibble. Date-like fields such as `dt_cadastro`
are converted to `Date` when every non-missing value uses the ISO date
format. Nested one-to-many relationships are preserved as list-columns.

## 4. Inspect pagination metadata

Every paginated result carries retrieval metadata. Check it before
deciding whether more pages are required.

``` r

metadata <- result_metadata(projects_pe)

metadata$total_items
metadata$total_pages
metadata$pages_retrieved
metadata$retrieved_at
```

The initial request retrieves only one page. To collect more pages
safely, use `all_pages = TRUE` together with a finite `page_limit`. See
[`vignette("pagination-and-nested-data")`](https://strategicprojects.github.io/obrasgovr/articles/pagination-and-nested-data.md)
for details.

## 5. Retrieve related resources

ObrasGov resources can be related through `id_projeto_investimento`.
After selecting a project, use its identifier to retrieve physical
execution, contracts, commitments, status history, and feasibility
studies.

``` r

project_id <- projects_pe$id_projeto_investimento[[1]]

physical_execution <- get_physical_execution(
  id_projeto_investimento = project_id
)

contracts <- get_contracts(
  id_projeto_investimento = project_id
)

commitments <- get_commitments(
  id_projeto_investimento = project_id
)

status_history <- get_status_history(
  id_projeto_investimento = project_id
)
```

Filtering related endpoints by project identifier avoids downloading
large tables and makes the relationship explicit in the analysis code.

## 6. Record the source update timestamp

The API reports the time of its most recent data load. Store this value
with the query results to identify the temporal version of the source.

``` r

source_updated_at <- get_last_update()
source_updated_at
```

## Portuguese aliases

The original Portuguese function names remain available as compatibility
aliases. Paginated aliases retain their original pagination argument
names.

``` r

projetos_pe <- obter_projetos(
  uf_principal = "PE",
  tamanho_da_pagina = 25,
  todas_paginas = FALSE
)
```

New code should use
[`get_projects()`](https://strategicprojects.github.io/obrasgovr/reference/get_projects.md),
`page_size`, and `all_pages`.

## Client configuration

The API does not require authentication. Three options customize
transport without changing every function call:

``` r

options(
  obrasgovr.base_url = "https://api-publica.obrasgov.gestao.gov.br/obras",
  obrasgovr.timeout = 30,
  obrasgovr.user_agent = "my-project/1.0 (contact@example.org)"
)
```

By default, the client requests HTTP/2 over TLS, retries transient
failures, and limits access to 60 requests per minute.

## Next steps

- Read
  [`vignette("pagination-and-nested-data")`](https://strategicprojects.github.io/obrasgovr/articles/pagination-and-nested-data.md)
  to collect multiple pages and normalize list-columns.
- Read
  [`vignette("end-to-end-workflow")`](https://strategicprojects.github.io/obrasgovr/articles/end-to-end-workflow.md)
  to build a reproducible dataset from multiple ObrasGov resources.
