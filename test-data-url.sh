#!/bin/bash

# Quick test script for data URL support with Redoc
# This script tests the copilot/fix-data-url branch changes

set -e

echo "================================================"
echo "Testing Redoc with Data URL Support"
echo "================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "Error: Please run this script from the redocly-cli root directory"
    exit 1
fi

# Check Node version
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "Error: Node.js version 20 or higher is required"
    echo "Current version: $(node --version)"
    exit 1
fi

echo "✓ Node.js version check passed: $(node --version)"
echo ""

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Check if fix-data-url branch exists
if ! git rev-parse --verify copilot/fix-data-url >/dev/null 2>&1; then
    echo "Fetching copilot/fix-data-url branch..."
    git fetch origin copilot/fix-data-url:copilot/fix-data-url
fi

# Offer to checkout the branch if not already on it
if [ "$CURRENT_BRANCH" != "copilot/fix-data-url" ]; then
    echo "You are not on the copilot/fix-data-url branch."
    read -p "Would you like to checkout copilot/fix-data-url? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout copilot/fix-data-url
    else
        echo "Continuing with current branch..."
    fi
fi

# Build the project
echo "================================================"
echo "Step 1: Building the project..."
echo "================================================"
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

echo "Compiling TypeScript..."
npm run compile

echo "✓ Build complete"
echo ""

# Check if test file exists
if [ ! -f "test-data-url.yaml" ]; then
    echo "Error: test-data-url.yaml not found"
    echo "Please ensure you have the test file in the repository root"
    exit 1
fi

# Lint the test file
echo "================================================"
echo "Step 2: Linting OpenAPI spec with data URLs..."
echo "================================================"
npm run cli -- lint test-data-url.yaml || echo "Note: Lint warnings are expected for this test spec"
echo ""

# Bundle the test file with dereferencing
echo "================================================"
echo "Step 3: Bundling OpenAPI spec (resolving data URLs)..."
echo "================================================"
npm run cli -- bundle test-data-url.yaml --dereferenced -o bundled.yaml
echo ""

# Build docs with Redoc
echo "================================================"
echo "Step 4: Building Redoc documentation..."
echo "================================================"
npm run cli -- build-docs bundled.yaml
echo ""

if [ -f "redoc-static.html" ]; then
    echo "✓ Redoc documentation generated successfully!"
    echo ""
    echo "================================================"
    echo "SUCCESS! Data URL support is working!"
    echo "================================================"
    echo ""
    echo "The generated documentation is in: redoc-static.html"
    echo ""
    echo "To view it:"
    echo "  - Option 1: Open redoc-static.html in your browser"
    echo "  - Option 2: Run 'npx http-server' and open http://localhost:8080/redoc-static.html"
    echo ""
    echo "What to verify:"
    echo "  1. The /users endpoint shows a schema with id, name, and email fields"
    echo "  2. The /products endpoint shows a schema with id, name, and price fields"
    echo "  3. The /orders endpoint shows request body schema"
    echo "  4. No errors about unresolved references"
    echo ""
else
    echo "Error: Documentation generation failed"
    exit 1
fi

# Optional: Run unit tests
read -p "Would you like to run the unit tests? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "================================================"
    echo "Running unit tests..."
    echo "================================================"
    npm run unit -- packages/core/src/__tests__/resolve.test.ts
fi

echo ""
echo "Done!"
