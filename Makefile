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

# Download the latest Grafana MCP server for current platform
.PHONY: download
download: get-latest-version
	@echo "⬇️  Downloading Grafana MCP server $(LATEST_VERSION) for $(OS) $(ARCH)..."
	@mkdir -p $(SERVER_DIR)
	$(eval DOWNLOAD_URL := https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(DOWNLOAD_FILE))
	@curl -L -o /tmp/$(DOWNLOAD_FILE) $(DOWNLOAD_URL)
	@echo "📂 Extracting to $(SERVER_DIR)..."
	@tar -xzf /tmp/$(DOWNLOAD_FILE) -C $(SERVER_DIR)
	@rm /tmp/$(DOWNLOAD_FILE)
	@mv $(SERVER_DIR)/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-$(PLATFORM)
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-$(PLATFORM)
	@echo "✅ Downloaded $(BINARY_NAME)-$(PLATFORM) $(LATEST_VERSION)"

# Download binaries for all platforms
.PHONY: download-all-platforms
download-all-platforms: get-latest-version download-darwin-x86_64 download-darwin-arm64 download-linux-x86_64 download-linux-arm64 download-windows-x86_64
	@echo "✅ Downloaded binaries for all platforms"

# Download Darwin x86_64
.PHONY: download-darwin-x86_64
download-darwin-x86_64: get-latest-version
	@echo "⬇️  Downloading Darwin x86_64 binary..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Darwin_x86_64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(BINARY_NAME)_Darwin_x86_64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Darwin_x86_64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-darwin-x86_64
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-darwin-x86_64
	@rm /tmp/$(BINARY_NAME)_Darwin_x86_64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Darwin x86_64"

# Download Darwin arm64
.PHONY: download-darwin-arm64
download-darwin-arm64: get-latest-version
	@echo "⬇️  Downloading Darwin arm64 binary..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Darwin_arm64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(BINARY_NAME)_Darwin_arm64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Darwin_arm64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-darwin-arm64
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-darwin-arm64
	@rm /tmp/$(BINARY_NAME)_Darwin_arm64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Darwin arm64"

# Download Linux x86_64
.PHONY: download-linux-x86_64
download-linux-x86_64: get-latest-version
	@echo "⬇️  Downloading Linux x86_64 binary..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(BINARY_NAME)_Linux_x86_64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-linux-x86_64
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-linux-x86_64
	@rm /tmp/$(BINARY_NAME)_Linux_x86_64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Linux x86_64"

# Download Linux arm64
.PHONY: download-linux-arm64
download-linux-arm64: get-latest-version
	@echo "⬇️  Downloading Linux arm64 binary..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Linux_arm64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(BINARY_NAME)_Linux_arm64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Linux_arm64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME) $(SERVER_DIR)/$(BINARY_NAME)-linux-arm64
	@chmod +x $(SERVER_DIR)/$(BINARY_NAME)-linux-arm64
	@rm /tmp/$(BINARY_NAME)_Linux_arm64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Linux arm64"

# Download Windows x86_64
.PHONY: download-windows-x86_64
download-windows-x86_64: get-latest-version
	@echo "⬇️  Downloading Windows x86_64 binary..."
	@mkdir -p $(SERVER_DIR)
	@curl -L -o /tmp/$(BINARY_NAME)_Windows_x86_64.tar.gz \
		https://github.com/grafana/mcp-grafana/releases/download/$(LATEST_VERSION)/$(BINARY_NAME)_Windows_x86_64.tar.gz
	@tar -xzf /tmp/$(BINARY_NAME)_Windows_x86_64.tar.gz -C /tmp
	@mv /tmp/$(BINARY_NAME).exe $(SERVER_DIR)/$(BINARY_NAME)-windows-x86_64.exe
	@rm /tmp/$(BINARY_NAME)_Windows_x86_64.tar.gz
	@rm -f /tmp/LICENSE /tmp/README.md
	@echo "✅ Downloaded Windows x86_64"

# Create platform-specific symlinks for current platform
.PHONY: link-platform-binaries
link-platform-binaries:
	@echo "🔗 Creating platform-specific symlinks..."
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		if [ -f $(SERVER_DIR)/$(BINARY_NAME)-darwin-$(ARCH) ]; then \
			ln -sf $(BINARY_NAME)-darwin-$(ARCH) $(SERVER_DIR)/$(BINARY_NAME)-darwin; \
			echo "✅ Created symlink for Darwin"; \
		fi \
	elif [ "$(PLATFORM)" = "linux" ]; then \
		if [ -f $(SERVER_DIR)/$(BINARY_NAME)-linux-$(ARCH) ]; then \
			ln -sf $(BINARY_NAME)-linux-$(ARCH) $(SERVER_DIR)/$(BINARY_NAME)-linux; \
			echo "✅ Created symlink for Linux"; \
		fi \
	fi
	@if [ -f $(SERVER_DIR)/$(BINARY_NAME)-windows-x86_64.exe ]; then \
		ln -sf $(BINARY_NAME)-windows-x86_64.exe $(SERVER_DIR)/$(BINARY_NAME)-windows.exe; \
		echo "✅ Created symlink for Windows"; \
	fi

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

# Clean downloaded files
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	@rm -f $(SERVER_DIR)/$(BINARY_NAME)-*
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
	@echo "  make all                     - Download latest version for current platform and update configs (default)"
	@echo "  make download                - Download the latest Grafana MCP server binary for current platform"
	@echo "  make download-all-platforms  - Download binaries for all supported platforms"
	@echo "  make download-darwin-x86_64  - Download Darwin x86_64 binary"
	@echo "  make download-darwin-arm64   - Download Darwin arm64 binary"
	@echo "  make download-linux-x86_64   - Download Linux x86_64 binary"
	@echo "  make download-linux-arm64    - Download Linux arm64 binary"
	@echo "  make download-windows-x86_64 - Download Windows x86_64 binary"
	@echo "  make link-platform-binaries  - Create platform-specific symlinks"
	@echo "  make update-version          - Update version in manifest.json and VERSION file"
	@echo "  make clean                   - Remove all downloaded binaries and VERSION file"
	@echo "  make version                 - Show current installed version"
	@echo "  make info                    - Show platform and version information"
	@echo "  make help                    - Show this help message"
	@echo ""
	@echo "Current Platform: $(OS) $(ARCH)"