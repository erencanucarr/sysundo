#!/bin/bash

# sysundo Cross-Platform Build Script
# This script builds sysundo for multiple platforms and architectures

set -e

VERSION="1.0.0"
BINARY_NAME="sysundo"
BUILD_DIR="build"
RELEASE_DIR="release"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform and architecture combinations
declare -a PLATFORMS=(
    "linux/amd64"
    "linux/arm64"
    "linux/386"
    "windows/amd64"
    "windows/arm64"
    "windows/386"
    "darwin/amd64"
    "darwin/arm64"
    "freebsd/amd64"
    "freebsd/arm64"
)

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  sysundo Cross-Platform Build Script  ${NC}"
    echo -e "${BLUE}            Version $VERSION           ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -p, --platform PLATFORM  Build for specific platform (linux/windows/darwin/freebsd)"
    echo "  -a, --arch ARCH          Build for specific architecture (amd64/arm64/386)"
    echo "  -r, --release            Create release packages with checksums"
    echo "  -c, --clean              Clean build directory before building"
    echo "  -l, --list               List supported platforms"
    echo "  -h, --help               Show this help message"
    echo
    echo "Examples:"
    echo "  $0                       Build for all platforms"
    echo "  $0 -p linux             Build for Linux only"
    echo "  $0 -p windows -a amd64  Build for Windows amd64 only"
    echo "  $0 -r                    Build all and create release packages"
    echo "  $0 -c                    Clean and build all"
}

print_platforms() {
    echo "Supported platforms and architectures:"
    echo
    printf "%-10s %-20s %-30s\n" "Platform" "Architecture" "Output"
    printf "%-10s %-20s %-30s\n" "--------" "------------" "------"
    
    for platform in "${PLATFORMS[@]}"; do
        IFS='/' read -r os arch <<< "$platform"
        if [ "$os" = "windows" ]; then
            output="${BINARY_NAME}-${os}-${arch}.exe"
        else
            output="${BINARY_NAME}-${os}-${arch}"
        fi
        printf "%-10s %-20s %-30s\n" "$os" "$arch" "$output"
    done
    echo
}

clean_build() {
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf "$BUILD_DIR"
    rm -rf "$RELEASE_DIR"
    echo -e "${GREEN}✓ Clean complete${NC}"
    echo
}

build_platform() {
    local os=$1
    local arch=$2
    
    if [ "$os" = "windows" ]; then
        local output="${BUILD_DIR}/${BINARY_NAME}-${os}-${arch}.exe"
    else
        local output="${BUILD_DIR}/${BINARY_NAME}-${os}-${arch}"
    fi
    
    echo -e "${BLUE}Building ${os}/${arch}...${NC}"
    
    # Set build flags
    local ldflags="-w -s -X main.version=$VERSION"
    
    # Build
    GOOS=$os GOARCH=$arch go build -ldflags "$ldflags" -o "$output" .
    
    if [ $? -eq 0 ]; then
        local size=$(du -h "$output" | cut -f1)
        echo -e "${GREEN}✓ ${os}/${arch} complete (${size})${NC}"
    else
        echo -e "${RED}✗ ${os}/${arch} failed${NC}"
        return 1
    fi
}

create_checksums() {
    echo -e "${YELLOW}Creating checksums...${NC}"
    cd "$BUILD_DIR"
    
    # Create SHA256 checksums
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum * > checksums.txt
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 * > checksums.txt
    else
        echo -e "${YELLOW}Warning: No SHA256 utility found, skipping checksums${NC}"
        cd ..
        return
    fi
    
    echo -e "${GREEN}✓ Checksums created${NC}"
    cd ..
}

create_release() {
    echo -e "${YELLOW}Creating release packages...${NC}"
    mkdir -p "$RELEASE_DIR"
    
    # Copy README and other docs to build directory
    cp README.md "$BUILD_DIR/" 2>/dev/null || true
    cp LICENSE "$BUILD_DIR/" 2>/dev/null || true
    
    # Create language directory in build
    if [ -d "lang" ]; then
        cp -r lang "$BUILD_DIR/"
    fi
    
    # Create individual platform packages
    cd "$BUILD_DIR"
    for file in sysundo-*; do
        if [ -f "$file" ]; then
            # Extract platform info from filename
            platform_info=$(echo "$file" | sed 's/sysundo-//' | sed 's/.exe$//')
            
            # Create platform-specific directory
            platform_dir="../${RELEASE_DIR}/${platform_info}"
            mkdir -p "$platform_dir"
            
            # Copy binary
            cp "$file" "$platform_dir/"
            
            # Copy docs and lang files
            cp README.md "$platform_dir/" 2>/dev/null || true
            cp LICENSE "$platform_dir/" 2>/dev/null || true
            cp -r lang "$platform_dir/" 2>/dev/null || true
            
            # Create archive
            cd "../$RELEASE_DIR"
            if command -v zip >/dev/null 2>&1; then
                zip -r "${platform_info}.zip" "$platform_info"
                rm -rf "$platform_info"
            elif command -v tar >/dev/null 2>&1; then
                tar -czf "${platform_info}.tar.gz" "$platform_info"
                rm -rf "$platform_info"
            fi
            cd "../$BUILD_DIR"
        fi
    done
    
    cd ..
    echo -e "${GREEN}✓ Release packages created in ${RELEASE_DIR}/$(NC)"
}

show_build_summary() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}           Build Summary                ${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    if [ -d "$BUILD_DIR" ]; then
        echo "Built binaries:"
        ls -la "$BUILD_DIR"/ | grep sysundo
        echo
        
        if [ -f "$BUILD_DIR/checksums.txt" ]; then
            echo "SHA256 Checksums:"
            cat "$BUILD_DIR/checksums.txt"
            echo
        fi
    fi
    
    if [ -d "$RELEASE_DIR" ]; then
        echo "Release packages:"
        ls -la "$RELEASE_DIR"/
        echo
    fi
    
    echo -e "${GREEN}Build complete!${NC}"
}

# Main script
main() {
    local CLEAN=false
    local RELEASE=false
    local PLATFORM=""
    local ARCH=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--platform)
                PLATFORM="$2"
                shift 2
                ;;
            -a|--arch)
                ARCH="$2"
                shift 2
                ;;
            -r|--release)
                RELEASE=true
                shift
                ;;
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -l|--list)
                print_platforms
                exit 0
                ;;
            -h|--help)
                print_header
                print_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    print_header
    
    # Clean if requested
    if [ "$CLEAN" = true ]; then
        clean_build
    fi
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Determine what to build
    if [ -n "$PLATFORM" ] && [ -n "$ARCH" ]; then
        # Build specific platform/arch
        build_platform "$PLATFORM" "$ARCH"
    elif [ -n "$PLATFORM" ]; then
        # Build all architectures for specific platform
        echo -e "${YELLOW}Building for platform: $PLATFORM${NC}"
        echo
        for platform in "${PLATFORMS[@]}"; do
            IFS='/' read -r os arch <<< "$platform"
            if [ "$os" = "$PLATFORM" ]; then
                build_platform "$os" "$arch"
            fi
        done
    else
        # Build all platforms
        echo -e "${YELLOW}Building for all platforms...${NC}"
        echo
        for platform in "${PLATFORMS[@]}"; do
            IFS='/' read -r os arch <<< "$platform"
            build_platform "$os" "$arch"
        done
    fi
    
    # Create checksums
    create_checksums
    
    # Create release packages if requested
    if [ "$RELEASE" = true ]; then
        create_release
    fi
    
    show_build_summary
}

# Run main function with all arguments
main "$@" 