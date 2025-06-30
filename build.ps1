# sysundo Cross-Platform Build Script for Windows PowerShell
# This script builds sysundo for multiple platforms and architectures

param(
    [string]$Platform = "",
    [string]$Arch = "",
    [switch]$Release = $false,
    [switch]$Clean = $false,
    [switch]$List = $false,
    [switch]$Help = $false
)

$VERSION = "1.0.0"
$BINARY_NAME = "sysundo"
$BUILD_DIR = "build"
$RELEASE_DIR = "release"

# Platform and architecture combinations
$PLATFORMS = @(
    "linux/amd64",
    "linux/arm64", 
    "linux/386",
    "windows/amd64",
    "windows/arm64",
    "windows/386",
    "darwin/amd64",
    "darwin/arm64",
    "freebsd/amd64",
    "freebsd/arm64"
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $oldColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $oldColor
}

function Show-Header {
    Write-ColorOutput "========================================" "Blue"
    Write-ColorOutput "  sysundo Cross-Platform Build Script  " "Blue"
    Write-ColorOutput "            Version $VERSION           " "Blue"  
    Write-ColorOutput "========================================" "Blue"
    Write-Output ""
}

function Show-Usage {
    Write-Output "Usage: .\build.ps1 [OPTIONS]"
    Write-Output ""
    Write-Output "Options:"
    Write-Output "  -Platform PLATFORM   Build for specific platform (linux/windows/darwin/freebsd)"
    Write-Output "  -Arch ARCH          Build for specific architecture (amd64/arm64/386)"
    Write-Output "  -Release            Create release packages with checksums"
    Write-Output "  -Clean              Clean build directory before building"
    Write-Output "  -List               List supported platforms"
    Write-Output "  -Help               Show this help message"
    Write-Output ""
    Write-Output "Examples:"
    Write-Output "  .\build.ps1                      Build for all platforms"
    Write-Output "  .\build.ps1 -Platform linux     Build for Linux only"
    Write-Output "  .\build.ps1 -Platform windows -Arch amd64  Build for Windows amd64 only"
    Write-Output "  .\build.ps1 -Release            Build all and create release packages"
    Write-Output "  .\build.ps1 -Clean              Clean and build all"
}

function Show-Platforms {
    Write-Output "Supported platforms and architectures:"
    Write-Output ""
    Write-Output ("{0,-10} {1,-20} {2,-30}" -f "Platform", "Architecture", "Output")
    Write-Output ("{0,-10} {1,-20} {2,-30}" -f "--------", "------------", "------")
    
    foreach ($platform in $PLATFORMS) {
        $parts = $platform.Split("/")
        $os = $parts[0]
        $arch = $parts[1]
        
        if ($os -eq "windows") {
            $output = "$BINARY_NAME-$os-$arch.exe"
        } else {
            $output = "$BINARY_NAME-$os-$arch"
        }
        
        Write-Output ("{0,-10} {1,-20} {2,-30}" -f $os, $arch, $output)
    }
    Write-Output ""
}

function Remove-BuildDirectories {
    Write-ColorOutput "Cleaning build directories..." "Yellow"
    
    if (Test-Path $BUILD_DIR) {
        Remove-Item -Recurse -Force $BUILD_DIR
    }
    if (Test-Path $RELEASE_DIR) {
        Remove-Item -Recurse -Force $RELEASE_DIR
    }
    
    Write-ColorOutput "✓ Clean complete" "Green"
    Write-Output ""
}

function Build-Platform {
    param(
        [string]$Os,
        [string]$Architecture
    )
    
    if ($Os -eq "windows") {
        $output = "$BUILD_DIR/$BINARY_NAME-$Os-$Architecture.exe"
    } else {
        $output = "$BUILD_DIR/$BINARY_NAME-$Os-$Architecture"
    }
    
    Write-ColorOutput "Building $Os/$Architecture..." "Blue"
    
    # Set environment variables
    $env:GOOS = $Os
    $env:GOARCH = $Architecture
    
    # Set build flags
    $ldflags = "-w -s -X main.version=$VERSION"
    
    # Build
    $result = go build -ldflags $ldflags -o $output .
    
    if ($LASTEXITCODE -eq 0) {
        $size = (Get-Item $output).Length
        $sizeKB = [math]::Round($size / 1KB, 1)
        Write-ColorOutput "✓ $Os/$Architecture complete ($sizeKB KB)" "Green"
    } else {
        Write-ColorOutput "✗ $Os/$Architecture failed" "Red"
        return $false
    }
    
    return $true
}

function New-Checksums {
    Write-ColorOutput "Creating checksums..." "Yellow"
    
    Push-Location $BUILD_DIR
    
    # Create SHA256 checksums
    $files = Get-ChildItem -File | Where-Object { $_.Name -like "sysundo-*" }
    $checksums = @()
    
    foreach ($file in $files) {
        $hash = Get-FileHash -Algorithm SHA256 $file.Name
        $checksums += "$($hash.Hash.ToLower())  $($file.Name)"
    }
    
    $checksums | Out-File -FilePath "checksums.txt" -Encoding UTF8
    
    Write-ColorOutput "✓ Checksums created" "Green"
    Pop-Location
}

