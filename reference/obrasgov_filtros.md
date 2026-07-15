# Filtros aceitos por um recurso

Lista os filtros publicados no contrato OpenAPI da versao suportada pelo
pacote. Filtros desconhecidos sao rejeitados antes da requisicao para
evitar consultas silenciosamente incorretas.

## Usage

``` r
obrasgov_filtros(recurso)
```

## Arguments

- recurso:

  Nome de um recurso retornado por
  [`obrasgov_recursos()`](https://strategicprojects.github.io/obrasgov/reference/obrasgov_recursos.md).

## Value

Um tibble com nomes, tipos esperados e, quando aplicavel, valores
permitidos.

## Examples

``` r
obrasgov_filtros("projetos")
#> # A tibble: 29 × 3
#>    filtro                  tipo      valores_permitidos
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
