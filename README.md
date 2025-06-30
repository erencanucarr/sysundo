# sysundo - Sistem Dosya İşlemleri Yedekleme Aracı

`sysundo`, Linux sistemlerde dosya işlemlerini (rm, mv, cp) gerçekleştirmeden önce otomatik yedekleme yapan ve gerektiğinde geri yükleme imkanı sunan bir CLI aracıdır.

## Özellikler

- **Otomatik Yedekleme**: `rm`, `mv`, `cp` komutları çalıştırılmadan önce etkilenen dosyaları otomatik olarak yedekler
- **Akıllı Filtreleme**: Sadece desteklenen dosya türlerini (.txt, .md, .json, .yaml, .yml, .sh, .js, .py) yedekler
- **Boyut Sınırı**: Maksimum 10MB boyutundaki dosyaları yedekler
- **Geri Yükleme**: Son yedeklenen dosyaları tek komutla geri yükler
- **Güvenli Depolama**: Yedekler kullanıcının ev dizininde `.sysundo/cache` klasöründe saklanır

## Kurulum

```bash
# Projeyi derle
go build -o sysundo

# Binary'yi PATH'e ekle (isteğe bağlı)
sudo cp sysundo /usr/local/bin/
```

## Kullanım

### Watch Modu
Dosya işlemlerini yedekleme ile birlikte gerçekleştir:

```bash
# Dosya silme işlemi ile birlikte yedekleme
sysundo watch rm dosya.txt

# Dosya taşıma işlemi ile birlikte yedekleme  
sysundo watch mv kaynak.py hedef/

# Dosya kopyalama işlemi ile birlikte yedekleme
sysundo watch cp *.json backup/

# Wildcard kullanımı
sysundo watch rm *.py
```

### Undo Modu
Son yedeklenen dosyaları geri yükle:

```bash
sysundo undo
```

### Yardım
```bash
sysundo help
```

## Desteklenen Dosya Türleri

- `.txt` - Metin dosyaları
- `.md` - Markdown dosyaları  
- `.json` - JSON dosyaları
- `.yaml`, `.yml` - YAML dosyaları
- `.sh` - Shell script dosyaları
- `.js` - JavaScript dosyaları
- `.py` - Python dosyaları

## Yedekleme Mekanizması

1. **Yedekleme Dizini**: Yedekler `~/.sysundo/cache/` dizininde saklanır
2. **Dosya Adlandırma**: `YYYYMMDD_HHMMSS_dosyaadi_ID` formatında adlandırılır
3. **Metadata**: Son yedekleme bilgileri `last_backup.json` dosyasında tutulur
4. **Geri Yükleme**: Dosyalar orijinal konumlarına izinleri korunarak geri yüklenir

## Sınırlamalar

- Maksimum dosya boyutu: 10MB
- Sadece belirtilen dosya türleri yedeklenir
- Dizinler yedeklenmez (sadece dosyalar)
- Binary dosyalar (.mp4, .zip, .tar, .gz) otomatik olarak hariç tutulur

## Örnek Kullanım Senaryoları

```bash
# Önemli script dosyalarını yedekleyerek sil
sysundo watch rm cleanup.sh setup.py

# Konfigürasyon dosyalarını güvenli şekilde taşı
sysundo watch mv config.json backup/

# Eğer bir hata yapıldıysa geri yükle
sysundo undo
```

## Proje Yapısı

- `main.go` - Ana CLI uygulaması ve komut yönetimi
- `watcher.go` - Dosya izleme ve komut çalıştırma mantığı
- `backup.go` - Dosya yedekleme işlemleri
- `restorer.go` - Dosya geri yükleme işlemleri

## Geliştirme

Proje tamamen Go standart kütüphaneleri kullanılarak geliştirilmiştir. Herhangi bir dış bağımlılık bulunmamaktadır.

```bash
# Test et
go run . help

# Derle
go build -o sysundo
``` 