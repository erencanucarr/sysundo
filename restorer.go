package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sysundo/lang"
)

type FileRestorer struct {
	backupManager *BackupManager
}

func NewFileRestorer() *FileRestorer {
	return &FileRestorer{
		backupManager: NewBackupManager(),
	}
}

func (fr *FileRestorer) RestoreLastBackup() error {
	// Son yedekleme kaydını oku
	recordPath := filepath.Join(fr.backupManager.backupDir, "last_backup.json")

	data, err := os.ReadFile(recordPath)
	if err != nil {
		return fmt.Errorf(lang.Get("backup_record_not_found"), err)
	}

	var record BackupRecord
	err = json.Unmarshal(data, &record)
	if err != nil {
		return fmt.Errorf(lang.Get("backup_record_read_error"), err)
	}

	// Her dosyayı geri yükle
	restoredCount := 0
	for _, fileInfo := range record.Files {
		err := fr.restoreFile(fileInfo)
		if err != nil {
			fmt.Printf(lang.Get("file_restore_warning")+"\n",
				fileInfo.OriginalPath, err)
		} else {
			fmt.Printf(lang.Get("restored")+"\n", fileInfo.OriginalPath)
			restoredCount++
		}
	}

	if restoredCount > 0 {
		fmt.Printf(lang.Get("total_files_restored")+"\n", restoredCount)
	} else {
		return fmt.Errorf(lang.Get("no_files_restored"))
	}

	return nil
}

func (fr *FileRestorer) restoreFile(fileInfo BackupFileInfo) error {
	// Yedekleme dosyasının var olduğunu kontrol et
	if _, err := os.Stat(fileInfo.BackupPath); err != nil {
		return fmt.Errorf(lang.Get("backup_file_not_found"), err)
	}

	// Hedef dizinin var olduğunu kontrol et, yoksa oluştur
	targetDir := filepath.Dir(fileInfo.OriginalPath)
	if err := os.MkdirAll(targetDir, 0755); err != nil {
		return fmt.Errorf(lang.Get("target_dir_create_error"), err)
	}

	// Dosyayı geri yükle
	err := fr.backupManager.copyFile(fileInfo.BackupPath, fileInfo.OriginalPath)
	if err != nil {
		return fmt.Errorf(lang.Get("file_copy_error"), err)
	}

	return nil
}

func (fr *FileRestorer) ListBackups() error {
	recordPath := filepath.Join(fr.backupManager.backupDir, "last_backup.json")

	data, err := os.ReadFile(recordPath)
	if err != nil {
		return fmt.Errorf(lang.Get("backup_record_not_found"), err)
	}

	var record BackupRecord
	err = json.Unmarshal(data, &record)
	if err != nil {
		return fmt.Errorf(lang.Get("backup_record_read_error"), err)
	}

	fmt.Printf("Son yedekleme: %s\n", record.Timestamp.Format("2006-01-02 15:04:05"))
	fmt.Printf("Komut: %s %v\n", record.Command, record.Args)
	fmt.Printf("Yedeklenen dosyalar:\n")

	for _, fileInfo := range record.Files {
		fmt.Printf("  - %s (%d bytes)\n", fileInfo.OriginalPath, fileInfo.Size)
	}

	return nil
}
