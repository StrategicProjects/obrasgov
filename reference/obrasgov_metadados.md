# Metadados de paginacao de um resultado

Metadados de paginacao de um resultado

## Usage

``` r
obrasgov_metadados(x)
```

## Arguments

- x:

  Tibble retornado por uma funcao paginada do pacote.

## Value

Uma lista com o recurso, o total informado pela API e as paginas
coletadas; `NULL` para outros objetos.

## Examples

``` r
obrasgov_metadados(tibble::tibble())
#> NULL
```
