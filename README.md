# reset-applock

![Platform](https://img.shields.io/badge/platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Tested](https://img.shields.io/badge/tested-MIUI%2014%20%2F%20HyperOS%201%2B2-blue?style=flat-square)
![Android](https://img.shields.io/badge/Android-13%20to%2016-3DDC84?style=flat-square)
![No Root](https://img.shields.io/badge/root-not%20required-success?style=flat-square)
![ADB](https://img.shields.io/badge/requires-ADB-orange?style=flat-square)
![Shell](https://img.shields.io/badge/shell-bash-lightgrey?style=flat-square&logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-informational?style=flat-square)

Clears Xiaomi and HyperOS App Lock via ADB secure settings. No root, no third-party apps.

## Background

Xiaomi's App Lock is not backed by an encrypted password hash. It is a set of boolean flags stored in Android's secure settings namespace. With ADB access you write them to `0` and the lock is gone. No brute force, no exploit, no APK.

The relevant keys:

```
privacy_password_is_open       # main on/off flag
access_control_lock_enabled    # access control gate
app_lock_enabled               # alternate name on older MIUI builds
miui_privacy_password_open     # alternate name on older MIUI builds
```

## Requirements

- USB Debugging enabled (Settings > Additional Settings > Developer Options)
- **USB Debugging (Security Settings)** enabled, separate toggle on the same screen. Without this, `settings put secure` will fail silently or return `Permission denied`
- ADB on your machine (`sudo apt install adb` / `sudo pacman -S android-tools` / [platform-tools](https://developer.android.com/studio/releases/platform-tools))
- Screen unlocked (face unlock works)

## Usage

```bash
bash reset-applock.sh
```

The script will:
1. Verify ADB is installed and a device is authorized
2. Write all four keys to `0` via `settings put secure`, escalating through `pm grant` if the first attempt is denied
3. Prompt to reboot

Prefer to run it manually:

```bash
adb shell settings put secure privacy_password_is_open 0
adb shell settings put secure access_control_lock_enabled 0
adb shell settings put secure app_lock_enabled 0
adb shell settings put secure miui_privacy_password_open 0
adb reboot
```

## Troubleshooting

**`Permission denied` even after `pm grant`**
Some HyperOS builds block `WRITE_SECURE_SETTINGS` at ROM policy level regardless of ADB session type. No workaround without root.

**Device stays `unauthorized`**
Developer Options > Revoke USB debugging authorizations, reconnect, accept the dialog on the phone.

**Device shows as `temporarily restricted`**
Settings > Apps > Restrictions > Allow restricted settings.

**`adb reboot` hangs**
Safe to Ctrl-C, reboot manually.

## After Reboot

App Lock is disabled. Go to Settings > Apps > App Lock to set a new PIN or disable the feature entirely.

This clears the lock state, it does not recover the original password. The flag does not store it, there is nothing to recover.

## Author

José for 
[schalt-werk.com](https://schalt-werk.com)

---

Need IT Services ?  Get in touch -> [schalt-werk.com](https://schalt-werk.com)
