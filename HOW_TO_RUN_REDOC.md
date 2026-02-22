# How to Run Redoc Against copilot/fix-data-url Code

This document directly answers the question: "How can I run https://github.com/Redocly/redoc against code from copilot/fix-data-url of this repo?"

## Quick Answer

Redoc is already integrated into this repository via the `build-docs` command. Here's the fastest way to test it:

```bash
# 1. Checkout the branch with data URL support
git checkout copilot/fix-data-url

# 2. Install and build
npm install
npm run compile

# 3. Run the quick test script
./test-data-url.sh
```

The script will:

- ✅ Build the project with data URL support
- ✅ Lint a test OpenAPI spec that uses data URLs
- ✅ Generate Redoc documentation (`redoc-static.html`)
- ✅ Show you how to view the results

## What is Redoc?

[Redoc](https://github.com/Redocly/redoc) is an open-source tool for generating beautiful API documentation from OpenAPI specifications. It's already built into Redocly CLI as part of the `build-docs` command.

## What does copilot/fix-data-url add?

The `copilot/fix-data-url` branch adds support for [RFC 2397 data URLs](https://datatracker.ietf.org/doc/html/rfc2397) in OpenAPI `$ref` fields. This means you can embed schemas directly as base64 or URL-encoded data:

**Before (traditional approach):**

```yaml
schema:
  $ref: './schemas/user.json'  # External file
```

**After (with data URL support):**

```yaml
schema:
  $ref: 'data:application/json;base64,eyJ0eXBlIjoib2JqZWN0In0='  # Embedded directly
```

## Step-by-Step Manual Process

If you prefer to run commands manually instead of using the script:

### 1. Setup

```bash
cd /path/to/redocly-cli
git fetch origin copilot/fix-data-url
git checkout copilot/fix-data-url
npm install
npm run compile
```

### 2. Test with Lint

```bash
npm run cli -- lint test-data-url.yaml
```

### 3. Bundle the spec first (with dereferencing), then Generate Redoc Documentation

Due to how build-docs interacts with data URLs, it's recommended to bundle with dereferencing first:

```bash
# Bundle with dereferencing to fully resolve data URLs
npm run cli -- bundle test-data-url.yaml --dereferenced -o bundled.yaml

# Then build docs from the bundled file
npm run cli -- build-docs bundled.yaml
```

This generates `redoc-static.html` which you can open in any browser.

**Note**: The `--dereferenced` flag ensures all references (including data URLs) are fully inlined, avoiding issues with component naming in the documentation build process.

### 4. View the Documentation

```bash
# Open directly in browser
open redoc-static.html  # macOS
xdg-open redoc-static.html  # Linux
start redoc-static.html  # Windows

# Or use a local server
npx http-server -p 8080
# Then visit http://localhost:8080/redoc-static.html
```

## What to Look For

When viewing the generated Redoc documentation, verify:

1. **No Reference Errors**: All `$ref` fields pointing to data URLs are resolved
2. **Schema Display**: The embedded schemas appear correctly in the documentation
3. **Three Endpoints**:
   - `/users` - Uses base64-encoded data URL
   - `/products` - Uses URL-encoded data URL
   - `/orders` - Uses simple data URL

## Understanding the build-docs Command

The `build-docs` command:

1. Reads your OpenAPI specification
2. Resolves all `$ref` references (including the new data URL support)
3. Bundles everything together
4. Uses Redoc to render beautiful HTML documentation
5. Outputs a standalone HTML file

## Alternative: Preview Mode

For live-reload during development:

```bash
npm run cli -- preview-docs test-data-url.yaml
```

This starts a development server with hot-reload.

## Troubleshooting

**Build fails with TypeScript errors:**

```bash
npm run clear
npm install
npm run compile
```

**"data:" URLs not recognized:**

- Make sure you're on the `copilot/fix-data-url` branch
- Run `git log --oneline -5` to verify you see commits about data URL support

**Node version issues:**

- Requires Node.js >= 22.12.0 or >= 20.19.0
- Check with: `node --version`

## Running Tests

To verify the data URL implementation works correctly:

```bash
# All tests
npm run test

# Just unit tests
npm run unit

# Just the resolve tests (where data URL logic lives)
npm run unit -- packages/core/src/__tests__/resolve.test.ts
```

## Further Documentation

- [TESTING_DATA_URL.md](./TESTING_DATA_URL.md) - Comprehensive testing guide
- [test-data-url.yaml](./test-data-url.yaml) - Example OpenAPI spec with data URLs
- [Redoc Documentation](https://redocly.com/docs/cli/commands/build-docs)
- [RFC 2397](https://datatracker.ietf.org/doc/html/rfc2397) - Data URL specification

## Summary

You don't need to do anything special to "run Redoc" - it's already integrated! Just:

1. Checkout `copilot/fix-data-url`
2. Build the project
3. Use `lint` to validate specs with data URLs
4. Use `bundle` to resolve data URLs into a single file
5. Use `build-docs` on the bundled spec to generate Redoc HTML
6. Open the generated HTML

The provided `test-data-url.yaml` file demonstrates the new data URL feature, and the `test-data-url.sh` script automates the entire testing process.
