# Contribuindo com o obrasgov

Obrigado pelo interesse em contribuir.

## Antes de comecar

- Para bugs e mudancas de comportamento, abra uma issue descrevendo o
  caso e inclua um exemplo minimo reproduzivel.
- Nunca inclua dados pessoais, credenciais ou informacoes nao publicas.
- Mudancas de interface devem manter nomes em `snake_case` e seguir o
  [tidyverse style guide](https://style.tidyverse.org/).

## Desenvolvimento

1.  Crie um fork e um branch para a mudanca.
2.  Instale as dependencias com
    [`pak::pak()`](https://pak.r-lib.org/reference/pak.html).
3.  Adicione ou atualize testes em `tests/testthat/`.
4.  Execute `devtools::document()`, `devtools::test()` e
    `devtools::check()`.
5.  Atualize `NEWS.md` quando a mudanca afetar usuarios.

Testes de integracao com a API oficial sao opcionais e podem ser
ativados com:

``` sh
OBRASGOV_LIVE_TESTS=true R -q -e 'devtools::test()'
```

Ao participar, voce concorda com o [Codigo de
Conduta](https://strategicprojects.github.io/obrasgov/CODE_OF_CONDUCT.md).
