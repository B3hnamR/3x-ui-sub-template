#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_URL="https://raw.githubusercontent.com/B3hnamR/3x-ui-sub-template/main/index.html"
INSTALL_DIR="/etc/3x-ui/sub_templates/my-theme"
MIN_VERSION="3.3.0"   # custom sub templates landed in 3x-ui v3.3.0 (PR #5079)
XUI_BIN="/usr/local/x-ui/x-ui"

# ── colors ────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' B='\033[1m' N='\033[0m'

clear
echo -e "${C}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     3x-ui Subscription Template Setup    ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${N}"

ask() {
  local prompt="$1" default="$2" var
  echo -ne "${B}${prompt}${N} ${Y}[${default}]${N}: " >&2
  read -r var
  echo "${var:-$default}"
}

# ── detect 3x-ui ──────────────────────────────────────────────────────
if [[ ! -x "$XUI_BIN" ]] && ! command -v x-ui >/dev/null 2>&1; then
  echo -e "${R}  ✖ 3x-ui is not installed on this server.${N}"
  echo -e "    Install it first: ${C}https://github.com/MHSanaei/3x-ui${N}"
  exit 1
fi

PANEL_VERSION=""
if [[ -x "$XUI_BIN" ]]; then
  PANEL_VERSION=$("$XUI_BIN" -v 2>/dev/null | head -1 | tr -dc '0-9.')
fi

if [[ -n "$PANEL_VERSION" ]]; then
  if [[ "$(printf '%s\n%s\n' "$MIN_VERSION" "$PANEL_VERSION" | sort -V | head -1)" != "$MIN_VERSION" ]]; then
    echo -e "${R}  ✖ 3x-ui v${PANEL_VERSION} detected — custom templates need v${MIN_VERSION}+.${N}"
    echo -e "    Update the panel first: run ${C}x-ui${N} and choose Update."
    exit 1
  fi
  echo -e "${G}  ✔ 3x-ui v${PANEL_VERSION} detected (templates supported)${N}"
else
  echo -e "${Y}  ⚠ 3x-ui found, but version could not be determined.${N}"
  echo -e "    Custom templates require v${MIN_VERSION}+ — continuing anyway."
fi
echo

echo -e "${C}── Customize ─────────────────────────────────────────────────────${N}"
BRAND=$(ask    "Brand name (shown when panel Sub Title is empty)" "My VPN")
CHANNEL=$(ask  "Telegram channel URL (leave blank to hide button)" "")
SUPPORT=$(ask  "Support URL fallback (leave blank to hide button)" "")
DLANG=$(ask    "Default language  fa / en / auto" "auto")

# validate lang
if [[ "$DLANG" != "fa" && "$DLANG" != "en" && "$DLANG" != "auto" ]]; then
  echo -e "${R}  Invalid language. Using 'auto'.${N}"
  DLANG="auto"
fi
echo

# ── download ──────────────────────────────────────────────────────────
echo -e "${Y}▸ Downloading template...${N}"
TMP=$(mktemp)
curl -fsSL "$TEMPLATE_URL" -o "$TMP"

# ── apply replacements ────────────────────────────────────────────────
esc() { printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'; }
BRAND_E=$(esc "$BRAND"); CHANNEL_E=$(esc "$CHANNEL"); SUPPORT_E=$(esc "$SUPPORT")

sed -i \
  "s|brandName: \"YOUR_BRAND_NAME\"|brandName: \"${BRAND_E}\"|g" \
  "$TMP"

if [[ -n "$CHANNEL" ]]; then
  sed -i "s|telegramChannel: \"https://t.me/YOUR_CHANNEL\"|telegramChannel: \"${CHANNEL_E}\"|g" "$TMP"
else
  sed -i "s|telegramChannel: \"https://t.me/YOUR_CHANNEL\"|telegramChannel: \"\"|g" "$TMP"
fi

if [[ -n "$SUPPORT" ]]; then
  sed -i "s|supportFallback: \"https://t.me/YOUR_SUPPORT\"|supportFallback: \"${SUPPORT_E}\"|g" "$TMP"
else
  sed -i "s|supportFallback: \"https://t.me/YOUR_SUPPORT\"|supportFallback: \"\"|g" "$TMP"
fi

sed -i "s|defaultLang: \"auto\"|defaultLang: \"${DLANG}\"|g" "$TMP"

# ── install ───────────────────────────────────────────────────────────
echo -e "${Y}▸ Installing to ${INSTALL_DIR}...${N}"
sudo mkdir -p "$INSTALL_DIR"

# backup existing template if present
if [[ -f "${INSTALL_DIR}/index.html" ]]; then
  BACKUP="${INSTALL_DIR}/index.html.bak.$(date +%Y%m%d_%H%M%S)"
  sudo cp "${INSTALL_DIR}/index.html" "$BACKUP"
  echo -e "${Y}  ↳ Backup saved: ${BACKUP}${N}"
fi

sudo cp "$TMP" "${INSTALL_DIR}/index.html"
sudo chmod 755 "$INSTALL_DIR"
sudo chmod 644 "${INSTALL_DIR}/index.html"
rm -f "$TMP"

# ── done ──────────────────────────────────────────────────────────────
echo
echo -e "${G}  ✔ Template installed successfully!${N}"
echo
echo -e "${B}  Panel setting:${N}"
echo -e "  Settings → Subscription → Information → Sub Theme Directory"
echo -e "  ${C}${INSTALL_DIR}/${N}"
echo
echo -e "${B}  Preview your page:${N}"
echo -e "  ${C}https://your-domain:2096/sub/SUB_ID?html=1${N}"
echo
