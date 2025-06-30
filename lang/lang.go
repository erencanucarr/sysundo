package lang

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type LangManager struct {
	currentLang string
	langData    map[string]string
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

var globalLangManager *LangManager

func init() {
	globalLangManager = &LangManager{
		currentLang: "en", // Varsayılan dil İngilizce
		langData:    make(map[string]string),
	}

	// Sistem dilini otomatik algıla
	if systemLang := detectSystemLanguage(); systemLang != "" {
		globalLangManager.currentLang = systemLang
	}

	// Dil dosyasını yükle
	err := globalLangManager.LoadLanguage(globalLangManager.currentLang)
	if err != nil {
		// Eğer sistem dili yüklenemezse İngilizce'ye geri dön
		globalLangManager.currentLang = "en"
		globalLangManager.LoadLanguage("en")
	}
}

func (lm *LangManager) LoadLanguage(langCode string) error {
	// Çalıştırılabilir dosyanın bulunduğu dizini bul
	execPath, err := os.Executable()
	if err != nil {
		execPath = "."
	}
	execDir := filepath.Dir(execPath)

	// Lang dosyasının yolunu oluştur
	langFile := filepath.Join(execDir, "lang", langCode+".json")

	// Eğer executable yanında yoksa, kaynak kodun yanına bak
	if _, err := os.Stat(langFile); os.IsNotExist(err) {
		langFile = filepath.Join("lang", langCode+".json")
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
	if message, exists := lm.langData[key]; exists {
		if len(args) > 0 {
			return fmt.Sprintf(message, args...)
		}
		return message
	}

	// Eğer mesaj bulunamazsa anahtar ve argümanları döndür
	if len(args) > 0 {
		return fmt.Sprintf("[%s] %v", key, args)
	}
	return fmt.Sprintf("[%s]", key)
}

func (lm *LangManager) SetLanguage(langCode string) error {
	return lm.LoadLanguage(langCode)
}

func (lm *LangManager) GetCurrentLanguage() string {
	return lm.currentLang
}

func (lm *LangManager) GetAvailableLanguages() ([]string, error) {
	var languages []string

	// Çalıştırılabilir dosyanın bulunduğu dizini bul
	execPath, err := os.Executable()
	if err != nil {
		execPath = "."
	}
	execDir := filepath.Dir(execPath)

	// Lang dizinini kontrol et
	langDir := filepath.Join(execDir, "lang")
	if _, err := os.Stat(langDir); os.IsNotExist(err) {
		langDir = "lang"
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
