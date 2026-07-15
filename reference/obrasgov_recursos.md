# Recursos disponiveis na API ObrasGov

Recursos disponiveis na API ObrasGov

## Usage

``` r
obrasgov_recursos()
```

## Value

Um tibble com o nome do recurso, a funcao correspondente e o endpoint da
API.

## Examples

``` r
obrasgov_recursos()
#> # A tibble: 8 × 4
#>   recurso             funcao                    endpoint                paginado
#>   <chr>               <chr>                     <chr>                   <lgl>   
#> 1 projetos            obter_projetos            projeto-investimento    TRUE    
#> 2 empenhos            obter_empenhos            empenho                 TRUE    
#> 3 execucao_fisica     obter_execucao_fisica     execucao-fisica         TRUE    
#> 4 contratos           obter_contratos           contrato                TRUE    
#> 5 geometrias          obter_geometrias          geometria               TRUE    
#> 6 historico_situacao  obter_historico_situacao  historico-situacao-can… TRUE    
#> 7 estudos_viabilidade obter_estudos_viabilidade estudo-viabilidade      TRUE    
#> 8 data_atualizacao    obter_data_atualizacao    data-atualizacao        FALSE   
```
