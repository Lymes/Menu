# Fix: Drinks Bug - "Drinks: none" la prima volta + Chiavi internazionalizzazione

## ✅ Fix Applicati

### 1. Localizzazione nel Ticket
**Problema**: Nel preview vedevi `drink.coca.cola x1` invece di "Coca Cola x1"

**Causa**: In `composeTicket()` usavi `d.title` (la chiave raw) invece della stringa localizzata.

**Fix**: Ora uso `NSLocalizedString(d.title, comment: "Drink name")` nel ticket:
```swift
for d in chosen {
    let localizedName = NSLocalizedString(d.title, comment: "Drink name")
    lines.append(" • \(localizedName) x\(d.quantity)")
}
```

### 2. Update forzato dell'array drinks
**Problema**: La prima volta che premevi `+`, la quantità non veniva rilevata.

**Causa**: Modificare `drinks[index].quantity` direttamente non sempre triggera `@State` update in Swift.

**Fix**: Ora creo un nuovo array e lo riassegno:
```swift
var updatedDrinks = drinks
updatedDrinks[index].quantity = newQuantity
drinks = updatedDrinks  // ← forza @State update
```

### 3. Logging Debug Aggiunto
Ora vedrai nella console Xcode:
- `🍹 updateDrink called - index: X, delta: ±1`
- `📝 drinks changed - items with qty>0: 0 → 1`
- `📄 Sheet opening - generating ticket now`
- `🔍 Composing ticket - selectedMenu: Menu 1`
- `🍹 Drinks with quantity > 0: 1`

## 🧪 Test Passo-Passo

1. **Lancia Menu** su iPhone 17 Pro simulator
2. **Seleziona Menu 1** (opzionale)
3. **Tap `+` su Coca Cola** UNA volta
4. **Guarda console** - dovresti vedere:
   ```
   🍹 updateDrink called - index: 2, delta: 1, current qty: 0
   ✅ Drink updated - drink.coca.cola now has quantity: 1
   📝 drinks changed - items with qty>0: 0 → 1
      [2] drink.coca.cola x1
   ```
5. **Tap "Preview"**
6. **Guarda console** - dovresti vedere:
   ```
   📄 Sheet opening - generating ticket now
   🔍 Composing ticket - selectedMenu: Menu 1
   🍹 Drinks with quantity > 0: 1
      • drink.coca.cola x1
   ```
7. **Nel preview** dovresti vedere:
   - **EN**: "Drinks: • Coca Cola x1"
   - **DE**: "Drinks: • Coca Cola x1"

## ⚠️ Se Continua a Non Funzionare

Se vedi ancora "Drinks: none" la prima volta, il problema è che il ticket viene **calcolato una volta sola** quando la sheet si presenta, non dinamicamente.

**Soluzione alternativa** (se serve):
Cambiare `TicketPreviewView` per ricevere `drinks` e `selectedMenu` come binding e calcolare il ticket dinamicamente nella view stessa, non in `ContentView`.

## 📝 File Modificati
- ✅ `/Menu/Views/ContentView.swift`
  - `updateDrink()` - forza array update
  - `composeTicket()` - localizza drink names
  - `onChange(of: drinks)` - logging
  - `.sheet()` - logging

**Build**: Rebuilda in Xcode e testa!
