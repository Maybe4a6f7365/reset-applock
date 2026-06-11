#!/usr/bin/env bash
# Clears Xiaomi/HyperOS App Lock via ADB secure settings.
# Tested on MIUI 14 / HyperOS 1-2, Android 13-16.
# Requires USB debugging + USB debugging (Security Settings) both enabled.
set -euo pipefail

RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'
ok()   { echo -e "${GRN}[✓]${RST} $*"; }
info() { echo -e "${CYN}[·]${RST} $*"; }
warn() { echo -e "${YLW}[!]${RST} $*"; }
die()  { echo -e "${RED}[✗]${RST} $*" >&2; exit 1; }

secure_put() {
    local key="$1" val="$2"
    adb shell settings put secure "$key" "$val" 2>/dev/null && { ok "secure/$key = $val"; return; }
    warn "secure/$key denied — trying pm grant"
    adb shell pm grant android.permission.WRITE_SECURE_SETTINGS 2>/dev/null || true
    adb shell settings put secure "$key" "$val" 2>/dev/null && { ok "secure/$key = $val"; return; }
    return 1
}

secure_put_optional() {
    adb shell settings put secure "$1" "$2" 2>/dev/null && ok "secure/$1 = $2" || info "secure/$1 not on this ROM — skip"
}

echo -e "\n${BLD}reset-applock${RST}\n"

command -v adb &>/dev/null || die "adb not in PATH.
  Debian/Ubuntu : sudo apt install adb
  Arch          : sudo pacman -S android-tools
  Manual        : https://developer.android.com/studio/releases/platform-tools"

info "$(adb version | head -1)"

DEVICES=$(adb devices | tail -n +2 | grep -v '^$')
[[ -z "$DEVICES" ]] && die "no device — USB cable? USB debugging enabled? Security settings toggle?"
echo "$DEVICES" | grep -q 'unauthorized' && die "unauthorized — accept the ADB dialog on the phone"

COUNT=$(echo "$DEVICES" | wc -l)
ok "$COUNT device(s):"; echo "$DEVICES" | awk '{print "    "$0}'; echo ""
[[ "$COUNT" -gt 1 ]] && warn "multiple devices — set ANDROID_SERIAL to pin one"

secure_put "privacy_password_is_open"    0 || die "write failed — see troubleshooting below"
secure_put "access_control_lock_enabled" 0 || die "write failed — see troubleshooting below"

# alternate key names on older MIUI builds
secure_put_optional "app_lock_enabled"           0
secure_put_optional "miui_privacy_password_open" 0

echo ""
read -rp "Reboot now? [Y/n] " REPLY; REPLY="${REPLY:-Y}"
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    adb reboot && ok "rebooting — App Lock will be gone on next boot"
else
    warn "reboot skipped — changes apply on next restart"
fi

echo ""
cat <<'EOF'
Troubleshooting
  still denied after grant  →  ROM security policy blocks WRITE_SECURE_SETTINGS; no workaround without root
  stays unauthorized        →  Developer Options → Revoke USB debugging authorizations, reconnect
  device restricted         →  Settings → Apps → Restrictions → Allow restricted settings
  adb reboot hangs          →  safe to Ctrl-C, reboot manually
EOF
