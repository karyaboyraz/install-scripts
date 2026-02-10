# Kurulum Script'leri

Ekip için tek komutla kurulum script'leri.

## Appium Kurulumu

### macOS
```bash
curl -fsSL https://raw.githubusercontent.com/karyaboyraz/install-scripts/main/appium.sh | bash
```

### Windows (PowerShell - Admin olarak çalıştır)
```powershell
irm https://raw.githubusercontent.com/karyaboyraz/install-scripts/main/appium.ps1 | iex
```

## Kurulum içeriği

| Bileşen | macOS | Windows |
|---------|-------|---------|
| Homebrew / Chocolatey | ✅ | ✅ |
| Node.js | ✅ | ✅ |
| Java JDK 17 | ✅ | ✅ |
| Android SDK | ✅ | ✅ |
| Xcode CLI Tools | ✅ | ❌ |
| Appium | ✅ | ✅ |
| UiAutomator2 Driver | ✅ | ✅ |
| XCUITest Driver | ✅ | ❌ |
| Appium Doctor | ✅ | ✅ |

## Kurulum sonrası

```bash
# Kurulumu doğrula
appium-doctor

# Appium'u başlat
appium
```
