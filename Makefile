# Grafana DXT Makefile
# Downloads the latest Grafana MCP server and manages versioning

# Variables
GITHUB_API_URL := https://api.github.com/repos/grafana/mcp-grafana/releases/latest
SERVER_DIR := server
BINARY_NAME := mcp-grafana
VERSION_FILE := VERSION
OUTPUT_DIR := dist

# Read version from VERSION file
CURRENT_VERSION := $(shell cat $(VERSION_FILE) 2>/dev/null || echo "v0.6.4")

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
	@echo "📦 Package created: grafana-dxt-$(CURRENT_VERSION).dxt"

# Build target (alias for all)
.PHONY: build
build: all

# Dist target (alias for all)
.PHONY: dist
dist: all

# Get the current version from VERSION file
.PHONY: get-version
get-version:
	@echo "📦 Using version: $(CURRENT_VERSION)"

# Fetch and update to the latest version from GitHub
.PHONY: update-latest
update-latest:
	@echo "🔍 Fetching latest version from GitHub..."
	$(eval LATEST_VERSION := $(shell curl -s $(GITHUB_API_URL) | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'))
	@if [ -z "$(LATEST_VERSION)" ]; then \
		echo "❌ Failed to fetch latest version from GitHub"; \
		exit 1; \
	fi
	@echo "📦 Latest version: $(LATEST_VERSION)"
	@echo "📝 Updating VERSION file to $(LATEST_VERSION)..."
	@echo $(LATEST_VERSION) > $(VERSION_FILE)
	@if command -v jq >/dev/null 2>&1; then \
		jq '.version = "$(LATEST_VERSION)"' manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json; \
	else \
		sed -i.bak 's/"version": *"[^"]*"/"version": "$(LATEST_VERSION)"/' manifest.json && rm manifest.json.bak; \
	fi
	@echo "✅ Updated to version $(LATEST_VERSION)"

# Download the Grafana MCP server for current platform
.PHONY: download
download:
	@echo "⬇️  Downloading Grafana MCP server $(CURRENT_VERSION) for $(OS) $(ARCH)..."
	@mkdir -p $(SERVER_DIR)
	$(eval DOWNLOAD_URL := https://github.com/grafana/mcp-grafana/releases/download/$(CURRENT_VERSION)/$(DOWNLOAD_FILE))
	@curl -L -o /tmp/$(DOWNLOAD_FILE) $(DOWNLOAD_URL)
	@echo "📂 Extracting to $(SERVER_DIR)..."
	@tar -xzf /tmp/$(DOWNLOAD_FILE) -C $(SERVER_DIR)
	@rm /tmp/$(DOWNLOAD_FILE)
	@mv $(SERVER_DIR)/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-$(PLATFORM)
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-$(PLATFORM)
	@echo "✅ Downloaded $(BINARY_NAME)-$(PLATFORM) $(CURRENT_VERSION)"

# Download binaries for all platforms
.PHONY: download-all-platforms
download-all-platforms: download-darwin download-linux download-windows
	@echo "✅ Downloaded binaries for all platforms"

# Download Darwin binary (auto-detect architecture)
.PHONY: download-darwin
download-darwin:
	@echo "⬇️  Downloading Darwin $(ARCH) binary ($(CURRENT_VERSION))..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(CURRENT_VERSION)/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-darwin
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-darwin
	@rm /tmp/$(BINARY_NAME)_Darwin_$(ARCH).tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Darwin $(ARCH)"

# Download Linux binary (x86_64 by default as most common)
.PHONY: download-linux
download-linux:
	@echo "⬇️  Downloading Linux x86_64 binary ($(CURRENT_VERSION))..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(CURRENT_VERSION)/$(BINARY_NAME)_Linux_x86_64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-linux
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-linux
	@rm /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Linux x86_64"

# Download Windows binary (x86_64)
.PHONY: download-windows
download-windows:
	@echo "⬇️  Downloading Windows x86_64 binary ($(CURRENT_VERSION))..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Windows_x86_64.zip \
		https://github.com/grafana/mcp-grafana/releases/download/$(CURRENT_VERSION)/$(BINARY_NAME)_Windows_x86_64.zip
	@unzip -q -o /tmp/$(BINARY_NAME)_Windows_x86_64.zip -d /tmp
	@mv /tmp/$(BINARY_NAME).exe $(SERVER_DIR)/$(BINARY_NAME)-windows.exe
	@rm /tmp/$(BINARY_NAME)_Windows_x86_64.zip
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Windows x86_64"

# Note: Additional architecture-specific targets can be added if needed
# For now, we download: Darwin (current arch), Linux (x86_64), Windows (x86_64)

# Sync manifest.json version with VERSION file
.PHONY: sync-version
sync-version:
	@echo "📝 Syncing manifest.json with version $(CURRENT_VERSION)..."
	@if command -v jq >/dev/null 2>&1; then \
		jq '.version = "$(CURRENT_VERSION)"' manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json; \
		echo "✅ Updated manifest.json using jq"; \
	else \
		sed -i.bak 's/"version": *"[^"]*"/"version": "$(CURRENT_VERSION)"/' manifest.json && rm manifest.json.bak; \
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
package: sync-version validate
	@echo "📦 Packaging extension version $(CURRENT_VERSION)..."
	@mkdir -p $(OUTPUT_DIR)
	@dxt pack . $(OUTPUT_DIR)/grafana-dxt-$(CURRENT_VERSION).dxt
	@echo "✅ Package created: $(OUTPUT_DIR)/grafana-dxt-$(CURRENT_VERSION).dxt"
	@ls -lh $(OUTPUT_DIR)/grafana-dxt-$(CURRENT_VERSION).dxt

# Clean downloaded files and dist directory (preserves VERSION file)
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	@rm -f $(SERVER_DIR)/$(BINARY_NAME)-*
	@rm -rf $(OUTPUT_DIR)
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
	@echo "  Platform: $(PLATFORM)"
	@echo "  Architecture: $(ARCH)"
	@echo "  Download file: $(DOWNLOAD_FILE)"
	@echo ""
	@if [ -f $(VERSION_FILE) ]; then \
		echo "Current version: $$(cat $(VERSION_FILE))"; \
	else \
		echo "No version installed yet"; \
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
	@echo "  make                         - Build pipeline: clean, download all, package (uses VERSION file)"
	@echo "  make build                   - Alias for 'make all'"
	@echo "  make dist                    - Alias for 'make all'"
	@echo "  make package                 - Create DXT package from current state"
	@echo ""
	@echo "📦 Download Targets (uses version from VERSION file):"
	@echo "  make download                - Download Grafana MCP server for current platform"
	@echo "  make download-all-platforms  - Download binaries for all supported platforms"
	@echo "  make download-darwin          - Download Darwin binary (auto-detects architecture)"
	@echo "  make download-linux           - Download Linux x86_64 binary"
	@echo "  make download-windows         - Download Windows x86_64 binary"
	@echo ""
	@echo "🔧 Utility Targets:"
	@echo "  make validate                - Validate extension manifest and structure"
	@echo "  make update-latest           - Update VERSION file to latest GitHub release"
	@echo "  make sync-version            - Sync manifest.json with VERSION file"
	@echo "  make clean                   - Remove downloaded binaries and dist (preserves VERSION)"
	@echo "  make version                 - Show current installed version"
	@echo "  make info                    - Show platform and version information"
	@echo "  make help                    - Show this help message"
	@echo ""
	@echo "Current Platform: $(OS) $(ARCH)"