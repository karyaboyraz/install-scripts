#!/bin/bash
#
# Appium Kurulum Script'i - macOS
# Kullanım: curl -fsSL https://raw.githubusercontent.com/karyaboyraz/install-scripts/main/appium.sh | bash
#
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 Appium Kurulum Script'i (macOS)     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# OS kontrolü
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "Bu script sadece macOS için. Windows için: irm https://raw.githubusercontent.com/karyaboyraz/install-scripts/main/appium.sh.ps1 | iex"
    exit 1
fi

# ============================================
# 1. HOMEBREW
# ============================================
log_info "Homebrew kontrol ediliyor..."
if ! command -v brew &> /dev/null; then
    log_warn "Homebrew bulunamadı, kuruluyor..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # M1/M2/M3 Mac için PATH ayarı
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    log_success "Homebrew kuruldu"
else
    log_success "Homebrew mevcut: $(brew --version | head -1)"
fi

# ============================================
# 2. NODE.JS
# ============================================
log_info "Node.js kontrol ediliyor..."
if ! command -v node &> /dev/null; then
    log_warn "Node.js bulunamadı, kuruluyor..."
    brew install node
    log_success "Node.js kuruldu"
else
    log_success "Node.js mevcut: $(node --version)"
fi

# ============================================
# 3. JAVA JDK
# ============================================
log_info "Java JDK kontrol ediliyor..."
if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "version"; then
    log_warn "Java bulunamadı, kuruluyor..."
    brew install openjdk@17
    
    # JAVA_HOME ayarla
    JAVA_PATH="$(brew --prefix openjdk@17)"
    sudo ln -sfn "$JAVA_PATH/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-17.jdk
    
    echo "export JAVA_HOME=\"$JAVA_PATH\"" >> ~/.zshrc
    echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.zshrc
    export JAVA_HOME="$JAVA_PATH"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    log_success "Java 17 kuruldu"
else
    log_success "Java mevcut: $(java -version 2>&1 | head -1)"
fi

# ============================================
# 4. ANDROID SDK
# ============================================
log_info "Android SDK kontrol ediliyor..."
if [[ -z "$ANDROID_HOME" ]] || [[ ! -d "$ANDROID_HOME" ]]; then
    log_warn "Android SDK bulunamadı, kuruluyor..."
    
    brew install --cask android-commandlinetools
    
    ANDROID_HOME="$HOME/Library/Android/sdk"
    mkdir -p "$ANDROID_HOME"
    
    # Environment variables
    {
        echo ""
        echo "# Android SDK"
        echo "export ANDROID_HOME=\"$ANDROID_HOME\""
        echo "export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH\""
    } >> ~/.zshrc
    
    export ANDROID_HOME="$ANDROID_HOME"
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
    
    # SDK bileşenlerini kur
    CMDLINE_TOOLS="/opt/homebrew/share/android-commandlinetools"
    if [[ -d "$CMDLINE_TOOLS" ]]; then
        yes | "$CMDLINE_TOOLS/bin/sdkmanager" --sdk_root="$ANDROID_HOME" "platform-tools" "platforms;android-34" "build-tools;34.0.0" "cmdline-tools;latest" 2>/dev/null || true
    fi
    
    log_success "Android SDK kuruldu"
else
    log_success "Android SDK mevcut: $ANDROID_HOME"
fi

# ============================================
# 5. XCODE COMMAND LINE TOOLS
# ============================================
log_info "Xcode Command Line Tools kontrol ediliyor..."
if ! xcode-select -p &> /dev/null; then
    log_warn "Xcode CLT bulunamadı, kuruluyor..."
    xcode-select --install
    log_warn "Xcode Command Line Tools kurulum penceresi açıldı. Kurulum bittikten sonra script'i tekrar çalıştırın."
    exit 0
else
    log_success "Xcode CLT mevcut: $(xcode-select -p)"
fi

# ============================================
# 6. APPIUM
# ============================================
log_info "Appium kontrol ediliyor..."
if ! command -v appium &> /dev/null; then
    log_warn "Appium bulunamadı, kuruluyor..."
    npm install -g appium
    log_success "Appium kuruldu"
else
    log_success "Appium mevcut: $(appium --version)"
fi

# ============================================
# 7. APPIUM DRIVERS
# ============================================
log_info "Appium driver'ları kuruluyor..."

# UiAutomator2 (Android)
if ! appium driver list --installed 2>/dev/null | grep -q "uiautomator2"; then
    appium driver install uiautomator2
    log_success "UiAutomator2 driver kuruldu"
else
    log_success "UiAutomator2 driver mevcut"
fi

# XCUITest (iOS)
if ! appium driver list --installed 2>/dev/null | grep -q "xcuitest"; then
    appium driver install xcuitest
    log_success "XCUITest driver kuruldu"
else
    log_success "XCUITest driver mevcut"
fi

# ============================================
# 8. APPIUM DOCTOR
# ============================================
log_info "Appium Doctor kuruluyor..."
if ! command -v appium-doctor &> /dev/null; then
    npm install -g @appium/doctor
    log_success "Appium Doctor kuruldu"
else
    log_success "Appium Doctor mevcut"
fi

# ============================================
# ÖZET
# ============================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✅ Kurulum Tamamlandı!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Kurulum doğrulamak için: ${YELLOW}appium-doctor${NC}"
echo -e "Appium başlatmak için:   ${YELLOW}appium${NC}"
echo ""
echo -e "${BLUE}Önemli:${NC} Yeni terminal açın veya şunu çalıştırın:"
echo -e "  ${YELLOW}source ~/.zshrc${NC}"
echo ""
