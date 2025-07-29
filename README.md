# gitsync

A Termux-friendly script for syncing Git repositories between internal storage and Android shared storage.

## 💡 Why?

Android apps (e.g., editors like Acode, Turbo Editor) can only access files in shared storage (`/storage/emulated/0/GIT`), while Git operations (cloning, pulling, pushing) are more reliable inside Termux (`~/GIT`).  
This script bridges the two worlds:

- ✅ Full Git support in Termux
- ✅ Visibility and editing in Android apps
- ✅ No manual copying needed

## 🔄 What it does

- **Sync mode**: Compare a repo between Termux and Shared storage and let you:
  - Push Termux → Shared
  - Pull Shared → Termux
  - Skip
- **Mirror mode**: Overwrite the shared repo completely from the Termux version (preserves `.git`)
  - Auto-adds `safe.directory` to avoid Git's ownership warnings
  - Ensures Git works in Shared

## 🧪 How to use

1. Install the script into `~/bin/gitsync` and make it executable:
   ```bash
   chmod +x ~/bin/gitsync
   ```

2. Run:
   ```bash
   gitsync
   ```

3. Choose:
   - `M` = Mirror Termux → Shared
   - `S` = Interactive Sync (compare and choose)

## 🔐 Notes

- If using shared storage for Git, Git may warn about "dubious ownership". This script auto-whitelists the directory.
- Safe for push/pull across Termux and GitHub with token authentication.

## 🛠 Requirements

- Git installed in Termux
- GitHub repo with token access
- Android file access permissions granted to Termux

---

Happy syncing!
