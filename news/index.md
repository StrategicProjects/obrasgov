# Changelog

## obrasgovr 0.1.0

### New API client

- Renamed the package and repository to `obrasgovr` to avoid a name
  collision with an earlier GitHub package for the legacy ObrasGov API.
- Rebuilt the package for the new ObrasGov open data API.
- Added consistent snake_case functions for all eight public resources.
- Added HTTP/2 over TLS negotiation, transient retries, request
  throttling and actionable API errors.
- Added safe multi-page collection, typed date columns, pagination
  metadata and lossless nested relationships.
- Added offline unit tests, optional live integration tests, vignettes,
  pkgdown configuration and continuous integration workflows.
- Made English names canonical across the public interface and
  documentation, while retaining Portuguese compatibility aliases.
- Added step-by-step vignettes for resource discovery, safe pagination,
  nested data normalization, multi-resource joins, and reproducible
  provenance.
