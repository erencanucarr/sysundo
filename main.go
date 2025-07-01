package main

import (
	"fmt"
	"os"
	"strings"
	"sysundo/lang"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	case "watch":
		if len(os.Args) < 3 {
			fmt.Println(lang.Get("watch_command_usage"))
			os.Exit(1)
		}
		handleWatchMode(os.Args[2:])
	case "undo":
		handleUndoMode()
	case "lang":
		handleLangMode(os.Args[2:])
	case "help", "-h", "--help":
		printUsage()
	default:
		fmt.Printf(lang.Get("unknown_command")+"\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println(lang.Get("app_description"))
	fmt.Println()
	fmt.Println(lang.Get("usage"))
	fmt.Println("  " + lang.Get("watch_usage"))
	fmt.Println("  " + lang.Get("undo_usage"))
	fmt.Println("  " + lang.Get("help_usage"))
	fmt.Println("  " + lang.Get("lang_usage"))
	fmt.Println()
	fmt.Println(lang.Get("examples"))
	fmt.Println("  " + lang.Get("example_watch_rm"))
	fmt.Println("  " + lang.Get("example_watch_mv"))
	fmt.Println("  " + lang.Get("example_watch_cp"))
	fmt.Println("  " + lang.Get("example_undo"))
	fmt.Println("  " + lang.Get("example_lang_set"))
	fmt.Println("  " + lang.Get("example_lang_list"))
}

func handleWatchMode(args []string) {
	watcher := NewFileWatcher()
	err := watcher.ExecuteWithBackup(args)
	if err != nil {
		fmt.Printf(lang.Get("error")+"\n", err)
		os.Exit(1)
	}
}

func handleUndoMode() {
	restorer := NewFileRestorer()
	err := restorer.RestoreLastBackup()
	if err != nil {
		fmt.Printf(lang.Get("undo_error")+"\n", err)
		os.Exit(1)
	}
	fmt.Println(lang.Get("last_backups_restored"))
}

func handleLangMode(args []string) {
	if len(args) == 0 {
		// Mevcut dili ve mevcut dilleri göster
		currentLang := lang.GetCurrentLanguage()
		availableLangs, err := lang.GetAvailableLanguages()

		fmt.Printf(lang.Get("current_language")+"\n", currentLang, getLangNativeName(currentLang))
		fmt.Println()
		fmt.Println(lang.Get("available_languages"))

		if err != nil {
			fmt.Printf("Error getting available languages: %v\n", err)
			return
		}

		for _, langCode := range availableLangs {
			if langCode == "example" {
				continue // example.json dosyasını listede gösterme
			}
			nativeName := getLangNativeName(langCode)
			fmt.Printf("  %s (%s)\n", langCode, nativeName)
		}
		return
	}

	// Dil değiştir
	newLang := args[0]
	err := lang.SetLanguage(newLang)
	if err != nil {
		fmt.Printf(lang.Get("language_file_error")+"\n", err)
		fmt.Printf(lang.Get("invalid_language")+"\n", newLang)
		os.Exit(1)
	}

	fmt.Printf(lang.Get("language_set")+"\n", newLang)
}

func getLangNativeName(langCode string) string {
	langNames := map[string]string{
		"en": "English",
		"tr": "Türkçe",
	}

	if name, exists := langNames[langCode]; exists {
		return name
	}

	return strings.ToUpper(langCode)
}
