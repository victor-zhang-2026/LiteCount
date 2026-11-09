#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
project_dir="${script_dir:h}"
bundle_dir="$project_dir/build/LiteCount.app"
contents_dir="$bundle_dir/Contents"
version_file="$project_dir/Support/Version.plist"
plist_buddy="/usr/libexec/PlistBuddy"

cd "$project_dir"
marketing_version="$("$plist_buddy" -c 'Print :MarketingVersion' "$version_file")"
build_number="$("$plist_buddy" -c 'Print :BuildNumber' "$version_file")"
release_channel="$("$plist_buddy" -c 'Print :ReleaseChannel' "$version_file")"
build_args=(-c release)
if [[ -n "${LITECOUNT_MACOS_SDK:-}" ]]; then
    build_args+=(--sdk "$LITECOUNT_MACOS_SDK")
fi
swift build "${build_args[@]}"

binary=".build/release/LiteCount"
if [[ ! -x "$binary" ]]; then
    # SwiftPM may place products under .build/out
    binary=".build/out/Products/Release/LiteCount"
fi

rm -rf "$bundle_dir"
mkdir -p "$contents_dir/MacOS" "$contents_dir/Resources"
cp "$binary" "$contents_dir/MacOS/LiteCount"
cp "Support/Info.plist" "$contents_dir/Info.plist"
cp "Support/LiteCount.icns" "$contents_dir/Resources/LiteCount.icns"
"$plist_buddy" -c "Add :CFBundleShortVersionString string $marketing_version" "$contents_dir/Info.plist"
"$plist_buddy" -c "Add :CFBundleVersion string $build_number" "$contents_dir/Info.plist"
"$plist_buddy" -c "Add :LiteCountReleaseChannel string $release_channel" "$contents_dir/Info.plist"
chmod +x "$contents_dir/MacOS/LiteCount"

codesign --force --deep --sign - "$bundle_dir"
codesign --verify --strict "$bundle_dir"
echo "$bundle_dir ($marketing_version build $build_number)"
