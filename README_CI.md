# GitHub Actions — Android APK CI

This pack gives you two workflows:

1. **Android APK (Debug)** — Builds an unsigned **debug** APK for every push/PR to `main` (or on manual run).  
   Artifact: `app-debug-apk`.

2. **Android APK (Release, Signed)** — Builds a **signed release** APK when you push a tag like `v1.2.3` (or on manual run).  
   Artifact: `app-release-apk`.

## Usage

1. Copy the `.github/workflows/*.yml` files into your repository root.
2. Commit + push. GitHub Actions will run automatically.

### Secrets for release signing
Add these repository **Secrets** (Settings → Secrets and variables → Actions → New repository secret):

- `ANDROID_KEYSTORE_BASE64` — base64 of your `*.jks` keystore file. Create via:
  ```bash
  base64 -w0 banking-manager.jks > keystore.b64
  # paste the file contents into the secret
  ```
- `ANDROID_KEYSTORE_PASSWORD` — your keystore password
- `ANDROID_KEY_ALIAS` — your key alias (e.g., `banking`)
- `ANDROID_KEY_ALIAS_PASSWORD` — your key alias password

> Ensure your `android/app/build.gradle` uses `key.properties` for release signing (as shown in the previous message).

### Firebase
If your app uses Firebase, you can either:
- Commit `android/app/google-services.json` to the repo, **or**
- Add it as a secret and reconstruct it in the workflow (advanced).

### Artifacts
After each run, go to **Actions → the workflow run → Artifacts** to download the APK.

---

**Tip:** If you also want AAB builds for Play Console:
```bash
flutter build appbundle --release
```
Add a new upload-artifact step pointing to `build/app/outputs/bundle/release/app-release.aab`.