#!/bin/zsh
# Publish a new version: ./release.sh 1.3 "What changed"
# Bumps the version, builds, commits, tags, pushes and creates the GitHub release.
# Installed copies of Sync Delay find it on their next launch and offer to update.
set -euo pipefail
cd "${0:A:h}"

version="${1:?Usage: ./release.sh <version> [\"release notes\"]}"
notes="${2:-}"
[[ "$version" =~ '^[0-9]+(\.[0-9]+)*$' ]] || { echo "Version must look like 1.3 or 1.3.1"; exit 1; }
if git rev-parse "v$version" >/dev/null 2>&1; then echo "v$version already exists"; exit 1; fi

plist=SyncDelay-Info.plist
build=$(( $(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$plist") + 1 ))
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" -c "Set :CFBundleVersion $build" "$plist"

./build-app.sh
rm -f Sync-Delay.zip
ditto -c -k --keepParent "Sync Delay.app" Sync-Delay.zip

git add -A
git commit -m "Release $version" >/dev/null
git tag "v$version"
git push origin HEAD "v$version"

if [[ -n "$notes" ]]; then
  gh release create "v$version" Sync-Delay.zip --title "Sync Delay $version" --notes "$notes"
else
  gh release create "v$version" Sync-Delay.zip --title "Sync Delay $version" --generate-notes
fi

# Update this Mac's copy too.
rm -rf "/Applications/Sync Delay.app" && cp -R "Sync Delay.app" /Applications/
echo "Released Sync Delay $version"
