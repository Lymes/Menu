#!/bin/bash

echo "🔍 Checking MenuServer setup..."
echo ""

# Check folders
echo "📁 Checking folders:"
if [ -d "MenuServer" ]; then
    echo "  ✅ MenuServer folder exists"
    echo "     Files: $(find MenuServer -name '*.swift' | wc -l) Swift files"
else
    echo "  ❌ MenuServer folder missing"
fi

if [ -d "Menu/Services" ]; then
    echo "  ✅ Menu/Services folder exists"
else
    echo "  ❌ Menu/Services folder missing"
fi

echo ""
echo "📄 Checking key files:"

files=(
    "MenuServer/MenuServerApp.swift"
    "MenuServer/Models/Order.swift"
    "MenuServer/Models/OrderStore.swift"
    "MenuServer/Services/BonjourService.swift"
    "MenuServer/Views/ServerContentView.swift"
    "Menu/Services/OrderSenderService.swift"
    "Menu/Models/OrderTransferData.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file MISSING"
    fi
done

echo ""
echo "🎯 Checking project targets:"
if grep -q "78BE4FF32F36593C0003DA43" Menu.xcodeproj/project.pbxproj; then
    echo "  ✅ MenuServer target UUID found in project"
else
    echo "  ❌ MenuServer target not in project"
fi

if grep -q "targets = (" Menu.xcodeproj/project.pbxproj; then
    targets_count=$(grep -A3 "targets = (" Menu.xcodeproj/project.pbxproj | grep -c "Menu")
    echo "  📊 Found $targets_count target(s) in targets list"
fi

echo ""
echo "🔧 Checking schemes:"
if [ -f "Menu.xcodeproj/xcshareddata/xcschemes/MenuServer.xcscheme" ]; then
    echo "  ✅ MenuServer.xcscheme exists"
else
    echo "  ❌ MenuServer.xcscheme missing"
fi

echo ""
echo "📝 Next steps:"
echo "  1. Open Menu.xcodeproj in Xcode"
echo "  2. Check if you see 'MenuServer' in the scheme picker (top left)"
echo "  3. If not, add target manually: File > New > Target > iOS App"
echo "     - Name: MenuServer"
echo "     - Bundle ID: com.youus.MenuServer"
echo "     - Save to existing 'MenuServer' folder"
echo "     - Delete auto-generated files"
echo "  4. Build & run both schemes on different simulators"
echo ""
