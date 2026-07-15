# Retrieve the data update timestamp

Retrieve the data update timestamp

## Usage

``` r
get_last_update(base_url = .obrasgovr_base_url())

obter_data_atualizacao(base_url = .obrasgovr_base_url())
```

## Arguments

- base_url:

  HTTPS base URL. By default, uses the `obrasgovr.base_url` option or
  the official API environment.

## Value

A `POSIXct` value in the UTC time zone.

## See also

Other API resources:
[`get_commitments()`](https://strategicprojects.github.io/obrasgovr/reference/get_commitments.md),
[`get_contracts()`](https://strategicprojects.github.io/obrasgovr/reference/get_contracts.md),
[`get_feasibility_studies()`](https://strategicprojects.github.io/obrasgovr/reference/get_feasibility_studies.md),
[`get_geometries()`](https://strategicprojects.github.io/obrasgovr/reference/get_geometries.md),
[`get_physical_execution()`](https://strategicprojects.github.io/obrasgovr/reference/get_physical_execution.md),
[`get_projects()`](https://strategicprojects.github.io/obrasgovr/reference/get_projects.md),
[`get_status_history()`](https://strategicprojects.github.io/obrasgovr/reference/get_status_history.md)

## Examples

``` r
if (interactive()) {
  get_last_update()
}
```
