# GraphQL Introspection Script

A bash script to query GraphQL endpoints with introspection queries and handle the output flexibly.

📖 **[Understanding the Introspection Query](./INTROSPECTION-QUERY-EXPLAINED.md)** - Line-by-line explanation of what the introspection query does

## Features

- ✅ **Clipboard support** (default) - Automatically copies result to clipboard
- 📄 **File output** - Save introspection to a JSON file
- 🖥️ **Console output** - Print directly to stdout
- 🔐 **Custom headers** - Support for authentication and custom headers
- 🎨 **Color-coded messages** - Clear visual feedback
- 🔍 **Error detection** - Validates responses and reports GraphQL errors

## Prerequisites

### For clipboard functionality:
- **macOS**: `pbcopy` (included by default)
- **Linux**: `xclip` or `xsel`
  ```bash
  # Ubuntu/Debian
  sudo apt-get install xclip
  # or
  sudo apt-get install xsel
  
  # Fedora/RHEL
  sudo dnf install xclip
  ```
- **Windows (WSL)**: `clip.exe` (included with Windows)

### Required tools:
- `curl` (usually pre-installed)
- `bash` (version 4.0+)

## Installation

```bash
# Download the script
curl -O https://example.com/graphql-introspect.sh

# Make it executable
chmod +x graphql-introspect.sh

# Optional: Move to PATH for global access
sudo mv graphql-introspect.sh /usr/local/bin/graphql-introspect
```

## Usage

### Basic Syntax

```bash
./graphql-introspect.sh <endpoint> [options]
```

### Options

| Option | Description |
|--------|-------------|
| `-c, --clipboard` | Copy output to clipboard (default) |
| `-p, --print` | Print output to stdout |
| `-o, --output FILE` | Save output to file |
| `-H, --header HEADER` | Add custom header (can use multiple times) |
| `-h, --help` | Show help message |

## Examples

### 1. Copy to Clipboard (Default)

```bash
./graphql-introspect.sh https://api.example.com/graphql
```

### 2. Print to Console

```bash
./graphql-introspect.sh https://api.example.com/graphql --print
```

### 3. Save to File

```bash
./graphql-introspect.sh https://api.example.com/graphql --output schema.json
```

### 4. With Authentication Header

```bash
./graphql-introspect.sh https://api.example.com/graphql \
  -H "Authorization: Bearer your_token_here"
```

### 5. Multiple Custom Headers

```bash
./graphql-introspect.sh https://api.example.com/graphql \
  -H "Authorization: Bearer token123" \
  -H "X-API-Key: api_key_456" \
  -H "X-Custom-Header: custom_value"
```

### 6. Pretty Print with jq

```bash
./graphql-introspect.sh https://api.example.com/graphql --print | jq '.'
```

### 7. Save and Open in Editor

```bash
./graphql-introspect.sh https://api.example.com/graphql --output schema.json
code schema.json  # or your preferred editor
```

## Common Use Cases

### Using with GraphQL Voyager

1. Copy introspection to clipboard:
```bash
./graphql-introspect.sh https://your-api.com/graphql
```

2. Go to [GraphQL Voyager](https://graphql-kit.com/graphql-voyager/)
3. Click "CHANGE SCHEMA" → "INTROSPECTION"
4. Paste from clipboard

### Using with GraphQL Playground

```bash
# Save introspection
./graphql-introspect.sh https://your-api.com/graphql --output schema.json

# Import in GraphQL Playground
```

### Automated Schema Documentation

```bash
#!/bin/bash
# Daily schema backup
DATE=$(date +%Y-%m-%d)
./graphql-introspect.sh https://api.example.com/graphql \
  --output "schemas/schema-$DATE.json"
```

### CI/CD Integration

```bash
# In your CI pipeline
./graphql-introspect.sh $GRAPHQL_ENDPOINT \
  -H "Authorization: Bearer $API_TOKEN" \
  --output current-schema.json

# Compare with previous schema
diff previous-schema.json current-schema.json
```

## Troubleshooting

### "No clipboard utility found"

**Solution**: Install a clipboard utility for your system:

```bash
# Linux
sudo apt-get install xclip

# Or fallback to file/print output
./graphql-introspect.sh https://api.example.com/graphql --print
```

### "Error: GraphQL query returned errors"

**Common causes:**
1. **Authentication required**: Add authorization header
   ```bash
   ./graphql-introspect.sh https://api.example.com/graphql \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

2. **Introspection disabled**: The API may have disabled introspection
   - Contact the API provider
   - Check API documentation for alternative schema access

3. **CORS issues**: Use a CORS proxy or make the request server-side

### Empty Response

**Check:**
1. Endpoint URL is correct
2. Network connectivity
3. API is running and accessible
4. Try with curl directly:
   ```bash
   curl -v https://api.example.com/graphql
   ```

## Advanced Usage

### Using with Environment Variables

```bash
# Set in your .bashrc or .zshrc
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"
export GRAPHQL_TOKEN="your_token_here"

# Use in script
./graphql-introspect.sh $GRAPHQL_ENDPOINT \
  -H "Authorization: Bearer $GRAPHQL_TOKEN"
```

### Creating an Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias gql-introspect='~/path/to/graphql-introspect.sh'

# Usage
gql-introspect https://api.example.com/graphql
```

### Piping to Other Tools

```bash
# Format with jq
./graphql-introspect.sh https://api.example.com/graphql --print | jq '.'

# Count types
./graphql-introspect.sh https://api.example.com/graphql --print | \
  jq '.data.__schema.types | length'

# Extract type names
./graphql-introspect.sh https://api.example.com/graphql --print | \
  jq -r '.data.__schema.types[].name'
```

## Script Details

### What It Does

1. Validates input parameters
2. Constructs GraphQL introspection query
3. Sends POST request to endpoint with headers
4. Validates response for errors
5. Outputs result based on selected mode

### Introspection Query

The script uses the standard GraphQL introspection query that retrieves:
- All types (objects, interfaces, unions, enums, scalars, input objects)
- All fields with arguments and descriptions
- Directives and their locations
- Deprecation information
- Type relationships

## Security Considerations

⚠️ **Important**: Never commit files containing authentication tokens!

```bash
# Good practices:
1. Use environment variables for tokens
2. Add *.json to .gitignore if saving schemas
3. Use secure methods to pass sensitive headers
4. Consider using API keys instead of bearer tokens when possible
```

## License

MIT License - Feel free to modify and distribute.

## Contributing

Suggestions and improvements welcome! Common enhancements:
- Support for GraphQL subscriptions introspection
- Batch endpoint processing
- Schema diff functionality
- Interactive mode
