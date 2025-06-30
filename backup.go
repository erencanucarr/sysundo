package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"
)

type BackupManager struct {
	backupDir string
}

type BackupRecord struct {
	Timestamp time.Time        `json:"timestamp"`
	Command   string           `json:"command"`
	Args      []string         `json:"args"`
	Files     []BackupFileInfo `json:"files"`
}

type BackupFileInfo struct {
	OriginalPath string `json:"original_path"`
	BackupPath   string `json:"backup_path"`
	Size         int64  `json:"size"`
}

func NewBackupManager() *BackupManager {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		// Fallback olarak mevcut dizini kullan
		homeDir = "."
	}

	backupDir := filepath.Join(homeDir, ".sysundo", "cache")

	// Yedekleme dizinini oluştur
	err = os.MkdirAll(backupDir, 0755)
	if err != nil {
		fmt.Printf("Uyarı: Yedekleme dizini oluşturulamadı: %v\n", err)
	}

	return &BackupManager{
		backupDir: backupDir,
	}
}

func (bm *BackupManager) BackupFile(filePath string) (string, error) {
	// Mutlak yol al
	absPath, err := filepath.Abs(filePath)
	if err != nil {
		return "", fmt.Errorf("mutlak yol alınamadı: %v", err)
	}

	// Dosya bilgilerini al
	_, err = os.Stat(absPath)
	if err != nil {
		return "", fmt.Errorf("dosya bilgileri alınamadı: %v", err)
	}

	// Yedekleme dosya adını oluştur
	timestamp := time.Now().Format("20060102_150405")
	baseFileName := filepath.Base(absPath)
	backupFileName := fmt.Sprintf("%s_%s_%s", timestamp,
		bm.sanitizeFileName(baseFileName), bm.generateID())
	backupPath := filepath.Join(bm.backupDir, backupFileName)

	// Dosyayı kopyala
	err = bm.copyFile(absPath, backupPath)
	if err != nil {
		return "", fmt.Errorf("dosya kopyalanamadı: %v", err)
	}

	return backupPath, nil
}

func (bm *BackupManager) CreateBackupRecord(backupPaths map[string]string, command string, args []string) error {
	var fileInfos []BackupFileInfo

	for originalPath, backupPath := range backupPaths {
		info, err := os.Stat(backupPath)
		if err != nil {
			continue
		}

		fileInfos = append(fileInfos, BackupFileInfo{
			OriginalPath: originalPath,
			BackupPath:   backupPath,
			Size:         info.Size(),
		})
	}

	record := BackupRecord{
		Timestamp: time.Now(),
		Command:   command,
		Args:      args,
		Files:     fileInfos,
	}

	// JSON olarak kaydet
	recordPath := filepath.Join(bm.backupDir, "last_backup.json")
	data, err := json.MarshalIndent(record, "", "  ")
	if err != nil {
		return fmt.Errorf("JSON marshal hatası: %v", err)
	}

	err = os.WriteFile(recordPath, data, 0644)
	if err != nil {
		return fmt.Errorf("kayıt dosyası yazılamadı: %v", err)
	}

	return nil
}

func (bm *BackupManager) copyFile(src, dst string) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	dstFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	if err != nil {
		return err
	}

	// Dosya izinlerini kopyala
	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	err = os.Chmod(dst, srcInfo.Mode())
	if err != nil {
		return err
	}

	return nil
}

func (bm *BackupManager) sanitizeFileName(fileName string) string {
	// Dosya adından güvenli olmayan karakterleri temizle
	sanitized := ""
	for _, r := range fileName {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') ||
			(r >= '0' && r <= '9') || r == '.' || r == '_' || r == '-' {
			sanitized += string(r)
		} else {
			sanitized += "_"
		}
	}
	return sanitized
}

func (bm *BackupManager) generateID() string {
	// Basit bir ID üretici
	return fmt.Sprintf("%d", time.Now().UnixNano()%100000)
}
