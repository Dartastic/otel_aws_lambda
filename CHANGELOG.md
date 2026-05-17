# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedAwsLambda<T>(...)` — wraps a otel_aws_lambda call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutAwsLambdaInstrumentation()` / `Async()`.
