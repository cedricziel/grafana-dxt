# Grafana DXT Extension

This is a Desktop Extension (DXT) for integrating with Grafana services.

## Project Structure

- `manifest.json` - DXT extension manifest file defining the extension configuration
- `server/index.js` - Main server entry point for the MCP (Model Context Protocol) server

## Development Setup

### Prerequisites
- Node.js (version 18 or higher recommended)
- npm or yarn package manager

### Installation
```bash
npm install
```

### Running the Extension
The extension runs as an MCP server and is configured through the manifest.json file.

## Extension Configuration

This extension is configured to run as a Node.js MCP server as defined in the manifest:
- Entry point: `server/index.js`
- Runtime: Node.js
- Protocol: MCP (Model Context Protocol)

## Testing

To test the extension locally:
```bash
node server/index.js
```

## Building and Packaging

Follow the DXT documentation for packaging and distribution guidelines:
https://www.desktopextensions.com/#documentation

## License

MIT License - See LICENSE file for details