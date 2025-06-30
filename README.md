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

```bash
# Build the project
go build -o sysundo

# Add binary to PATH (optional)
sudo cp sysundo /usr/local/bin/
```

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
├── go.mod           # Go module definition
├── Makefile         # Build and installation commands
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