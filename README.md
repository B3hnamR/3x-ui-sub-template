# 3x-ui 3D Subscription Template

A modern, self-contained subscription page template for [3x-ui](https://github.com/MHSanaei/3x-ui) — glassmorphism cards, 3D tilt, animated 3D background, circular usage gauge, QR code, one-tap app import, and full **Persian (فارسی) / English** support with RTL/LTR switching.

![Showcase](showcase.png)

## Features

- 🌐 FA / EN toggle (saved in the browser), automatic RTL/LTR
- 🌓 Auto dark / light theme (follows the device)
- 🧊 3D floating background scene + mouse-tilt cards (pure CSS/JS, no libraries)
- 📊 Circular usage gauge, days-remaining countdown, upload/download/total/remaining stats
- 📅 Jalali (شمسی) dates in Persian mode, Gregorian in English
- 🔗 Copy buttons for subscription / JSON / Clash links + QR code (generator embedded — works offline/with blocked CDNs)
- 📱 One-tap import: v2rayNG, Hiddify, Streisand, Shadowrocket, Happ, FlClash (editable list)
- 🟢 Live online/offline status badge — auto-refreshes every 30s via the panel's `?format=info` endpoint
- 📢 Announcement banner, support button, per-config list with copy
- 📦 Single `index.html` file — no assets, no build step

## Install

> **Requires 3x-ui v3.3.0+** (custom subscription templates were added in [v3.3.0](https://github.com/MHSanaei/3x-ui/releases/tag/v3.3.0)). The live online/offline badge uses the `?format=info` endpoint from newer builds — on older panels the badge simply shows the render-time status.

**One-liner** — paste this on your server (replace the URL if you forked the repo):

```bash
sudo mkdir -p /etc/3x-ui/sub_templates/my-theme && sudo curl -fsSL https://raw.githubusercontent.com/B3hnamR/3x-ui-sub-template/main/index.html -o /etc/3x-ui/sub_templates/my-theme/index.html && sudo chmod 755 /etc/3x-ui/sub_templates /etc/3x-ui/sub_templates/my-theme && sudo chmod 644 /etc/3x-ui/sub_templates/my-theme/index.html
```

**Or use the interactive setup script** — detects your 3x-ui installation and version, asks for your brand name, Telegram channel, support link, and language, then installs and backs up any existing template automatically:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/B3hnamR/3x-ui-sub-template/main/install.sh)
```

The script asks a few questions, downloads the template, fills in your answers, backs up any existing `index.html` in the theme folder, and installs. Run it again anytime to reconfigure — it always backs up before replacing.

Then in the panel: **Settings → Subscription → Information → Sub Theme Directory**

```
/etc/3x-ui/sub_templates/my-theme/
```

Save and restart the panel, then open your sub link with `?html=1` to see the page:

```
https://your-domain:2096/sub/SUB_ID?html=1
```

## Customize

Everything lives at the top of `index.html`:

- **`CONFIG`** (in the first `<script>`): brand name, Telegram channel, support-link fallback, default language, and the app deep-link list (with per-OS visibility). Placeholders like `YOUR_BRAND_NAME` / `YOUR_CHANNEL` — just replace them.
- **`EDIT ME` CSS block**: `--accent`, `--accent-2` and status colors.

The brand name is only used when the panel's *Sub Title* is empty — set the title in the panel and it takes over automatically.

## 💖 Support the project

If this template has been useful to you, donations help fund ongoing development, testing, and maintenance.

| Asset / network | Donation address |
|---|---|
| TRON | `TVEKp9cAU97PGfvWse7BxseeiwfCVyRef4` |
| USDT - TRC20 | `TVEKp9cAU97PGfvWse7BxseeiwfCVyRef4` |
| USDT - BEP20 | `0x34E90a9476028F15064EE8fa6aa7c1b4dDE3f480` |
| TON | `UQAuXUNyd4Sfvhm59Ef27UNC46oEBrVys5Ud7VLzqZOj5O13` |

> ⚠️ **Important:** Please verify both the asset and network before sending. Blockchain transfers are irreversible.
