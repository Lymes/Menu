# MenuServer Implementation Guide

## Current Status

I've implemented the complete WiFi-based order system architecture with two targets:
- **MenuStanza1** (client - room device) - sends orders
- **MenuServer** (server - kitchen/reception) - receives and displays orders

## What's Already Done

### ✅ Code Implementation
1. **MenuServer App** (in `MenuServer/` folder):
   - `MenuServerApp.swift` - Main app entry point
   - `Models/Order.swift` - SwiftData model for orders
   - `Models/OrderStore.swift` - Persistence layer with SwiftData
   - `Services/BonjourService.swift` - Network listener for incoming orders
   - `Views/ServerContentView.swift` - UI showing received orders

2. **MenuStanza1 (Menu) Updates**:
   - `Services/OrderSenderService.swift` - Bonjour discovery + order transmission
   - `Models/OrderTransferData.swift` - Shared data models
   - `MenuApp.swift` - Updated to inject OrderSenderService
   - `ContentView.swift` - Replaced printer logic with network send
   - `BottomBar.swift` - Shows server connection status

3. **Localizations**:
   - Added server status strings (de/en/it)

4. **Project Configuration**:
   - Added MenuServer target to `project.pbxproj`
   - Created MenuServer.xcscheme
   - Configured Bonjour permissions for both targets

### ⚠️ Issue
The `project.pbxproj` modifications via terminal aren't being recognized by Xcode consistently. 

## Next Steps - ADD TARGET VIA XCODE UI (2 minutes)

### Option A: Add Target Manually (Recommended)
1. Open `Menu.xcodeproj` in Xcode
2. Click the blue **"Menu"** project icon in Project Navigator
3. In the targets list, click **"+"** at the bottom
4. Choose **iOS → App**
5. Configure:
   - **Product Name**: `MenuServer`
   - **Team**: Your development team
   - **Organization Identifier**: `com.youus`
   - **Bundle Identifier**: `com.youus.MenuServer`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Include Tests**: No
6. Click **Finish**
7. When asked where to save, select the existing **`MenuServer`** folder
8. **Delete** the auto-generated files Xcode creates:
   - `MenuServerApp.swift` (we have a better version)
   - `ContentView.swift` (we use ServerContentView.swift)
   - `Assets.xcassets` (will use shared assets)

### Option B: Use Existing Target (If visible in Xcode)
If you already see "MenuServer" as a target in Xcode:
1. Select the MenuServer target
2. Go to **Build Phases** tab
3. Verify the **MenuServer** folder is in "Compile Sources"
4. Try building the scheme

## How to Test End-to-End

### 1. Build and Run MenuServer (Kitchen/Reception iPad)
```bash
# In Xcode:
- Select scheme: MenuServer
- Select destination: iPad Pro 13-inch (M5) Simulator
- Press ⌘R (Run)
```

You should see:
- "Menu Server" title with Legrand logo
- Status: "Server attivo" (green dot)
- Empty orders list: "Nessun ordine ricevuto"

### 2. Build and Run MenuStanza1 (Room iPhone)
```bash
# In Xcode:
- Select scheme: Menu
- Select destination: iPhone 17 Pro Simulator
- Press ⌘R (Run)
```

You should see:
- "Ordine Stanza 1" title
- Bottom bar shows one of:
  - "Cercando server..." (discovering)
  - "Server trovato" (discovered)
  - "Server connesso" (when sending)

### 3. Send an Order
1. In MenuStanza1 (iPhone):
   - Select a menu (e.g., "Pranzo")
   - Add some drinks (e.g., 2× Coca-Cola, 1× Birra)
   - Tap "Anteprima"
   - Tap "Invia"
2. Watch MenuServer (iPad):
   - A new order should appear immediately
   - Shows "Stanza 1", timestamp, menu items, drinks
   - Status: "Pending" (orange dot)

### 4. Manage Orders in MenuServer
- Swipe left on an order → "Elimina" (delete)
- Tap the "⋯" menu → change status:
  - Pending (orange)
  - Preparing (blue)
  - Completed (green)
  - Cancelled (gray)

## Architecture

### Network Protocol
- **Discovery**: Bonjour/mDNS with service type `_menuorder._tcp.local.`
- **Transport**: TCP/IP over local network
- **Format**: JSON-encoded OrderTransferData
- **Flow**:
  1. MenuServer starts advertising on launch
  2. MenuStanza1 discovers via NWBrowser
  3. When user sends order, MenuStanza1 opens TCP connection
  4. Sends JSON payload
  5. MenuServer receives, decodes, saves to SwiftData
  6. Connection closes

### Data Model
```swift
OrderTransferData:
  - roomNumber: String
  - menuItems: [String]
  - drinks: [DrinkTransferData(name, quantity)]

Order (SwiftData):
  - id, roomNumber, timestamp
  - menuItems, drinks, status
```

## Troubleshooting

### "No server found"
- Both apps must be on the same network (simulators share host Mac's network, so they can see each other)
- Check MenuServer shows "Server attivo"
- Restart both apps

### Orders not arriving
- Check Xcode console for "✅ Order received" / "❌" errors
- Verify local network permissions granted
- Check firewall settings on Mac

### Build errors
- Clean build folder (⇧⌘K)
- Delete DerivedData
- Restart Xcode

## Files Created/Modified

### New Files (MenuServer):
- `MenuServer/MenuServerApp.swift`
- `MenuServer/Models/Order.swift`
- `MenuServer/Models/OrderStore.swift`
- `MenuServer/Models/OrderTransferData.swift`
- `MenuServer/Services/BonjourService.swift`
- `MenuServer/Views/ServerContentView.swift`

### New Files (MenuStanza1):
- `Menu/Services/OrderSenderService.swift`
- `Menu/Models/OrderTransferData.swift`

### Modified Files:
- `Menu/MenuApp.swift` - Integrated OrderSenderService
- `Menu/Views/ContentView.swift` - Replaced printer with network send
- `Menu/Views/Sections/BottomBar.swift` - Made callbacks optional
- `Menu/{en,de,it}.lproj/Localizable.strings` - Added server status strings
- `Menu.xcodeproj/project.pbxproj` - Added MenuServer target (may need UI confirmation)
- `Menu.xcodeproj/xcshareddata/xcschemes/MenuServer.xcscheme` - New scheme

## Next: After Adding Target in Xcode

Once you add the MenuServer target via Xcode UI, you'll be able to:
1. Switch between schemes (Menu / MenuServer)
2. Run both simultaneously on different simulators
3. Test the complete order flow from room to kitchen

All the code is ready - you just need Xcode to recognize the target!
