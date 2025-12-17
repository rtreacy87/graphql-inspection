#!/bin/bash

# GraphQL Introspection Script
# Usage: ./graphql-introspect.sh <endpoint> [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default behavior
OUTPUT_MODE="clipboard"
OUTPUT_FILE=""
ENDPOINT=""
HEADERS=""

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/introspection-query.json"

# Load introspection query from config file
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Config file not found: $CONFIG_FILE${NC}" >&2
    exit 1
fi

INTROSPECTION_QUERY=$(cat "$CONFIG_FILE")

# Help message
show_help() {
    cat << HELP
GraphQL Introspection Script

Usage: $0 <endpoint> [options]

Arguments:
  endpoint              GraphQL endpoint URL (required)

Options:
  -o, --output FILE     Save output to file
  -p, --print           Print output to stdout
  -c, --clipboard       Copy output to clipboard (default)
  -H, --header HEADER   Add custom header (format: "Key: Value")
                        Can be used multiple times
  -h, --help            Show this help message

Examples:
  # Copy to clipboard (default)
  $0 https://api.example.com/graphql

  # Print to stdout
  $0 https://api.example.com/graphql --print

  # Save to file
  $0 https://api.example.com/graphql --output schema.json

  # With authentication header
  $0 https://api.example.com/graphql -H "Authorization: Bearer token123"

  # Multiple headers
  $0 https://api.example.com/graphql \\
    -H "Authorization: Bearer token123" \\
    -H "X-Custom-Header: value"
HELP
}

# Check if clipboard command is available
check_clipboard_command() {
    if command -v pbcopy &> /dev/null; then
        echo "pbcopy"
    elif command -v xclip &> /dev/null; then
        echo "xclip"
    elif command -v xsel &> /dev/null; then
        echo "xsel"
    elif command -v clip.exe &> /dev/null; then
        echo "clip.exe"
    else
        echo ""
    fi
}

# Copy to clipboard
copy_to_clipboard() {
    local data="$1"
    local clipboard_cmd=$(check_clipboard_command)
    
    if [ -z "$clipboard_cmd" ]; then
        echo -e "${RED}Error: No clipboard utility found.${NC}" >&2
        echo -e "${YELLOW}Please install one of: pbcopy (macOS), xclip, xsel (Linux), or use --print or --output instead.${NC}" >&2
        return 1
    fi
    
    case "$clipboard_cmd" in
        pbcopy)
            echo "$data" | pbcopy
            ;;
        xclip)
            echo "$data" | xclip -selection clipboard
            ;;
        xsel)
            echo "$data" | xsel --clipboard --input
            ;;
        clip.exe)
            echo "$data" | clip.exe
            ;;
    esac
    
    return 0
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

ENDPOINT="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_MODE="file"
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -p|--print)
            OUTPUT_MODE="print"
            shift
            ;;
        -c|--clipboard)
            OUTPUT_MODE="clipboard"
            shift
            ;;
        -H|--header)
            HEADERS="$HEADERS -H \"$2\""
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            show_help
            exit 1
            ;;
    esac
done

# Validate endpoint
if [ -z "$ENDPOINT" ]; then
    echo -e "${RED}Error: Endpoint is required${NC}" >&2
    show_help
    exit 1
fi

# Make the GraphQL request
echo -e "${YELLOW}Querying GraphQL endpoint: $ENDPOINT${NC}" >&2

CURL_CMD="curl -s -X POST \"$ENDPOINT\" \
  -H \"Content-Type: application/json\" \
  $HEADERS \
  -d '$INTROSPECTION_QUERY'"

RESPONSE=$(eval $CURL_CMD)

# Check if response is valid
if [ -z "$RESPONSE" ]; then
    echo -e "${RED}Error: Empty response from endpoint${NC}" >&2
    exit 1
fi

# Check for errors in response
if echo "$RESPONSE" | grep -q '"errors"'; then
    echo -e "${RED}Error: GraphQL query returned errors:${NC}" >&2
    echo "$RESPONSE" | grep -o '"errors":\[.*\]' >&2
    exit 1
fi

# Handle output based on mode
case "$OUTPUT_MODE" in
    clipboard)
        if copy_to_clipboard "$RESPONSE"; then
            echo -e "${GREEN}✓ Introspection result copied to clipboard!${NC}" >&2
        else
            echo -e "${YELLOW}Falling back to printing to stdout:${NC}" >&2
            echo "$RESPONSE"
        fi
        ;;
    print)
        echo "$RESPONSE"
        ;;
    file)
        echo "$RESPONSE" > "$OUTPUT_FILE"
        echo -e "${GREEN}✓ Introspection result saved to: $OUTPUT_FILE${NC}" >&2
        ;;
esac

exit 0
