#!/bin/bash
# Usage: ./release.sh <version> <path-to-dmg>
# Example: ./release.sh 1.1.0 ~/Downloads/ClipIt.dmg

VERSION=$1
DMG_PATH=$2
SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData/ClipIt-*/SourcePackages/artifacts -name "sign_update" 2>/dev/null | head -1)

if [ -z "$VERSION" ] || [ -z "$DMG_PATH" ]; then
    echo "Usage: ./release.sh <version> <path-to-dmg>"
    exit 1
fi

# Sign the DMG with Sparkle EdDSA key
SIGNATURE=$("$SPARKLE_BIN" "$DMG_PATH" 2>&1)
LENGTH=$(stat -f%z "$DMG_PATH")
SPARKLE_ATTRS=$(echo "$SIGNATURE" | grep -o 'sparkle:edSignature="[^"]*"')
SPARKLE_SIG=$(echo "$SPARKLE_ATTRS" | sed 's/sparkle:edSignature="//;s/"//')

echo "Version: $VERSION"
echo "Length: $LENGTH"
echo "Signature: $SPARKLE_SIG"

# Generate new appcast.xml
cat > appcast.xml << APPCAST
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>ClipIt Updates</title>
    <link>https://labeebmm.github.io/ClipIt-updates/appcast.xml</link>
    <description>Most recent changes with links to updates.</description>
    <language>en</language>
    <item>
      <title>Version $VERSION</title>
      <sparkle:version>$VERSION</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <pubDate>$(date -R)</pubDate>
      <enclosure
        url="https://github.com/labeebmm/ClipIt-updates/releases/download/v$VERSION/ClipIt.dmg"
        $SPARKLE_ATTRS
        length="$LENGTH"
        type="application/octet-stream" />
    </item>
  </channel>
</rss>
APPCAST

echo ""
echo "appcast.xml updated. Now run:"
echo "  1. git add appcast.xml && git commit -m 'Release v$VERSION' && git push"
echo "  2. gh release create v$VERSION '$DMG_PATH' --title 'ClipIt v$VERSION' --repo labeebmm/ClipIt-updates"
