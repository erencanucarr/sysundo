package lang

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
)

type LangManager struct {
	currentLang string
	langData    map[string]string
	configPath  string
}

type LangData struct {
	Meta     LangMeta          `json:"meta"`
	Messages map[string]string `json:"messages"`
}

type LangMeta struct {
	Name       string `json:"name"`
	NativeName string `json:"native_name"`
	Code       string `json:"code"`
	Author     string `json:"author"`
	Version    string `json:"version"`
}

type LangConfig struct {
	Language string `json:"language"`
}

var globalLangManager *LangManager

func init() {
	// Config dosyası yolunu belirle
	homeDir, err := os.UserHomeDir()
	if err != nil {
		homeDir = "."
	}
	configDir := filepath.Join(homeDir, ".sysundo")
	os.MkdirAll(configDir, 0755)
	configPath := filepath.Join(configDir, "config.json")

	globalLangManager = &LangManager{
		currentLang: "en", // Varsayılan dil İngilizce
		langData:    make(map[string]string),
		configPath:  configPath,
	}

	// Kaydedilmiş dil ayarını yükle
	savedLang := globalLangManager.loadSavedLanguage()
	if savedLang != "" {
		globalLangManager.currentLang = savedLang
	} else {
		// Sistem dilini otomatik algıla
		if systemLang := detectSystemLanguage(); systemLang != "" {
			globalLangManager.currentLang = systemLang
		}
	}

	// Dil dosyasını yükle
	err = globalLangManager.LoadLanguage(globalLangManager.currentLang)
	if err != nil {
		// Eğer belirtilen dil yüklenemezse İngilizce'ye geri dön
		globalLangManager.currentLang = "en"
		globalLangManager.LoadLanguage("en")
	}
}

func (lm *LangManager) loadSavedLanguage() string {
	data, err := os.ReadFile(lm.configPath)
	if err != nil {
		return ""
	}

	var config LangConfig
	err = json.Unmarshal(data, &config)
	if err != nil {
		return ""
	}

	return config.Language
}

func (lm *LangManager) saveLangaugeConfig() error {
	config := LangConfig{
		Language: lm.currentLang,
	}

	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(lm.configPath, data, 0644)
}

func (lm *LangManager) LoadLanguage(langCode string) error {
	var langFile string
	var err error

	// Farklı yolları sırayla deneyeceğiz
	possiblePaths := []string{
		// Kaynak kod yanında (geliştirme ortamı)
		filepath.Join("lang", langCode+".json"),
		// Go module root'a göre
		filepath.Join(".", "lang", langCode+".json"),
	}

	// Executable path'i dene
	if execPath, err := os.Executable(); err == nil {
		execDir := filepath.Dir(execPath)
		possiblePaths = append([]string{
			filepath.Join(execDir, "lang", langCode+".json"),
		}, possiblePaths...)
	}

	// Working directory'yi dene
	if workDir, err := os.Getwd(); err == nil {
		possiblePaths = append(possiblePaths, filepath.Join(workDir, "lang", langCode+".json"))
	}

	// İlk mevcut dosyayı bul
	for _, path := range possiblePaths {
		if _, err := os.Stat(path); err == nil {
			langFile = path
			break
		}
	}

	if langFile == "" {
		return fmt.Errorf("dil dosyası bulunamadı (%s), aranan yollar: %v", langCode, possiblePaths)
	}

	// Dosyayı oku
	data, err := os.ReadFile(langFile)
	if err != nil {
		return fmt.Errorf("dil dosyası okunamadı (%s): %v", langCode, err)
	}

	// JSON'u parse et
	var langData LangData
	err = json.Unmarshal(data, &langData)
	if err != nil {
		return fmt.Errorf("dil dosyası parse edilemedi: %v", err)
	}

	// Mesajları yükle
	lm.langData = langData.Messages
	lm.currentLang = langCode

	return nil
}

