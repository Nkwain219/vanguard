#!/bin/bash

echo "🎨 Vanguard Icon Generator"
echo "=========================="
echo ""

# Check if ImageMagick or Inkscape is installed
if command -v convert &> /dev/null; then
    echo "✓ ImageMagick found"
    echo "Converting SVG to PNG..."
    convert -background none -resize 1024x1024 icon_template.svg assets/icons/app_icon.png
    echo "✓ Icon generated: assets/icons/app_icon.png"
elif command -v inkscape &> /dev/null; then
    echo "✓ Inkscape found"
    echo "Converting SVG to PNG..."
    inkscape icon_template.svg --export-filename=assets/icons/app_icon.png --export-width=1024 --export-height=1024
    echo "✓ Icon generated: assets/icons/app_icon.png"
elif command -v rsvg-convert &> /dev/null; then
    echo "✓ rsvg-convert found"
    echo "Converting SVG to PNG..."
    rsvg-convert -w 1024 -h 1024 icon_template.svg -o assets/icons/app_icon.png
    echo "✓ Icon generated: assets/icons/app_icon.png"
else
    echo "❌ No SVG converter found!"
    echo ""
    echo "Please install one of the following:"
    echo "  • ImageMagick: sudo apt install imagemagick"
    echo "  • Inkscape: sudo apt install inkscape"
    echo "  • librsvg: sudo apt install librsvg2-bin"
    echo ""
    echo "Or convert manually:"
    echo "  1. Open icon_template.svg in a browser"
    echo "  2. Take a screenshot or use browser dev tools to export"
    echo "  3. Save as assets/icons/app_icon.png (1024x1024)"
    exit 1
fi

echo ""
echo "🚀 Generating Flutter launcher icons..."
flutter pub run flutter_launcher_icons

echo ""
echo "✅ Done! Your new Vanguard icon is ready!"
echo ""
echo "Preview the icon:"
echo "  • Android: android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
echo "  • iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo ""
