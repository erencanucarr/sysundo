# sysundo Makefile

# Değişkenler
BINARY_NAME=sysundo
SOURCE_DIR=.
BUILD_DIR=build

# Varsayılan hedef
.PHONY: all
all: build

# Derleme
.PHONY: build
build:
	go build -o $(BINARY_NAME) $(SOURCE_DIR)

# Test
.PHONY: test
test:
	go test ./...

# Temizleme
.PHONY: clean
clean:
	rm -f $(BINARY_NAME)
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

# Yardım
.PHONY: help
help:
	@echo "Kullanılabilir komutlar:"
	@echo "  build      - Uygulamayı derle"
	@echo "  test       - Testleri çalıştır"
	@echo "  clean      - Oluşturulan dosyaları temizle"
	@echo "  install    - Binary'yi sistem genelinde kur"
	@echo "  uninstall  - Binary'yi sistemden kaldır"
	@echo "  dev        - Geliştirme modunda çalıştır (make dev ARGS='help')"
	@echo "  help       - Bu yardım metnini göster"

# Linux için özel hedefler
.PHONY: linux-build
linux-build:
	GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME)-linux $(SOURCE_DIR)

.PHONY: windows-build
windows-build:
	GOOS=windows GOARCH=amd64 go build -o $(BINARY_NAME).exe $(SOURCE_DIR) 