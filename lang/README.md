# Sysundo Language Support

This directory contains language files for sysundo multilingual support.

## Adding a New Language

1. **Copy the example template:**
   ```bash
   cp example.json your_language_code.json
   ```
   
2. **Edit the language file:**
   - Update the `meta` section with your language information
   - Translate all messages in the `messages` section
   - Use ISO 639-1 language codes (en, tr, fr, de, etc.)

3. **Test your translation:**
   ```bash
   go run . lang your_language_code
   go run . help
   ```

## Language File Structure

```json
{
  "meta": {
    "name": "Language Name in English",
    "native_name": "Language Name in Native Script",
    "code": "xx",
    "author": "Your Name",
    "version": "1.0.0"
  },
  "messages": {
    "key": "Translated message",
    ...
  }
}
```

## Available Languages

- `en.json` - English (default)
- `tr.json` - Turkish
- `example.json` - Template for new languages

## Message Keys

All message keys are documented in the `example.json` file. Please ensure all keys are translated for complete language support.

## Guidelines

1. **Keep formatting placeholders:** Messages with `%s`, `%d`, `%v` should maintain these placeholders
2. **Maintain consistency:** Use consistent terminology throughout the translation
3. **Test thoroughly:** Make sure all commands work correctly with your translation
4. **Use proper encoding:** Ensure your file is saved in UTF-8 encoding

## Contributing

To add your language to the main project:

1. Fork the repository
2. Add your language file following the naming convention
3. Update the `getLangNativeName` function in `main.go` to include your language
4. Test your changes
5. Submit a pull request

Your contribution will help make sysundo accessible to more users worldwide!

## Language File Validation

Before submitting your translation, please verify:

- [ ] All message keys from `example.json` are included
- [ ] All formatting placeholders (`%s`, `%d`, `%v`) are preserved
- [ ] Meta information is correctly filled
- [ ] File is saved in UTF-8 encoding
- [ ] Language code follows ISO 639-1 standard
- [ ] All commands work correctly with your translation

## Translation Tips

### Common Terms
- **backup** - The act of creating a copy for safety
- **restore** - The act of bringing back original files
- **watch** - Monitor and execute with backup
- **undo** - Reverse the last operation

### Technical Terms
Keep these terms consistent in your language:
- Command line interface
- File operations
- Directory/folder
- Configuration
- Metadata

### Message Formatting
When translating messages with parameters:
```json
"error": "Error: %v"
```
The `%v` must remain in the translated text to display the actual error.

## Need Help?

If you need assistance with translation or have questions about the language system:

1. Check existing translations in `en.json` and `tr.json` for reference
2. Open an issue in the GitHub repository
3. Contact the maintainers

Thank you for helping make sysundo more accessible to users worldwide! 🌍 