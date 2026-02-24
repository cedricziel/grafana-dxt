# Grafana DXT Makefile
# Downloads the latest Grafana MCP server and manages versioning

# Variables
GITHUB_API_URL := https://api.github.com/repos/grafana/mcp-grafana/releases/latest
SERVER_DIR := server
BINARY_NAME := mcp-grafana
UPSTREAM_VERSION_FILE := UPSTREAM_VERSION
OUTPUT_DIR := dist

# Upstream mcp-grafana server version (used for downloading binaries)
UPSTREAM_VERSION := $(shell cat $(UPSTREAM_VERSION_FILE) 2>/dev/null || echo "v0.6.4")

# DXT extension version (read from manifest.json)
DXT_VERSION := $(shell grep -o '"version": *"[^"]*"' manifest.json | head -1 | sed 's/"version": *"//;s/"//')

# Platform detection
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Map platform names to Grafana release names
ifeq ($(UNAME_S),Darwin)
	OS := Darwin
	PLATFORM := darwin
else ifeq ($(UNAME_S),Linux)
	OS := Linux
	PLATFORM := linux
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

# Default target - complete build pipeline
.PHONY: all
all: clean download-all-platforms package
	@echo "✅ Successfully built and packaged Grafana DXT extension!"
	@echo "📦 DXT v$(DXT_VERSION) with mcp-grafana $(UPSTREAM_VERSION)"

# Build target (alias for all)
.PHONY: build
build: all

# Dist target (alias for all)
.PHONY: dist
dist: all

# Get the current versions
.PHONY: get-version
get-version:
	@echo "📦 DXT extension version: $(DXT_VERSION)"
	@echo "📦 Upstream mcp-grafana version: $(UPSTREAM_VERSION)"

