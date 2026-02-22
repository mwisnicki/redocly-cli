# Testing Data URL Support with Redoc

This directory contains documentation and test files for running Redoc against the `copilot/fix-data-url` branch, which adds RFC 2397 data URL support to Redocly CLI.

## Quick Start

```bash
git checkout copilot/fix-data-url
npm install && npm run compile
./test-data-url.sh
```

## Documentation Files

📄 **[ANSWER.md](./ANSWER.md)** - Quick summary answering "How do I run Redoc against copilot/fix-data-url?"

📘 **[HOW_TO_RUN_REDOC.md](./HOW_TO_RUN_REDOC.md)** - Step-by-step guide to testing with Redoc

📚 **[TESTING_DATA_URL.md](./TESTING_DATA_URL.md)** - Comprehensive testing documentation

## Test Files

🧪 **[test-data-url.yaml](./test-data-url.yaml)** - Full OpenAPI spec demonstrating data URLs

🧪 **[test-data-url-simple.yaml](./test-data-url-simple.yaml)** - Simplified example

🔧 **[test-data-url.sh](./test-data-url.sh)** - Automated test script

## What You'll Learn

- ✅ How to use data URLs in OpenAPI `$ref` fields
- ✅ How to test with lint, bundle, and build-docs commands
- ✅ How Redoc rendering works with data URLs
- ✅ Best practices for bundling specs with data URLs

## Key Insight

**Redoc is already integrated** into Redocly CLI via the `build-docs` command. You don't need to set up Redoc separately!

The workflow is:

1. **Lint** - Validates data URLs ✅
2. **Bundle** - Resolves data URLs (use `--dereferenced` flag) ✅
3. **Build-docs** - Generates Redoc HTML ✅

Start with **[ANSWER.md](./ANSWER.md)** for the quick overview! 🚀
