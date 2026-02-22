# Running Redoc Against copilot/fix-data-url Branch - Complete Answer

## Question

"How can I run https://github.com/Redocly/redoc against code from copilot/fix-data-url of this repo?"

## Answer Summary

**Redoc is already integrated** into this repository via the `build-docs` command in Redocly CLI. You don't need to set up Redoc separately. Here's how to test the data URL support feature with Redoc:

### Quick Start (3 commands)

```bash
git checkout copilot/fix-data-url
npm install && npm run compile
./test-data-url.sh
```

The automated script will:

1. ✅ Build the project with data URL support
2. ✅ Lint an OpenAPI spec with data URLs
3. ✅ Bundle the spec (resolving data URLs)
4. ✅ Generate Redoc HTML documentation
5. ✅ Show you how to view the results

### What is copilot/fix-data-url?

This branch adds support for **RFC 2397 data URLs** in OpenAPI `$ref` fields, allowing you to embed schemas directly:

```yaml
schema:
  # Instead of external files:
  $ref: './schemas/user.json'

  # You can now use data URLs:
  $ref: 'data:application/json;base64,eyJ0eXBlIjoib2JqZWN0In0='
```

### What Gets Tested?

The test files demonstrate:

- **Base64-encoded** data URLs
- **URL-encoded** data URLs
- **Simple** data URLs without encoding
- Integration with **lint**, **bundle**, and **build-docs** commands

### Files Provided

| File                        | Purpose                                  |
| --------------------------- | ---------------------------------------- |
| `HOW_TO_RUN_REDOC.md`       | Quick answer to your question            |
| `TESTING_DATA_URL.md`       | Comprehensive testing guide              |
| `test-data-url.yaml`        | Full OpenAPI spec with data URL examples |
| `test-data-url-simple.yaml` | Simpler example for quick tests          |
| `test-data-url.sh`          | Automated test script                    |

### Manual Workflow

If you prefer manual control:

```bash
# 1. Setup
git checkout copilot/fix-data-url
npm install && npm run compile

# 2. Test linting (validates data URL parsing)
npm run cli -- lint test-data-url.yaml

# 3. Bundle with dereferencing (resolves data URLs)
npm run cli -- bundle test-data-url.yaml --dereferenced -o bundled.yaml

# 4. Generate Redoc documentation
npm run cli -- build-docs bundled.yaml

# 5. View the result
open redoc-static.html
```

### Key Finding: Why Bundle First?

The `lint` and `bundle` commands fully support data URLs directly. However, `build-docs` works best when you:

1. Bundle with `--dereferenced` flag first
2. Then build docs from the bundled spec

This ensures all data URL references are fully inlined and avoids component naming issues in the Redoc rendering process.

### Verification

After running the workflow, check that:

- ✅ No errors about unresolved references
- ✅ Schemas from data URLs appear correctly in the documentation
- ✅ All endpoints display their schema properties
- ✅ The HTML file is generated successfully

### What Changes Were Made?

The `copilot/fix-data-url` branch modified:

1. `packages/core/src/ref-utils.ts` - Recognize `data:` URLs as absolute URLs
2. `packages/core/src/resolve.ts` - Parse and decode data URLs (base64 and URL-encoded)
3. Added comprehensive tests for data URL functionality

### Resources

- **Start here**: `HOW_TO_RUN_REDOC.md` - Direct answer to your question
- **Deep dive**: `TESTING_DATA_URL.md` - Full testing documentation
- **Examples**: `test-data-url.yaml` and `test-data-url-simple.yaml`
- **Automation**: `test-data-url.sh` - Run everything automatically

## Bottom Line

You **already have Redoc** integrated through the `build-docs` command. The test script and documentation provided make it easy to verify that the data URL feature works correctly with Redoc rendering.

**Just run**: `./test-data-url.sh` on the `copilot/fix-data-url` branch! 🎉
