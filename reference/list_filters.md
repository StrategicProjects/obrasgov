# List filters accepted by a resource

Lists the filters published in the OpenAPI contract supported by this
package. Unknown filters are rejected before a request is sent to
prevent silently incorrect queries. Filter names and categorical values
remain in Portuguese because they are part of the upstream API contract.

## Usage

``` r
list_filters(resource)

obrasgov_filtros(recurso)
```

## Arguments

- resource:

  A resource name returned by
  [`list_resources()`](https://strategicprojects.github.io/obrasgovr/reference/list_resources.md).
  Portuguese resource names used by earlier package versions are also
  accepted.

- recurso:

  Portuguese alias for `resource`, available only in
  `obrasgov_filtros()`.

## Value

A tibble containing filter names, expected types, and allowed values
when applicable.

## Examples

``` r
list_filters("projects")
#> # A tibble: 29 × 3
#>    filter                  type      allowed_values
#>    <chr>                   <chr>     <list>        
#>  1 id_projeto_investimento character <chr [0]>     
#>  2 projeto_estruturante    character <chr [2]>     
#>  3 desc_nome               character <chr [0]>     
#>  4 nr_cep                  character <chr [0]>     
#>  5 desc_endereco           character <chr [0]>     
#>  6 desc_projeto            character <chr [0]>     
#>  7 desc_funcao_social      character <chr [0]>     
#>  8 desc_meta_global        character <chr [0]>     
#>  9 dt_inicial_prevista     Date      <chr [0]>     
#> 10 dt_final_prevista       Date      <chr [0]>     
#> # ℹ 19 more rows
```
