# sysundo Makefile

# Değişkenler
BINARY_NAME=sysundo
SOURCE_DIR=.
BUILD_DIR=build
VERSION=1.0.0

# Varsayılan hedef
.PHONY: all
all: build

# Derleme
.PHONY: build
build:
	go build -o $(BINARY_NAME) $(SOURCE_DIR)

# Cross-platform builds
.PHONY: build-all
build-all: clean-build
	@echo "Building for all platforms..."
	@mkdir -p $(BUILD_DIR)
	
	# Linux builds
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 $(SOURCE_DIR)
	GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 $(SOURCE_DIR)
	GOOS=linux GOARCH=386 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-386 $(SOURCE_DIR)
	
	# Windows builds
	GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(SOURCE_DIR)
	GOOS=windows GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe $(SOURCE_DIR)
	GOOS=windows GOARCH=386 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-386.exe $(SOURCE_DIR)
	
	# macOS builds
	GOOS=darwin GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 $(SOURCE_DIR)
	GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 $(SOURCE_DIR)
	
	# FreeBSD builds
	GOOS=freebsd GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-freebsd-amd64 $(SOURCE_DIR)
	GOOS=freebsd GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-freebsd-arm64 $(SOURCE_DIR)
	
	@echo "Build complete! Binaries are in $(BUILD_DIR)/"
	@ls -la $(BUILD_DIR)/

# Platform-specific builds
.PHONY: build-linux
build-linux: clean-build
	@mkdir -p $(BUILD_DIR)
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 $(SOURCE_DIR)
	GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 $(SOURCE_DIR)
	GOOS=linux GOARCH=386 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-386 $(SOURCE_DIR)

.PHONY: build-windows
build-windows: clean-build
	@mkdir -p $(BUILD_DIR)
	GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(SOURCE_DIR)
	GOOS=windows GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe $(SOURCE_DIR)
	GOOS=windows GOARCH=386 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-386.exe $(SOURCE_DIR)

.PHONY: build-darwin
build-darwin: clean-build
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 $(SOURCE_DIR)
	GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 $(SOURCE_DIR)

.PHONY: build-freebsd
build-freebsd: clean-build
	@mkdir -p $(BUILD_DIR)
	GOOS=freebsd GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-freebsd-amd64 $(SOURCE_DIR)
	GOOS=freebsd GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-freebsd-arm64 $(SOURCE_DIR)

# Test
.PHONY: test
test:
	go test ./...

# Temizleme
.PHONY: clean
clean:
	rm -f $(BINARY_NAME)
	rm -rf $(BUILD_DIR)

.PHONY: clean-build
clean-build:
	rm -rf $(BUILD_DIR)

# Kurulum
.PHONY: install
install: build
	sudo cp $(BINARY_NAME) /usr/local/bin/

# Kaldırma
.PHONY: uninstall
uninstall:
	sudo rm -f /usr/local/bin/$(BINARY_NAME)

# Geliştirme modu
.PHONY: dev
dev:
	go run . $(ARGS)

# Build info
.PHONY: build-info
build-info:
	@echo "Supported platforms and architectures:"
	@echo "Linux:   amd64, arm64, 386"
	@echo "Windows: amd64, arm64, 386"
	@echo "macOS:   amd64, arm64 (Intel/Apple Silicon)"
	@echo "FreeBSD: amd64, arm64"
	@echo ""
	@echo "Available build commands:"
	@echo "  make build-all     - Build for all platforms"
	@echo "  make build-linux   - Build for Linux only"
	@echo "  make build-windows - Build for Windows only"
	@echo "  make build-darwin  - Build for macOS only"
	@echo "  make build-freebsd - Build for FreeBSD only"
	@echo "  build-info - Desteklenen platformları göster"

# Yardım
.PHONY: help
help:
	@echo "Kullanılabilir komutlar:"
	@echo "  build      - Uygulamayı derle"
	@echo "  build-all  - Tüm platformlar için derle"
	@echo "  build-linux   - Linux için derle"
	@echo "  build-windows - Windows için derle"
	@echo "  build-darwin  - macOS için derle"
	@echo "  build-freebsd - FreeBSD için derle"
	@echo "  build-info - Desteklenen platformları göster"
	@echo "  test       - Testleri çalıştır"
	@echo "  clean      - Oluşturulan dosyaları temizle"
	@echo "  install    - Binary'yi sistem genelinde kur"
	@echo "  uninstall  - Binary'yi sistemden kaldır"
	@echo "  dev        - Geliştirme modunda çalıştır (make dev ARGS='help')"
	@echo "  help       - Bu yardım metnini göster" 