# Fetch and update to the latest upstream mcp-grafana version from GitHub
.PHONY: update-latest
update-latest:
	@echo "🔍 Fetching latest mcp-grafana version from GitHub..."
	$(eval LATEST_VERSION := $(shell curl -s $(GITHUB_API_URL) | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'))
	@if [ -z "$(LATEST_VERSION)" ]; then \
		echo "❌ Failed to fetch latest version from GitHub"; \
		exit 1; \
	fi
	@echo "📦 Latest upstream version: $(LATEST_VERSION)"
	@echo "📝 Updating UPSTREAM_VERSION file to $(LATEST_VERSION)..."
	@echo $(LATEST_VERSION) > $(UPSTREAM_VERSION_FILE)
	@echo "✅ Updated upstream mcp-grafana to $(LATEST_VERSION)"
	@echo "ℹ️  DXT extension version ($(DXT_VERSION)) is unchanged — update manifest.json to bump it"

# Download the Grafana MCP server for current platform
.PHONY: download
download:
	@echo "⬇️  Downloading Grafana MCP server $(UPSTREAM_VERSION) for $(OS) $(ARCH)..."
	@mkdir -p $(SERVER_DIR)
	$(eval DOWNLOAD_URL := https://github.com/grafana/mcp-grafana/releases/download/$(UPSTREAM_VERSION)/$(DOWNLOAD_FILE))
	@curl -L -o /tmp/$(DOWNLOAD_FILE) $(DOWNLOAD_URL)
	@echo "📂 Extracting to $(SERVER_DIR)..."
	@tar -xzf /tmp/$(DOWNLOAD_FILE) -C $(SERVER_DIR)
	@rm /tmp/$(DOWNLOAD_FILE)
	@mv $(SERVER_DIR)/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-$(PLATFORM)
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-$(PLATFORM)
	@echo "✅ Downloaded $(BINARY_NAME)-$(PLATFORM) $(UPSTREAM_VERSION)"

# Download binaries for all platforms
.PHONY: download-all-platforms
download-all-platforms: download-darwin download-linux download-windows
	@echo "✅ Downloaded binaries for all platforms"

# Download Darwin binary (auto-detect architecture)
.PHONY: download-darwin
download-darwin:
	@echo "⬇️  Downloading Darwin $(ARCH) binary ($(UPSTREAM_VERSION))..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(UPSTREAM_VERSION)/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-darwin
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-darwin
	@rm /tmp/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Darwin $(ARCH)"

# Download Linux binary (x86_64 by default as most common)
.PHONY: download-linux
download-linux:
	@echo "⬇️  Downloading Linux x86_64 binary ($(UPSTREAM_VERSION))..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(UPSTREAM_VERSION)/$(BINARY_NAME)_Linux_x86_64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-linux
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-linux
	@rm /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Linux x86_64"

# Download Windows binary (x86_64)
.PHONY: download-windows
download-windows:
	@echo "⬇️  Downloading Windows x86_64 binary ($(UPSTREAM_VERSION))..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Windows_x86_64.zip \
		https://github.com/grafana/mcp-grafana/releases/download/$(UPSTREAM_VERSION)/$(BINARY_NAME)_Windows_x86_64.zip
	@unzip -q -o /tmp/$(BINARY_NAME)_Windows_x86_64.zip -d /tmp
	@mv /tmp/$(BINARY_NAME).exe $(SERVER_DIR)/$(BINARY_NAME)-windows.exe
	@rm /tmp/$(BINARY_NAME)_Windows_x86_64.zip
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Windows x86_64"

# Note: Additional architecture-specific targets can be added if needed
# For now, we download: Darwin (current arch), Linux (x86_64), Windows (x86_64)

# Set the DXT extension version in manifest.json (for use in CI or manual bumps)
# Usage: make set-dxt-version DXT_NEW_VERSION=1.2.3
.PHONY: set-dxt-version
set-dxt-version:
	@if [ -z "$(DXT_NEW_VERSION)" ]; then \
		echo "❌ Usage: make set-dxt-version DXT_NEW_VERSION=1.2.3"; \
		exit 1; \
	fi
	@echo "📝 Setting DXT extension version to $(DXT_NEW_VERSION)..."
	@if command -v jq >/dev/null 2>&1; then \
		jq '.version = "$(DXT_NEW_VERSION)"' manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json; \
		echo "✅ Updated manifest.json using jq"; \
	else \
		sed -i.bak 's/"version": *"[^"]*"/"version": "$(DXT_NEW_VERSION)"/' manifest.json && rm manifest.json.bak; \
		echo "✅ Updated manifest.json using sed"; \
	fi

# Validate the extension manifest and structure
.PHONY: validate
validate:
	@echo "🔍 Validating extension manifest..."
	@dxt validate manifest.json
	@echo "✅ Validation passed"

# Package the extension using dxt
.PHONY: package
package: validate
	@echo "📦 Packaging DXT extension $(DXT_VERSION) (mcp-grafana $(UPSTREAM_VERSION))..."
	@mkdir -p $(OUTPUT_DIR)
	@dxt pack . $(OUTPUT_DIR)/grafana-dxt-$(DXT_VERSION).dxt
	@echo "✅ Package created: $(OUTPUT_DIR)/grafana-dxt-$(DXT_VERSION).dxt"
	@ls -lh $(OUTPUT_DIR)/grafana-dxt-$(DXT_VERSION).dxt

# Clean downloaded files and dist directory
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	@rm -f $(SERVER_DIR)/$(BINARY_NAME)-*
	@rm -rf $(OUTPUT_DIR)
	@echo "✅ Cleaned up"

# Show current versions
.PHONY: version
version:
	@echo "DXT extension version: $(DXT_VERSION) (from manifest.json)"
	@if [ -f $(UPSTREAM_VERSION_FILE) ]; then \
		echo "Upstream mcp-grafana version: $$(cat $(UPSTREAM_VERSION_FILE))"; \
	else \
		echo "No UPSTREAM_VERSION file found. Run 'make update-latest' to get started."; \
	fi

# Show platform information
.PHONY: info
info:
	@echo "Platform Information:"
	@echo "  OS: $(OS)"
	@echo "  Platform: $(PLATFORM)"
	@echo "  Architecture: $(ARCH)"
	@echo "  Download file: $(DOWNLOAD_FILE)"
	@echo ""
	@echo "  DXT version: $(DXT_VERSION)"
	@if [ -f $(UPSTREAM_VERSION_FILE) ]; then \
		echo "  Upstream mcp-grafana: $$(cat $(UPSTREAM_VERSION_FILE))"; \
	else \
		echo "  Upstream mcp-grafana: not set"; \
	fi
	@echo ""
	@echo "Available binaries in $(SERVER_DIR):"
	@ls -la $(SERVER_DIR)/$(BINARY_NAME)-* 2>/dev/null || echo "  None"

# Help target
.PHONY: help
help:
	@echo "Grafana DXT Makefile - Available targets:"
	@echo ""
	@echo "🚀 Main Targets:"
	@echo "  make                         - Build pipeline: clean, download all, package"
	@echo "  make build                   - Alias for 'make all'"
	@echo "  make dist                    - Alias for 'make all'"
	@echo "  make package                 - Create DXT package from current state"
	@echo ""
	@echo "📦 Download Targets (uses version from UPSTREAM_VERSION file):"
	@echo "  make download                - Download Grafana MCP server for current platform"
	@echo "  make download-all-platforms  - Download binaries for all supported platforms"
	@echo "  make download-darwin          - Download Darwin binary (auto-detects architecture)"
	@echo "  make download-linux           - Download Linux x86_64 binary"
	@echo "  make download-windows         - Download Windows x86_64 binary"
	@echo ""
	@echo "🔧 Utility Targets:"
	@echo "  make validate                - Validate extension manifest and structure"
	@echo "  make update-latest           - Update UPSTREAM_VERSION to latest mcp-grafana release"
	@echo "  make set-dxt-version DXT_NEW_VERSION=x.y.z - Set DXT extension version in manifest"
	@echo "  make clean                   - Remove downloaded binaries and dist"
	@echo "  make version                 - Show current versions (DXT + upstream)"
	@echo "  make info                    - Show platform and version information"
	@echo "  make help                    - Show this help message"
	@echo ""
	@echo "Current Platform: $(OS) $(ARCH)"