func (lm *LangManager) Get(key string, args ...interface{}) string {
	// Önce mevcut dilde dene
	if message, exists := lm.langData[key]; exists {
		if len(args) > 0 {
			return fmt.Sprintf(message, args...)
		}
		return message
	}

	// Mevcut dil İngilizce değilse İngilizce'den dene
	if lm.currentLang != "en" {
		// Yeni bir LangManager oluştur İngilizce için
		tempManager := &LangManager{
			currentLang: "en",
			langData:    make(map[string]string),
			configPath:  lm.configPath,
		}

		err := tempManager.LoadLanguage("en")
		if err == nil {
			if message, exists := tempManager.langData[key]; exists {
				if len(args) > 0 {
					return fmt.Sprintf(message, args...)
				}
				return message
			}
		}
	}

	// Hard-coded fallback mesajları
	fallbackMessages := map[string]string{
		"app_description":   "sysundo - Automatic backup tool for system file operations",
		"usage":             "Usage:",
		"watch_usage":       "sysundo watch <command> [arguments...]  - Execute command while backing up files",
		"undo_usage":        "sysundo undo                          - Restore last backups",
		"help_usage":        "sysundo help                          - Show this help text",
		"lang_usage":        "sysundo lang [language_code]          - Set language or show available languages",
		"examples":          "Examples:",
		"example_watch_rm":  "sysundo watch rm file.txt",
		"example_watch_mv":  "sysundo watch mv source.py target/",
		"example_watch_cp":  "sysundo watch cp *.json backup/",
		"example_undo":      "sysundo undo",
		"example_lang_set":  "sysundo lang tr",
		"example_lang_list": "sysundo lang",
		"unknown_command":   "Unknown command: %s",
		"error":             "Error: %v",
	}

	if message, exists := fallbackMessages[key]; exists {
		if len(args) > 0 {
			return fmt.Sprintf(message, args...)
		}
		return message
	}

	// Eğer hiç bulunamazsa anahtar ve argümanları döndür
	if len(args) > 0 {
		return fmt.Sprintf("[%s] %v", key, args)
	}
	return fmt.Sprintf("[%s]", key)
}

func (lm *LangManager) SetLanguage(langCode string) error {
	err := lm.LoadLanguage(langCode)
	if err != nil {
		return err
	}

	// Dil ayarını kaydet
	return lm.saveLangaugeConfig()
}

func (lm *LangManager) GetCurrentLanguage() string {
	return lm.currentLang
}

func (lm *LangManager) GetAvailableLanguages() ([]string, error) {
	var languages []string
	var langDir string

	// Farklı yolları sırayla deneyeceğiz
	possiblePaths := []string{
		"lang",
		filepath.Join(".", "lang"),
	}

	// Executable path'i dene
	if execPath, err := os.Executable(); err == nil {
		execDir := filepath.Dir(execPath)
		possiblePaths = append([]string{
			filepath.Join(execDir, "lang"),
		}, possiblePaths...)
	}

	// Working directory'yi dene
	if workDir, err := os.Getwd(); err == nil {
		possiblePaths = append(possiblePaths, filepath.Join(workDir, "lang"))
	}

	// İlk mevcut dizini bul
	for _, path := range possiblePaths {
		if info, err := os.Stat(path); err == nil && info.IsDir() {
			langDir = path
			break
		}
	}

	if langDir == "" {
		return nil, fmt.Errorf("lang dizini bulunamadı, aranan yollar: %v", possiblePaths)
	}

	// Lang dizinindeki dosyaları listele
	files, err := os.ReadDir(langDir)
	if err != nil {
		return nil, err
	}

	for _, file := range files {
		if !file.IsDir() && filepath.Ext(file.Name()) == ".json" {
			langCode := filepath.Base(file.Name())
			langCode = langCode[:len(langCode)-5] // .json uzantısını kaldır
			languages = append(languages, langCode)
		}
	}

	sort.Strings(languages)

	return languages, nil
}

// Sistem dilini algıla
func detectSystemLanguage() string {
	// LANG environment variable'ı kontrol et
	if lang := os.Getenv("LANG"); lang != "" {
		if len(lang) >= 2 {
			return lang[:2] // İlk 2 karakteri al (örn: tr_TR -> tr)
		}
	}

	// Windows için LANGUAGE kontrol et
	if lang := os.Getenv("LANGUAGE"); lang != "" {
		if len(lang) >= 2 {
			return lang[:2]
		}
	}

	return ""
}

// Global fonksiyonlar
func Get(key string, args ...interface{}) string {
	return globalLangManager.Get(key, args...)
}

func SetLanguage(langCode string) error {
	return globalLangManager.SetLanguage(langCode)
}

func GetCurrentLanguage() string {
	return globalLangManager.GetCurrentLanguage()
}

func GetAvailableLanguages() ([]string, error) {
	return globalLangManager.GetAvailableLanguages()
}
