# valhalla-openapi-models-swift

A pre-generated set of Valhalla's API models and configuration models.

## Contributing

Install OpenAPI Generator **7.26.0 or newer (stable release)** and SwiftFormat:

```sh
brew install openapi-generator swiftformat
```

Generator 7.26.0 includes the [Swift nullable-array fix](https://github.com/OpenAPITools/openapi-generator/pull/24770),
so height responses with missing elevation data generate correctly without a manual patch.
If you already have an older generator installed, run `brew upgrade openapi-generator`.

Regenerate both sets of models and run the tests from the repository root:

```sh
./generate_models.sh
swift test
```
