#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_URL="https://raw.githubusercontent.com/B3hnamR/3x-ui-sub-template/main/index.html"
INSTALL_DIR="/etc/3x-ui/sub_templates/my-theme"
MIN_VERSION="3.3.0"   # custom sub templates landed in 3x-ui v3.3.0 (PR #5079)
LIVE_VERSION="3.6.0"  # {{ .isOnline }} + ?format=info landed in v3.6.0
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

# true when $1 is strictly older than $2
version_lt() { [[ "$1" != "$2" && "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" == "$1" ]]; }

RAW_VERSION=""
PANEL_VERSION=""
if [[ -x "$XUI_BIN" ]]; then
  RAW_VERSION=$("$XUI_BIN" -v 2>/dev/null | head -1 | tr -d '[:space:]')
fi
# dev builds report "dev+<sha>" — only treat a real x.y.z as a comparable version
if [[ "$RAW_VERSION" =~ ^v?([0-9]+\.[0-9]+(\.[0-9]+)?) ]]; then
  PANEL_VERSION="${BASH_REMATCH[1]}"
fi

if [[ -n "$PANEL_VERSION" ]]; then
  if version_lt "$PANEL_VERSION" "$MIN_VERSION"; then
    echo -e "${R}  ✖ 3x-ui v${PANEL_VERSION} detected — custom templates need v${MIN_VERSION}+.${N}"
    echo -e "    Update the panel first: run ${C}x-ui${N} and choose Update."
    exit 1
  fi
  echo -e "${G}  ✔ 3x-ui v${PANEL_VERSION} detected (templates supported)${N}"
  if version_lt "$PANEL_VERSION" "$LIVE_VERSION"; then
    echo -e "${Y}  ⚠ Live online/offline badge needs v${LIVE_VERSION}+ — it will show 'offline' on this panel.${N}"
    echo -e "    Everything else works. Update the panel to enable it."
  fi
elif [[ -n "$RAW_VERSION" ]]; then
  echo -e "${Y}  ⚠ 3x-ui reports '${RAW_VERSION}' (dev build?) — skipping the version check.${N}"
  echo -e "    Custom templates require v${MIN_VERSION}+ — continuing anyway."
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

# the panel prefers sub.html over index.html — move any stray one aside
if [[ -f "${INSTALL_DIR}/sub.html" ]]; then
  SHADOW="${INSTALL_DIR}/sub.html.bak.$(date +%Y%m%d_%H%M%S)"
  sudo mv "${INSTALL_DIR}/sub.html" "$SHADOW"
  echo -e "${Y}  ↳ Existing sub.html would shadow index.html — moved to: ${SHADOW}${N}"
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
if [[ -n "$PANEL_VERSION" ]] && version_lt "$PANEL_VERSION" "3.6.0"; then
  echo -e "  Settings → Subscription → Information → Sub Theme Directory"
else
  echo -e "  Settings → Subscription → Profile → Sub Theme Directory"
fi
echo -e "  ${C}${INSTALL_DIR}/${N}"
echo -e "  Save, then restart the panel."
echo
echo -e "${B}  Preview your page:${N}"
echo -e "  ${C}https://your-domain:2096/sub/SUB_ID${N}"
echo -e "  (browsers get it automatically; add ${C}?html=1${N} to force it from curl)"
echo
