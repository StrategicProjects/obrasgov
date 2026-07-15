# Changelog

## obrasgov 0.1.0

### New API client

- Rebuilt the package for the new ObrasGov open data API.
- Added consistent snake_case functions for all eight public resources.
- Added HTTP/2 over TLS negotiation, transient retries, request
  throttling and actionable API errors.
- Added safe multi-page collection, typed date columns, pagination
  metadata and lossless nested relationships.
- Added offline unit tests, optional live integration tests, vignettes,
  pkgdown configuration and continuous integration workflows.
