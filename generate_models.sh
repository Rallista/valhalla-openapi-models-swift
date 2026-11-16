#!/bin/bash

# Check that required tools are installed
if ! command -v openapi-generator >/dev/null 2>&1; then
    echo "Error: openapi-generator is not installed or not on your PATH."
    echo "Install it with: brew install openapi-generator"
    echo "See https://openapi-generator.tech/docs/installation for other options."
    exit 1
fi

if ! command -v swiftformat >/dev/null 2>&1; then
    echo "Error: swiftformat is not installed or not on your PATH."
    echo "Install it with: brew install swiftformat"
    exit 1
fi

# Define the source directories
source_dirs=("Sources/ValhallaModels" "Sources/ValhallaConfigModels")

if [ "$1" == "clean" ]; then
    echo "Cleaning openapi models..."
    rm -rf .openapi-temp
    for dir in "${source_dirs[@]}"; do
        rm -rf "$dir/Models"
        rm -rf "$dir/Support"
    done
fi

mkdir -p .openapi-temp

for dir in "${source_dirs[@]}"; do
    echo "Generating Swift models for $dir..."

    # Check if openapi.yaml exists in the current directory
    if [ ! -f "$dir/openapi.yaml" ]; then
        echo "Error: openapi.yaml not found in $dir"
        continue
    fi

    # Create necessary directories
    mkdir -p "$dir/Models"
    mkdir -p "$dir/Support"

    # Generate models
    openapi-generator generate -i "$dir/openapi.yaml" -g swift5 --strict-spec=true \
         -o .openapi-temp --model-package Models --skip-validate-spec --additional-properties=useJsonEncodable=false

    # Format generated files
    swiftformat .openapi-temp/OpenAPIClient/Classes/OpenAPIsModels

    # Move the generated files to the correct directory
    mv .openapi-temp/OpenAPIClient/Classes/OpenAPIsModels/* "$dir/Models/"
    mv .openapi-temp/OpenAPIClient/Classes/OpenAPIs/Validation.swift "$dir/Support/Validation.swift"

    echo "Done generating models for $dir"
done

# Clean up temporary directory
rm -rf .openapi-temp

echo "All models generated successfully"
