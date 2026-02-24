# Debug Guide - Bonjour Discovery Not Working

## Problema
Menu mostra "Cercando server..." infinitamente e non trova MenuServer.

## Fix Applicati
1. ✅ Aggiunto logging dettagliato in `OrderSenderService` e `BonjourService`
2. ✅ Verificato che entrambi i target compilano

## Come Debuggare Ora

### Step 1: Lancia MenuServer (iPad) e guarda console
In Xcode:
- Schema: `MenuServer`
- Device: `iPad Pro 11-inch (M4)`
- ⌘R
- **Apri Console** (⌘⇧C o View > Debug Area > Activate Console)

**Dovresti vedere:**
```
🎯 Starting to advertise MenuServer as 'MenuServer' on _menuorder._tcp.local.
📡 Listener created, setting up handlers...
✅ MenuServer advertising on Bonjour (port: XXXXX)
```

**Se invece vedi:**
```
❌ Listener failed: ...
```
→ Il problema è lato server (permessi, porta occupata, ecc.)

---

### Step 2: Lancia Menu (iPhone) e guarda console
In Xcode (mantieni MenuServer attivo):
- Schema: `Menu`
- Device: `iPhone 17 Pro`
- ⌘R
- **Apri Console**

**Dovresti vedere:**
```
🔍 Starting Bonjour discovery for _menuorder._tcp.local.
✅ Browser ready, discovering servers...
📡 Discovered 1 server(s):
  - MenuServer._menuorder._tcp.local.:XXXXX
✅ Auto-selected server: ...
```

**Se invece vedi:**
```
❌ Browser failed: ...
```
→ Il problema è lato client (permessi local network negati)

**Se vedi:**
```
✅ Browser ready...
📡 Discovered 0 server(s)
```
→ Discovery funziona ma non trova il server (problema rete/simulatori)

---

## Fix Comuni

### A) Local Network Permission Non Concessa
Quando lanci **Menu** per la prima volta, iOS dovrebbe chiedere:
> "Menu Stanza 1 vuole trovare dispositivi sulla rete locale"

Se hai premuto **"Non Consentire"** o non appare:

**Fix:**
1. Nel simulatore iPhone: **Settings > Privacy & Security > Local Network**
2. Trova **"Menu"** e abilita lo switch
3. Rilancia l'app Menu

### B) Simulatori Non Condividono Rete Correttamente
A volte i simulatori hanno "reti separate" anche se sono sullo stesso Mac.

**Fix 1: Forza stesso host**
In Xcode, quando lanci i simulatori, assicurati che:
- Entrambi siano **Booted** (non "Shutdown")
- Usa la stessa versione iOS (entrambi iOS 26.2 o simile)

**Fix 2: Usa Device Reali (se disponibili)**
Bonjour su simulatori può essere flaky. Se hai 2 device iOS fisici:
- Lancia MenuServer su un iPad fisico
- Lancia Menu su un iPhone fisico
- Devono essere sulla **stessa WiFi**

**Fix 3: Usa .local. domain esplicito**
Ho già impostato `domain: "local."` — dovrebbe funzionare.

### C) Firewall macOS Blocca Connessioni tra Simulatori
Controlla:
1. **System Settings > Network > Firewall**
2. Se è attivo, aggiungi eccezione per Xcode/Simulators

### D) Port Conflict
Se un'altra app usa la stessa porta:
- Stoppa tutti i simulatori
- Nella console cerca il numero di porta da MenuServer (es. `port: 54321`)
- Verifica che non sia occupata: `lsof -i :54321`

---

## Quick Test: Forza Porta Fissa (Debugging)

Per eliminare variabili, posso modificare il codice per usare una **porta fissa** invece che random, così è più facile debuggare.

Vuoi che aggiunga questa modalità debug? Oppure prova prima a:
1. Rilanciare MenuServer in Xcode e leggere la console
2. Rilanciare Menu e leggere la console
3. Dirmi cosa appare nei log

---

## Test Alternativo: Stesso Simulatore
Come ultimo test, posso far girare **entrambe le app sullo stesso simulatore** (es. iPad Pro 11):
- MenuServer in foreground
- Menu in background (multi-tasking iPad)

Su iOS stesso device, Bonjour funziona **sempre** tramite loopback.

Vuoi che modifichi il target Menu per essere iPad-compatible e testiamo così?
