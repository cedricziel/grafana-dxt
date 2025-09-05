# Grafana DXT Makefile
# Downloads the latest Grafana MCP server and manages versioning

# Variables
GITHUB_API_URL := https://api.github.com/repos/grafana/mcp-grafana/releases/latest
SERVER_DIR := server
BINARY_NAME := mcp-grafana
VERSION_FILE := VERSION

# Platform detection
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Map platform names to Grafana release names
ifeq ($(UNAME_S),Darwin)
	OS := Darwin
else ifeq ($(UNAME_S),Linux)
	OS := Linux
else
	$(error Unsupported operating system: $(UNAME_S))
endif

ifeq ($(UNAME_M),x86_64)
	ARCH := x86_64
else ifeq ($(UNAME_M),amd64)
	ARCH := x86_64
else ifeq ($(UNAME_M),arm64)
	ARCH := arm64
else ifeq ($(UNAME_M),aarch64)
	ARCH := arm64
else
	$(error Unsupported architecture: $(UNAME_M))
endif

# Build the download filename
DOWNLOAD_FILE := $(BINARY_NAME)_$(OS)_$(ARCH).tar.gz

# Default target
.PHONY: all
all: download update-version
	@echo "✅ Successfully downloaded and configured Grafana MCP server"

# Get the latest version from GitHub
.PHONY: get-latest-version
get-latest-version:
	@echo "🔍 Fetching latest version from GitHub..."
	$(eval LATEST_VERSION := $(shell curl -s $(GITHUB_API_URL) | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'))
	@if [ -z "$(LATEST_VERSION)" ]; then \
		echo "❌ Failed to fetch latest version from GitHub"; \
		exit 1; \
	fi
	@echo "📦 Latest version: $(LATEST_VERSION)"

# Download the latest Grafana MCP server
.PHONY: download
download: get-latest-version
	@echo "⬇️  Downloading Grafana MCP server $(LATEST_VERSION) for $(OS) $(ARCH)..."
	@mkdir -p $(SERVER_DIR)
	$(eval DOWNLOAD_URL := https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(DOWNLOAD_FILE))
	@curl -L -o /tmp/$(DOWNLOAD_FILE) $(DOWNLOAD_URL)
	@echo "📂 Extracting to $(SERVER_DIR)..."
	@tar -xzf /tmp/$(DOWNLOAD_FILE) -C $(SERVER_DIR)
	@rm /tmp/$(DOWNLOAD_FILE)
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)
	@echo "✅ Downloaded $(BINARY_NAME) $(LATEST_VERSION)"

# Update version in manifest.json and VERSION file
.PHONY: update-version
update-version: get-latest-version
	@echo "📝 Updating version to $(LATEST_VERSION)..."
	@echo $(LATEST_VERSION) > $(VERSION_FILE)
	@if command -v jq >/dev/null 2>&1; then \
		jq '.version = "$(LATEST_VERSION)"' manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json; \
		echo "✅ Updated manifest.json using jq"; \
	else \
		sed -i.bak 's/"version": *"[^"]*"/"version": "$(LATEST_VERSION)"/' manifest.json && rm manifest.json.bak; \
		echo "✅ Updated manifest.json using sed"; \
	fi
	@echo "✅ Version updated to $(LATEST_VERSION)"

# Update manifest to use binary instead of Node.js script
.PHONY: update-manifest-binary
update-manifest-binary:
	@echo "🔧 Updating manifest.json to use binary executable..."
	@if command -v jq >/dev/null 2>&1; then \
		jq '.server.entry_point = "server/mcp-grafana" | .server.mcp_config.command = "$${__dirname}/server/mcp-grafana" | .server.mcp_config.args = []' manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json; \
	else \
		echo "⚠️  Please manually update manifest.json to use the binary"; \
		echo "   Set server.entry_point to: server/mcp-grafana"; \
		echo "   Set server.mcp_config.command to: \$${__dirname}/server/mcp-grafana"; \
		echo "   Set server.mcp_config.args to: []"; \
	fi

# Clean downloaded files
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	@rm -rf $(SERVER_DIR)/$(BINARY_NAME)
	@rm -f $(VERSION_FILE)
	@echo "✅ Cleaned up"

# Show current version
.PHONY: version
version:
	@if [ -f $(VERSION_FILE) ]; then \
		echo "Current version: $$(cat $(VERSION_FILE))"; \
	else \
		echo "No version file found. Run 'make download' to get started."; \
	fi

# Show platform information
.PHONY: info
info:
	@echo "Platform Information:"
	@echo "  OS: $(OS)"
	@echo "  Architecture: $(ARCH)"
	@echo "  Download file: $(DOWNLOAD_FILE)"
	@echo ""
	@if [ -f $(VERSION_FILE) ]; then \
		echo "Current version: $$(cat $(VERSION_FILE))"; \
	else \
		echo "No version installed yet"; \
	fi

# Help target
.PHONY: help
help:
	@echo "Grafana DXT Makefile - Available targets:"
	@echo ""
	@echo "  make all              - Download latest version and update configs (default)"
	@echo "  make download         - Download the latest Grafana MCP server binary"
	@echo "  make update-version   - Update version in manifest.json and VERSION file"
	@echo "  make update-manifest-binary - Update manifest.json to use binary executable"
	@echo "  make clean            - Remove downloaded binary and VERSION file"
	@echo "  make version          - Show current installed version"
	@echo "  make info             - Show platform and version information"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Platform: $(OS) $(ARCH)"