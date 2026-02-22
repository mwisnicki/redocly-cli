# Testing Redoc with Data URL Support

This guide explains how to run Redoc against the code from the `copilot/fix-data-url` branch to test the new data URL (RFC 2397) support feature.

## What's in copilot/fix-data-url?

The `copilot/fix-data-url` branch adds support for data URLs in OpenAPI `$ref` fields. This allows you to embed schemas and other content directly as base64-encoded or URL-encoded data instead of requiring external files or URLs.

### Changes Made:

- Modified `packages/core/src/ref-utils.ts` to recognize `data:` URLs as absolute URLs
- Added `parseDataUrl()` method in `packages/core/src/resolve.ts` to parse RFC 2397 data URLs
- Added support for both base64-encoded and URL-encoded data URLs
- Added comprehensive tests for the new functionality

## Prerequisites

- Node.js >= 22.12.0 or >= 20.19.0 (check with `node --version`)
- npm >= 11 (check with `npm --version`)

## Step-by-Step Testing Instructions

### 1. Checkout the fix-data-url branch

```bash
cd /path/to/redocly-cli
git fetch origin copilot/fix-data-url
git checkout copilot/fix-data-url
```

### 2. Install dependencies and build

```bash
npm install
npm run compile
```

This will:

- Install all dependencies
- Compile TypeScript to JavaScript
- Generate necessary parsers
- Copy required assets

### 3. Create a test OpenAPI spec with data URLs

Create a file named `test-data-url.yaml` with the following content:

```yaml
openapi: 3.0.0
info:
  title: Data URL Test API
  version: 1.0.0
  description: API demonstrating data URL support in references

paths:
  /users:
    get:
      summary: Get all users
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: 'data:application/json;base64,ewogICJ0eXBlIjogIm9iamVjdCIsCiAgInByb3BlcnRpZXMiOiB7CiAgICAiaWQiOiB7CiAgICAgICJ0eXBlIjogInN0cmluZyIKICAgIH0sCiAgICAibmFtZSI6IHsKICAgICAgInR5cGUiOiAic3RyaW5nIgogICAgfSwKICAgICJlbWFpbCI6IHsKICAgICAgInR5cGUiOiAic3RyaW5nIiwKICAgICAgImZvcm1hdCI6ICJlbWFpbCIKICAgIH0KICB9Cn0='

  /products:
    get:
      summary: Get all products
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: 'data:application/json,%7B%22type%22%3A%22object%22%2C%22properties%22%3A%7B%22id%22%3A%7B%22type%22%3A%22string%22%7D%2C%22name%22%3A%7B%22type%22%3A%22string%22%7D%2C%22price%22%3A%7B%22type%22%3A%22number%22%7D%7D%7D'
```

**Note:** The base64 string decodes to:

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "string"
    },
    "name": {
      "type": "string"
    },
    "email": {
      "type": "string",
      "format": "email"
    }
  }
}
```

The URL-encoded string decodes to:

```json
{"type":"object","properties":{"id":{"type":"string"},"name":{"type":"string"},"price":{"type":"number"}}}
```

### 4. Test with the CLI

First, validate the OpenAPI spec with lint:

```bash
npm run cli -- lint test-data-url.yaml
```

This should successfully lint the file and resolve the data URL references.

### 5. Generate Redoc documentation

Now generate the HTML documentation using Redoc. First bundle with dereferencing, then build docs:

```bash
# Bundle with dereferencing to fully resolve data URLs
npm run cli -- bundle test-data-url.yaml --dereferenced -o bundled.yaml

# Generate Redoc HTML from bundled spec
npm run cli -- build-docs bundled.yaml
```

This will:

- Bundle the OpenAPI spec and fully resolve all `$ref` including data URLs
- Generate a standalone HTML file (`redoc-static.html`) using Redoc

**Why --dereferenced?** The `--dereferenced` flag inlines all references completely, which ensures data URLs are fully resolved and avoids component naming issues in the Redoc build process.

### 6. View the generated documentation

Open the generated file in a browser:

```bash
# On Linux
xdg-open redoc-static.html

# On macOS
open redoc-static.html

# On Windows
start redoc-static.html

# Or use a simple HTTP server
npx http-server -p 8080
# Then open http://localhost:8080/redoc-static.html
```

### 7. Verify the feature works

In the Redoc documentation, you should see:

- The `/users` endpoint with the schema properly resolved from the base64 data URL
- The `/products` endpoint with the schema properly resolved from the URL-encoded data URL
- All schema properties (id, name, email, price) displayed correctly
- No errors or warnings about unresolved references

## Running Tests

To run the test suite that validates data URL functionality:

```bash
# Run all unit tests
npm run unit

# Run specific tests for resolve functionality
npm run unit -- packages/core/src/__tests__/resolve.test.ts
```

## Advanced Usage

### Bundle the spec

You can also bundle the spec to see how data URLs are handled:

```bash
npm run cli -- bundle test-data-url.yaml -o bundled.yaml
```

The bundled output should show the schemas inlined from the data URLs.

### Preview with the preview command

If using Redocly's preview features:

```bash
npm run cli -- preview-docs test-data-url.yaml
```

This starts a development server where you can see live updates.

## Troubleshooting

### Build errors

If you encounter compilation errors:

```bash
npm run clear
npm install
npm run compile
```

### Node version issues

Make sure you're using Node.js 22.12.0+ or 20.19.0+:

```bash
nvm use 22
# or
nvm use 20
```

### Data URL format issues

Data URLs must follow RFC 2397 format:

- `data:[<mediatype>][;base64],<data>`
- The data part cannot be empty
- Base64 data must be valid
- URL-encoded data must use proper percent encoding

## Understanding the Implementation

The implementation adds:

1. **URL Recognition** (`ref-utils.ts`): The `isAbsoluteUrl()` function now recognizes `data:` URLs
2. **Data URL Parsing** (`resolve.ts`): New `parseDataUrl()` method that:
   - Validates the data URL format
   - Detects base64 vs URL-encoded content
   - Decodes the content appropriately
   - Returns the decoded content with optional MIME type
3. **Resolution** (`resolve.ts`): The `loadExternalRef()` method now handles data URLs before attempting HTTP/file loading

## Additional Examples

### Embedding JSON Schema

```yaml
$ref: 'data:application/json;base64,<base64-encoded-schema>'
```

### Embedding YAML (URL-encoded)

```yaml
$ref: 'data:text/yaml,type%3A%20object%0Aproperties%3A%0A%20%20id%3A%0A%20%20%20%20type%3A%20string'
```

### Embedding without MIME type

```yaml
$ref: 'data:,{"type":"string"}'
```

## Next Steps

Once you've verified the functionality works:

1. The changes can be merged to the main branch
2. A new version can be published to npm
3. Users can start using data URLs in their OpenAPI specifications

## Related Resources

- [RFC 2397 - The "data" URL scheme](https://datatracker.ietf.org/doc/html/rfc2397)
- [Redoc Documentation](https://redocly.com/docs/cli/commands/build-docs)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
