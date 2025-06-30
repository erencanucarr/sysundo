# sysundo - Automatic Backup Tool for System File Operations

`sysundo` is a multilingual CLI tool that automatically backs up files before performing file operations (rm, mv, cp) on Linux systems and provides restore functionality when needed.

## Features

- **Automatic Backup**: Automatically backs up affected files before executing `rm`, `mv`, `cp` commands
- **Smart Filtering**: Only backs up supported file types (.txt, .md, .json, .yaml, .yml, .sh, .js, .py)
- **Size Limit**: Backs up files with a maximum size of 10MB
- **Restore**: Restore last backed up files with a single command
- **Safe Storage**: Backups are stored in `.sysundo/cache` folder in user's home directory
- **🌍 Multilingual Support**: English and Turkish support, new languages can be easily added
- **🔄 Automatic Language Detection**: Automatically detects your system language

## Installation

### Quick Installation
```bash
# Build the project
go build -o sysundo

# Add binary to PATH (optional)
sudo cp sysundo /usr/local/bin/
```

### Cross-Platform Builds

The project supports building for multiple platforms and architectures:

**Supported Platforms:**
- **Linux**: amd64, arm64, 386
- **Windows**: amd64, arm64, 386
- **macOS**: amd64 (Intel), arm64 (Apple Silicon)
- **FreeBSD**: amd64, arm64

**Build Methods:**

1. **Using Makefile** (Linux/macOS/WSL):
```bash
# Build for all platforms
make build-all

# Build for specific platform
make build-linux     # All Linux architectures
make build-windows   # All Windows architectures
make build-darwin    # All macOS architectures
make build-freebsd   # All FreeBSD architectures

# Show supported platforms
make build-info
```

2. **Using Bash Script** (Linux/macOS/WSL):
```bash
# Make executable (first time only)
chmod +x build.sh

# Build all platforms
./build.sh

# Build specific platform
./build.sh -p linux
./build.sh -p windows -a amd64

# Create release packages
./build.sh -r

# Show help
./build.sh -h
```

3. **Using PowerShell** (Windows):
```powershell
# Build all platforms
.\build.ps1

# Build specific platform
.\build.ps1 -Platform windows
.\build.ps1 -Platform linux -Arch amd64

# Create release packages
.\build.ps1 -Release

# Show supported platforms
.\build.ps1 -List
```

4. **Using Batch Script** (Windows):
```cmd
# Build all platforms
build.bat
```

5. **Manual Cross-Compilation**:
```bash
# Linux 64-bit
GOOS=linux GOARCH=amd64 go build -o sysundo-linux-amd64

# Windows 64-bit
GOOS=windows GOARCH=amd64 go build -o sysundo-windows-amd64.exe

# macOS 64-bit (Intel)
GOOS=darwin GOARCH=amd64 go build -o sysundo-darwin-amd64

# macOS ARM64 (Apple Silicon)
GOOS=darwin GOARCH=arm64 go build -o sysundo-darwin-arm64
```

All built binaries will be placed in the `build/` directory with platform-specific naming.

## Usage

### Watch Mode
Execute file operations with backup:

```bash
# File deletion with backup
sysundo watch rm file.txt

# File move with backup  
sysundo watch mv source.py target/

# File copy with backup
sysundo watch cp *.json backup/

# Using wildcards
sysundo watch rm *.py
```

### Undo Mode
Restore last backed up files:

```bash
sysundo undo
```

### Language Management
```bash
# Show current language and supported languages
sysundo lang

# Switch to English
sysundo lang en

# Switch to Turkish
sysundo lang tr
```

### Help
```bash
sysundo help
```

## Supported Languages

- 🇺🇸 **English** (en) - Default language
- 🇹🇷 **Turkish** (tr) - Full support
- 📄 **Template** (example.json) - Template for new languages

### Adding New Languages

1. Copy `lang/example.json` file
2. Rename it with your language code (e.g., `fr.json`)
3. Translate all messages
4. Test: `sysundo lang fr`

See [lang/README.md](lang/README.md) for detailed instructions.

## Supported File Types

- `.txt` - Text files
- `.md` - Markdown files  
- `.json` - JSON files
- `.yaml`, `.yml` - YAML files
- `.sh` - Shell script files
- `.js` - JavaScript files
- `.py` - Python files

## Backup Mechanism

1. **Backup Directory**: Backups are stored in `~/.sysundo/cache/` directory
2. **File Naming**: Files are named in `YYYYMMDD_HHMMSS_filename_ID` format
3. **Metadata**: Last backup information is kept in `last_backup.json` file
4. **Restore**: Files are restored to their original locations with permissions preserved

## Limitations

- Maximum file size: 10MB
- Only specified file types are backed up
- Directories are not backed up (files only)
- Binary files (.mp4, .zip, .tar, .gz) are automatically excluded

## Example Usage Scenarios

```bash
# Delete important script files with backup
sysundo watch rm cleanup.sh setup.py

# Safely move configuration files
sysundo watch mv config.json backup/

# If you made a mistake, restore
sysundo undo

# Change language
sysundo lang en
```

## Project Structure

```
sysundo/
├── main.go          # Main CLI application
├── watcher.go       # File watching and command execution
├── backup.go        # Backup operations
├── restorer.go      # Restore operations
├── lang/            # Language files
│   ├── lang.go      # Language management system
│   ├── en.json      # English translations
│   ├── tr.json      # Turkish translations
│   ├── example.json # Template for new languages
│   └── README.md    # Language addition guide
├── build/           # Cross-platform binaries (created after build)
├── go.mod           # Go module definition
├── Makefile         # Build and installation commands
├── build.sh         # Cross-platform build script (Bash)
├── build.ps1        # Cross-platform build script (PowerShell)
├── build.bat        # Cross-platform build script (Batch)
├── LICENSE          # MIT License
└── README.md        # Project documentation
```

## Development

The project is developed entirely using Go standard libraries. There are no external dependencies.

```bash
# Test
go run . help

# Build
go build -o sysundo

# Language tests
go run . lang
go run . lang tr
go run . help
```

## Makefile Commands

```bash
make build          # Build the application
make build-all      # Build for all platforms
make build-linux    # Build for Linux only
make build-windows  # Build for Windows only
make build-darwin   # Build for macOS only
make build-freebsd  # Build for FreeBSD only
make build-info     # Show supported platforms
make install        # Install system-wide
make clean          # Clean up
make dev ARGS=help  # Run in development mode
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### To Add a New Language

1. Copy `lang/example.json` to `lang/your_lang_code.json`
2. Translate all messages
3. Add your language to the `getLangNativeName` function in `main.go`
4. Test and submit a Pull Request

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

**sysundo** - Keep your files safe, undo your mistakes! 🛡️ 