function New-Release {
    Write-ColorOutput "Creating release packages..." "Yellow"
    
    if (-not (Test-Path $RELEASE_DIR)) {
        New-Item -ItemType Directory -Path $RELEASE_DIR | Out-Null
    }
    
    # Copy README and other docs to build directory
    if (Test-Path "README.md") {
        Copy-Item "README.md" $BUILD_DIR
    }
    if (Test-Path "LICENSE") {
        Copy-Item "LICENSE" $BUILD_DIR
    }
    
    # Create language directory in build
    if (Test-Path "lang") {
        Copy-Item -Recurse "lang" $BUILD_DIR
    }
    
    # Create individual platform packages
    Push-Location $BUILD_DIR
    
    $binaries = Get-ChildItem -File | Where-Object { $_.Name -like "sysundo-*" -and $_.Name -notlike "*.txt" }
    
    foreach ($binary in $binaries) {
        # Extract platform info from filename
        $platformInfo = $binary.Name -replace "sysundo-", "" -replace ".exe$", ""
        
        # Create platform-specific directory
        $platformDir = "..\$RELEASE_DIR\$platformInfo"
        if (-not (Test-Path $platformDir)) {
            New-Item -ItemType Directory -Path $platformDir -Force | Out-Null
        }
        
        # Copy binary
        Copy-Item $binary.Name $platformDir
        
        # Copy docs and lang files
        if (Test-Path "README.md") {
            Copy-Item "README.md" $platformDir
        }
        if (Test-Path "LICENSE") {
            Copy-Item "LICENSE" $platformDir
        }
        if (Test-Path "lang") {
            Copy-Item -Recurse "lang" $platformDir
        }
        
        # Create archive
        Push-Location "..\$RELEASE_DIR"
        
        if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
            Compress-Archive -Path $platformInfo -DestinationPath "$platformInfo.zip" -Force
            Remove-Item -Recurse -Force $platformInfo
        }
        
        Pop-Location
    }
    
    Pop-Location
    Write-ColorOutput "✓ Release packages created in $RELEASE_DIR/" "Green"
}

function Show-BuildSummary {
    Write-Output ""
    Write-ColorOutput "========================================" "Green"
    Write-ColorOutput "           Build Summary                " "Green"
    Write-ColorOutput "========================================" "Green"
    
    if (Test-Path $BUILD_DIR) {
        Write-Output "Built binaries:"
        Get-ChildItem $BUILD_DIR | Where-Object { $_.Name -like "sysundo-*" } | ForEach-Object {
            $size = [math]::Round($_.Length / 1KB, 1)
            Write-Output "  $($_.Name) ($size KB)"
        }
        Write-Output ""
        
        if (Test-Path "$BUILD_DIR\checksums.txt") {
            Write-Output "SHA256 Checksums:"
            Get-Content "$BUILD_DIR\checksums.txt"
            Write-Output ""
        }
    }
    
    if (Test-Path $RELEASE_DIR) {
        Write-Output "Release packages:"
        Get-ChildItem $RELEASE_DIR | ForEach-Object {
            $size = [math]::Round($_.Length / 1KB, 1)
            Write-Output "  $($_.Name) ($size KB)"
        }
        Write-Output ""
    }
    
    Write-ColorOutput "Build complete!" "Green"
}

# Main script logic
function Main {
    if ($Help) {
        Show-Header
        Show-Usage
        return
    }
    
    if ($List) {
        Show-Platforms
        return
    }
    
    Show-Header
    
    # Clean if requested
    if ($Clean) {
        Remove-BuildDirectories
    }
    
    # Create build directory
    if (-not (Test-Path $BUILD_DIR)) {
        New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
    }
    
    # Determine what to build
    if ($Platform -and $Arch) {
        # Build specific platform/arch
        Build-Platform $Platform $Arch
    } elseif ($Platform) {
        # Build all architectures for specific platform
        Write-ColorOutput "Building for platform: $Platform" "Yellow"
        Write-Output ""
        
        foreach ($p in $PLATFORMS) {
            $parts = $p.Split("/")
            $os = $parts[0]
            $arch = $parts[1]
            
            if ($os -eq $Platform) {
                Build-Platform $os $arch
            }
        }
    } else {
        # Build all platforms
        Write-ColorOutput "Building for all platforms..." "Yellow"
        Write-Output ""
        
        foreach ($p in $PLATFORMS) {
            $parts = $p.Split("/")
            $os = $parts[0]
            $arch = $parts[1]
            
            Build-Platform $os $arch
        }
    }
    
    # Create checksums
    New-Checksums
    
    # Create release packages if requested
    if ($Release) {
        New-Release
    }
    
    Show-BuildSummary
}

# Run main function
Main 