# ClipIt Updates

Auto-update feed for ClipIt — the native macOS clipboard manager.

This repo hosts the Sparkle appcast and release binaries. The app checks `appcast.xml` on launch for new versions.

## Releasing a new version

```bash
# 1. Build and notarize the new DMG
# 2. Run the release script
./release.sh 1.1.0 ~/Downloads/ClipIt.dmg

# 3. Commit and push the updated appcast
git add appcast.xml && git commit -m "Release v1.1.0" && git push

# 4. Create a GitHub Release with the DMG attached
gh release create v1.1.0 ~/Downloads/ClipIt.dmg --title "ClipIt v1.1.0" --repo labeebmm/ClipIt-updates
```
