package main

import (
	"fmt"
	"os"
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
			fmt.Println("Kullanım: sysundo watch <komut> [argümanlar...]")
			os.Exit(1)
		}
		handleWatchMode(os.Args[2:])
	case "undo":
		handleUndoMode()
	case "help", "-h", "--help":
		printUsage()
	default:
		fmt.Printf("Bilinmeyen komut: %s\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("sysundo - Sistem dosya işlemleri için otomatik yedekleme aracı")
	fmt.Println()
	fmt.Println("Kullanım:")
	fmt.Println("  sysundo watch <komut> [argümanlar...]  - Komut çalıştırırken dosyaları yedekle")
	fmt.Println("  sysundo undo                          - Son yedekleri geri yükle")
	fmt.Println("  sysundo help                          - Bu yardım metnini göster")
	fmt.Println()
	fmt.Println("Örnekler:")
	fmt.Println("  sysundo watch rm dosya.txt")
	fmt.Println("  sysundo watch mv kaynak.py hedef/")
	fmt.Println("  sysundo watch cp *.json backup/")
	fmt.Println("  sysundo undo")
}

func handleWatchMode(args []string) {
	watcher := NewFileWatcher()
	err := watcher.ExecuteWithBackup(args)
	if err != nil {
		fmt.Printf("Hata: %v\n", err)
		os.Exit(1)
	}
}

func handleUndoMode() {
	restorer := NewFileRestorer()
	err := restorer.RestoreLastBackup()
	if err != nil {
		fmt.Printf("Geri yükleme hatası: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("Son yedekler başarıyla geri yüklendi.")
}
