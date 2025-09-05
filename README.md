# Grafana DXT

Connect to Grafana from your desktop. This is a Desktop Extension (DXT) that packages the official Grafana MCP server.

## What it does

Gives you access to your Grafana instance - dashboards, alerts, datasources, the whole thing - right from your desktop app.

## Quick Setup

1. **Get your Grafana credentials:**
   - Go to your Grafana instance
   - Create a service account (Configuration → Service accounts)
   - Generate a token
   - Keep it somewhere safe

2. **Install the extension:**
   - Download the latest `.dxt` file from releases
   - Install it in your DXT-compatible app
   - Enter your Grafana URL and token when prompted

3. **That's it.** You're connected.

## Building from source

Got Make? Good. Here's all you need:

```bash
# Get latest version and build everything
make update-latest
make

# Output will be in dist/grafana-dxt-*.dxt
```

Want more control?

```bash
make download              # Just get binaries for your platform
make download-all-platforms # Get everything
make package              # Package what you have
make clean                # Start fresh (keeps version file)
```

## Configuration

The extension needs two things:

- **Grafana URL**: Where your Grafana lives (like `https://mycompany.grafana.net`)
- **Service Account Token**: The key to get in

Both get configured through the extension UI. No messing with environment variables.

## Supported Platforms

- macOS (Intel & Apple Silicon)
- Linux (x86_64)
- Windows (x86_64)

## Troubleshooting

**Can't connect?**
- Check your Grafana URL is right
- Make sure your token hasn't expired
- Verify the service account has the permissions you need

**Build failing?**
- Run `make clean` and try again
- Check you have `curl` and `make` installed
- Run `make validate` to check the manifest

## Project Structure

```
grafana-dxt/
├── Makefile              # Build automation
├── manifest.json         # Extension config
├── VERSION              # Current version
├── server/              # Grafana binaries (after build)
└── dist/                # Built packages
```

## Development

The Makefile handles everything:
- Downloads the right Grafana MCP server version
- Manages cross-platform binaries
- Packages everything into a `.dxt` file

Version is controlled through the `VERSION` file. The build uses whatever's in there, so builds are predictable. Run `make update-latest` when you want to bump to the newest Grafana MCP server.

## License

Apache-2.0 - Same as the Grafana MCP server we're packaging.

## Links

- [Grafana MCP Server](https://github.com/grafana/mcp-grafana) - The thing we're packaging
- [Desktop Extensions](https://www.desktopextensions.com) - The DXT ecosystem
- [Grafana](https://grafana.com) - You know what this is

---

Built with the Grafana MCP server. We just make it easier to use on desktop.