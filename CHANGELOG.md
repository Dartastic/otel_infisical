# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedInfisical<T>(...)` — wraps a otel_infisical call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutInfisicalInstrumentation()` / `Async()`.
