# Grafana DXT Extension

A Desktop Extension (DXT) that integrates Grafana MCP server, providing access to Grafana dashboards, datasources, alerts, and other Grafana resources through the Model Context Protocol (MCP).

## Overview

This extension packages the official Grafana MCP server as a cross-platform DXT extension, enabling seamless integration with Grafana instances for monitoring, observability, and data visualization tasks.

## Configuration

The extension requires configuration of your Grafana instance connection details:

### Required Settings

1. **Grafana URL** (`grafana_url`)
   - The URL of your Grafana instance
   - Default: `http://localhost:3000`
   - Examples: 
     - Local: `http://localhost:3000`
     - Cloud: `https://myinstance.grafana.net`

2. **Grafana Service Account Token** (`grafana_service_account_token`)
   - Service account token for authentication
   - Required for API access
   - Marked as sensitive for secure handling
   - Create a service account in Grafana with appropriate permissions

### Setting Up Grafana Authentication

1. In your Grafana instance, navigate to **Configuration → Service accounts**
2. Create a new service account with appropriate permissions
3. Generate a new token for the service account
4. Copy the token and use it in the extension configuration

## Building from Source

### Prerequisites
- Make (GNU Make)
- curl
- jq (optional, for JSON manipulation)
- dxt CLI tool

### Quick Start

```bash
# Update to latest Grafana MCP server version
make update-latest

# Build complete package (clean, download all platforms, package)
make

# Or use specific targets:
make download              # Download for current platform
make download-all-platforms # Download for all platforms
make package              # Create DXT package
make validate             # Validate manifest
```

### Makefile Targets

**Main Targets:**
- `make` - Complete build pipeline (uses VERSION file)
- `make build` / `make dist` - Aliases for complete build
- `make package` - Create DXT package from current state

**Download Targets:**
- `make download` - Download for current platform
- `make download-all-platforms` - Download all platform binaries
- `make download-darwin` - Download macOS binary
- `make download-linux` - Download Linux binary
- `make download-windows` - Download Windows binary

**Utility Targets:**
- `make validate` - Validate extension manifest
- `make update-latest` - Update to latest Grafana MCP version
- `make sync-version` - Sync manifest with VERSION file
- `make clean` - Clean build artifacts (preserves VERSION)
- `make version` - Show current version
- `make info` - Show platform information
- `make help` - Show all available targets

## Project Structure

```
grafana-dxt/
├── manifest.json          # DXT extension manifest
├── VERSION               # Version tracking file
├── Makefile             # Build automation
├── CLAUDE.md            # This file
├── server/              # Platform binaries
│   ├── mcp-grafana-darwin      # macOS binary
│   ├── mcp-grafana-linux       # Linux binary
│   └── mcp-grafana-windows.exe # Windows binary
└── dist/                # Build output
    └── grafana-dxt-*.dxt       # Packaged extension
```

## Features

The Grafana MCP server provides access to:

- **Dashboard Management** - Search, view, and manage dashboards
- **Datasource Queries** - Query Prometheus, Loki, and other datasources
- **Alerting** - Manage alerts and notification channels
- **Incidents & OnCall** - Handle incidents and on-call schedules
- **Navigation** - Generate deep links to Grafana resources

## Supported Platforms

- macOS (Darwin) - Intel and Apple Silicon
- Linux - x86_64
- Windows - x86_64

## Version Management

The extension uses a predictable versioning system:
- Version is tracked in the `VERSION` file
- Build process uses the version from this file
- Use `make update-latest` to explicitly update to the latest version
- This ensures reproducible builds

## Troubleshooting

### Authentication Issues
- Ensure your service account token has the necessary permissions
- Verify the Grafana URL is correct and accessible
- Check that the service account is active and not expired

### Build Issues
- Run `make clean` to remove old artifacts
- Ensure you have all prerequisites installed
- Use `make validate` to check manifest validity

## License

Apache-2.0 License - See LICENSE file for details

## Resources

- [Grafana MCP Server](https://github.com/grafana/mcp-grafana)
- [Desktop Extensions Documentation](https://www.desktopextensions.com/#documentation)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Grafana Documentation](https://grafana.com/docs/)