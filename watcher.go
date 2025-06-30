package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type FileWatcher struct {
	backupManager *BackupManager
	config        *Config
}

type Config struct {
	MaxFileSize   int64    // 10MB limit
	SupportedExts []string // Desteklenen uzantılar
	ExcludedExts  []string // Hariç tutulan uzantılar
	TextFilesOnly bool     // Sadece metin dosyaları
}

func NewFileWatcher() *FileWatcher {
	return &FileWatcher{
		backupManager: NewBackupManager(),
		config: &Config{
			MaxFileSize: 10 * 1024 * 1024, // 10MB
			SupportedExts: []string{
				".txt", ".md", ".json", ".yaml", ".yml",
				".sh", ".js", ".py",
			},
			ExcludedExts:  []string{".mp4", ".zip", ".tar", ".gz"},
			TextFilesOnly: false,
		},
	}
}

func (fw *FileWatcher) ExecuteWithBackup(args []string) error {
	if len(args) == 0 {
		return fmt.Errorf("komut belirtilmedi")
	}

	command := args[0]
	commandArgs := args[1:]

	// Sadece rm, mv, cp komutları için yedekleme yapıyoruz
	if !fw.isWatchedCommand(command) {
		return fw.executeCommand(command, commandArgs)
	}

	// Etkilenecek dosyaları bul
	affectedFiles, err := fw.findAffectedFiles(command, commandArgs)
	if err != nil {
		return fmt.Errorf("etkilenen dosyalar bulunamadı: %v", err)
	}

	// Geçerli dosyaları filtrele ve yedekle
	backupPaths := make(map[string]string)
	for _, file := range affectedFiles {
		if fw.shouldBackupFile(file) {
			backupPath, err := fw.backupManager.BackupFile(file)
			if err != nil {
				fmt.Printf("Uyarı: %s dosyası yedeklenemedi: %v\n", file, err)
			} else {
				absPath, _ := filepath.Abs(file)
				backupPaths[absPath] = backupPath
				fmt.Printf("Yedeklendi: %s\n", file)
			}
		}
	}

	// Yedekleme kaydını oluştur
	if len(backupPaths) > 0 {
		err := fw.backupManager.CreateBackupRecord(backupPaths, command, commandArgs)
		if err != nil {
			fmt.Printf("Uyarı: Yedekleme kaydı oluşturulamadı: %v\n", err)
		}
	}

	// Orijinal komutu çalıştır
	return fw.executeCommand(command, commandArgs)
}

func (fw *FileWatcher) isWatchedCommand(command string) bool {
	watchedCommands := []string{"rm", "mv", "cp"}
	for _, cmd := range watchedCommands {
		if command == cmd {
			return true
		}
	}
	return false
}

func (fw *FileWatcher) findAffectedFiles(command string, args []string) ([]string, error) {
	var files []string

	switch command {
	case "rm":
		files = fw.expandPaths(args)
	case "mv":
		if len(args) >= 1 {
			// mv komutunda kaynak dosyalar etkilenir
			files = fw.expandPaths(args[:len(args)-1])
		}
	case "cp":
		if len(args) >= 1 {
			// cp komutunda kaynak dosyalar yedeklenir
			files = fw.expandPaths(args[:len(args)-1])
		}
	}

	// Var olan dosyaları filtrele
	var existingFiles []string
	for _, file := range files {
		if info, err := os.Stat(file); err == nil && !info.IsDir() {
			existingFiles = append(existingFiles, file)
		}
	}

	return existingFiles, nil
}

func (fw *FileWatcher) expandPaths(paths []string) []string {
	var expanded []string

	for _, path := range paths {
		// Basit wildcard expansion
		if strings.Contains(path, "*") {
			matches, err := filepath.Glob(path)
			if err == nil {
				expanded = append(expanded, matches...)
			}
		} else {
			expanded = append(expanded, path)
		}
	}

	return expanded
}

func (fw *FileWatcher) shouldBackupFile(filePath string) bool {
	// Dosya var mı kontrol et
	info, err := os.Stat(filePath)
	if err != nil {
		return false
	}

	// Dizin mi kontrol et
	if info.IsDir() {
		return false
	}

	// Boyut kontrolü
	if info.Size() > fw.config.MaxFileSize {
		return false
	}

	// Uzantı kontrolü
	ext := strings.ToLower(filepath.Ext(filePath))

	// Hariç tutulan uzantılar kontrolü
	for _, excludedExt := range fw.config.ExcludedExts {
		if ext == excludedExt {
			return false
		}
	}

	// Desteklenen uzantılar kontrolü
	for _, supportedExt := range fw.config.SupportedExts {
		if ext == supportedExt {
			return true
		}
	}

	return false
}

func (fw *FileWatcher) executeCommand(command string, args []string) error {
	cmd := exec.Command(command, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}
