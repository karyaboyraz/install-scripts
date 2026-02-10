#
# Appium Kurulum Script'i - Windows
# Kullanım: irm https://raw.githubusercontent.com/karyaboyraz/install-scripts/main/appium.ps1 | iex
#
# Requires: PowerShell 5.1+ (Run as Administrator recommended)
#

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Success { param($msg) Write-Host "[✓] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "[✗] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║    🚀 Appium Kurulum Script'i (Windows)    ║" -ForegroundColor Blue  
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Admin kontrolü
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warn "Administrator olarak çalıştırmanız önerilir."
    Write-Warn "Devam etmek için Enter'a basın veya Ctrl+C ile iptal edin..."
    Read-Host
}

# ============================================
# 1. CHOCOLATEY
# ============================================
Write-Info "Chocolatey kontrol ediliyor..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Warn "Chocolatey bulunamadı, kuruluyor..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Success "Chocolatey kuruldu"
} else {
    Write-Success "Chocolatey mevcut"
}

# ============================================
# 2. NODE.JS
# ============================================
Write-Info "Node.js kontrol ediliyor..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Warn "Node.js bulunamadı, kuruluyor..."
    choco install nodejs-lts -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Success "Node.js kuruldu"
} else {
    $nodeVersion = node --version
    Write-Success "Node.js mevcut: $nodeVersion"
}

# ============================================
# 3. JAVA JDK
# ============================================
Write-Info "Java JDK kontrol ediliyor..."
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Warn "Java bulunamadı, kuruluyor..."
    choco install openjdk17 -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # JAVA_HOME ayarla
    $javaPath = "C:\Program Files\OpenJDK\jdk-17"
    if (Test-Path $javaPath) {
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
        $env:JAVA_HOME = $javaPath
    }
    Write-Success "Java 17 kuruldu"
} else {
    Write-Success "Java mevcut"
}

# ============================================
# 4. ANDROID SDK
# ============================================
Write-Info "Android SDK kontrol ediliyor..."
$androidHome = $env:ANDROID_HOME
if (-not $androidHome -or -not (Test-Path $androidHome)) {
    Write-Warn "Android SDK bulunamadı, kuruluyor..."
    
    # Android Command Line Tools indir
    $sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
    $cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $zipPath = "$env:TEMP\cmdline-tools.zip"
    
    New-Item -ItemType Directory -Force -Path $sdkPath | Out-Null
    
    Write-Info "Android Command Line Tools indiriliyor..."
    Invoke-WebRequest -Uri $cmdlineToolsUrl -OutFile $zipPath
    
    Write-Info "Çıkartılıyor..."
    Expand-Archive -Path $zipPath -DestinationPath "$sdkPath\cmdline-tools-temp" -Force
    
    # Doğru klasör yapısına taşı
    New-Item -ItemType Directory -Force -Path "$sdkPath\cmdline-tools\latest" | Out-Null
    Move-Item -Path "$sdkPath\cmdline-tools-temp\cmdline-tools\*" -Destination "$sdkPath\cmdline-tools\latest" -Force
    Remove-Item -Path "$sdkPath\cmdline-tools-temp" -Recurse -Force
    Remove-Item -Path $zipPath -Force
    
    # Environment variables
    [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
    $env:ANDROID_HOME = $sdkPath
    
    $newPath = "$sdkPath\cmdline-tools\latest\bin;$sdkPath\platform-tools;$sdkPath\emulator"
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$sdkPath*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$newPath", "User")
    }
    $env:Path = "$env:Path;$newPath"
    
    # SDK bileşenlerini kur
    Write-Info "SDK bileşenleri kuruluyor (bu biraz zaman alabilir)..."
    $sdkmanager = "$sdkPath\cmdline-tools\latest\bin\sdkmanager.bat"
    if (Test-Path $sdkmanager) {
        echo "y" | & $sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" 2>$null
    }
    
    Write-Success "Android SDK kuruldu: $sdkPath"
} else {
    Write-Success "Android SDK mevcut: $androidHome"
}

# ============================================
# 5. APPIUM
# ============================================
Write-Info "Appium kontrol ediliyor..."
if (-not (Get-Command appium -ErrorAction SilentlyContinue)) {
    Write-Warn "Appium bulunamadı, kuruluyor..."
    npm install -g appium
    Write-Success "Appium kuruldu"
} else {
    $appiumVersion = appium --version
    Write-Success "Appium mevcut: $appiumVersion"
}

# ============================================
# 6. APPIUM DRIVERS
# ============================================
Write-Info "Appium driver'ları kuruluyor..."

# UiAutomator2 (Android)
$installedDrivers = appium driver list --installed 2>$null
if ($installedDrivers -notmatch "uiautomator2") {
    appium driver install uiautomator2
    Write-Success "UiAutomator2 driver kuruldu"
} else {
    Write-Success "UiAutomator2 driver mevcut"
}

# Not: XCUITest Windows'ta çalışmaz (sadece macOS)
Write-Info "XCUITest driver sadece macOS'ta desteklenir, atlanıyor."

# ============================================
# 7. APPIUM DOCTOR
# ============================================
Write-Info "Appium Doctor kuruluyor..."
if (-not (Get-Command appium-doctor -ErrorAction SilentlyContinue)) {
    npm install -g @appium/doctor
    Write-Success "Appium Doctor kuruldu"
} else {
    Write-Success "Appium Doctor mevcut"
}

# ============================================
# ÖZET
# ============================================
Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         ✅ Kurulum Tamamlandı!             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Kurulum doğrulamak için: " -NoNewline; Write-Host "appium-doctor" -ForegroundColor Yellow
Write-Host "Appium başlatmak için:   " -NoNewline; Write-Host "appium" -ForegroundColor Yellow
Write-Host ""
Write-Host "Önemli: " -ForegroundColor Blue -NoNewline
Write-Host "Yeni PowerShell penceresi açın veya bilgisayarı yeniden başlatın."
Write-Host ""
