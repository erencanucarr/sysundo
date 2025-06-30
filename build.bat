@echo off
REM sysundo Cross-Platform Build Script for Windows Batch
REM This script builds sysundo for multiple platforms and architectures

setlocal EnableDelayedExpansion

set VERSION=1.0.0
set BINARY_NAME=sysundo
set BUILD_DIR=build

echo ========================================
echo   sysundo Cross-Platform Build Script
echo            Version %VERSION%
echo ========================================
echo.

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo Building for all platforms...
echo.

REM Linux builds
echo Building Linux amd64...
set GOOS=linux
set GOARCH=amd64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-linux-amd64" .
if !errorlevel! equ 0 (
    echo ✓ Linux amd64 complete
) else (
    echo ✗ Linux amd64 failed
)

echo Building Linux arm64...
set GOOS=linux
set GOARCH=arm64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-linux-arm64" .
if !errorlevel! equ 0 (
    echo ✓ Linux arm64 complete
) else (
    echo ✗ Linux arm64 failed
)

echo Building Linux 386...
set GOOS=linux
set GOARCH=386
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-linux-386" .
if !errorlevel! equ 0 (
    echo ✓ Linux 386 complete
) else (
    echo ✗ Linux 386 failed
)

REM Windows builds
echo Building Windows amd64...
set GOOS=windows
set GOARCH=amd64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-windows-amd64.exe" .
if !errorlevel! equ 0 (
    echo ✓ Windows amd64 complete
) else (
    echo ✗ Windows amd64 failed
)

echo Building Windows arm64...
set GOOS=windows
set GOARCH=arm64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-windows-arm64.exe" .
if !errorlevel! equ 0 (
    echo ✓ Windows arm64 complete
) else (
    echo ✗ Windows arm64 failed
)

echo Building Windows 386...
set GOOS=windows
set GOARCH=386
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-windows-386.exe" .
if !errorlevel! equ 0 (
    echo ✓ Windows 386 complete
) else (
    echo ✗ Windows 386 failed
)

REM macOS builds
echo Building macOS amd64...
set GOOS=darwin
set GOARCH=amd64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-darwin-amd64" .
if !errorlevel! equ 0 (
    echo ✓ macOS amd64 complete
) else (
    echo ✗ macOS amd64 failed
)

echo Building macOS arm64 (Apple Silicon)...
set GOOS=darwin
set GOARCH=arm64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-darwin-arm64" .
if !errorlevel! equ 0 (
    echo ✓ macOS arm64 complete
) else (
    echo ✗ macOS arm64 failed
)

REM FreeBSD builds
echo Building FreeBSD amd64...
set GOOS=freebsd
set GOARCH=amd64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-freebsd-amd64" .
if !errorlevel! equ 0 (
    echo ✓ FreeBSD amd64 complete
) else (
    echo ✗ FreeBSD amd64 failed
)

echo Building FreeBSD arm64...
set GOOS=freebsd
set GOARCH=arm64
go build -ldflags "-w -s" -o "%BUILD_DIR%\%BINARY_NAME%-freebsd-arm64" .
if !errorlevel! equ 0 (
    echo ✓ FreeBSD arm64 complete
) else (
    echo ✗ FreeBSD arm64 failed
)

echo.
echo ========================================
echo           Build Summary
echo ========================================
echo Built binaries:
dir /B "%BUILD_DIR%\%BINARY_NAME%-*"
echo.
echo Build complete! Binaries are in %BUILD_DIR%/ directory.
echo.
echo Supported platforms:
echo   Linux:   amd64, arm64, 386
echo   Windows: amd64, arm64, 386
echo   macOS:   amd64 (Intel), arm64 (Apple Silicon)
echo   FreeBSD: amd64, arm64

pause 