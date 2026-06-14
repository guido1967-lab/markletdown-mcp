# MarkltDown — File → Markdown (riduci i token in Claude)

Converte PDF, Word, Excel, PowerPoint, immagini (OCR), CSV/JSON/XML/HTML, EPub,
audio e ZIP in **Markdown**, usando [markitdown](https://github.com/microsoft/markitdown) di Microsoft.

**Perché:** dare a Claude un `.md` leggero invece del file originale (PDF/immagini)
riduce molto i token. Converti **fuori** dalla chat e passa solo il Markdown.

## Dove finiscono i Markdown
- File dentro un progetto in `~/solongevity-projects/<progetto>/…`
  → tutti raccolti in **`<progetto>/_markdown/`** (struttura interna preservata)
- File altrove (es. Download) → cartella **`_markdown/`** accanto al file

## Struttura del repo
```
markletdown-mcp/
├── README.md
├── QUICK_START.md            # guida per l'MCP server (Claude Desktop)
├── requirements.txt
├── server/
│   └── file_to_markdown_mcp.py   # MCP server (file→md per path dentro Claude Desktop)
├── macos/
│   ├── install.command           # ⟵ doppio click: installa tutto
│   ├── convert.command           # motore di conversione
│   ├── app.applescript           # sorgente dell'app droplet sul Desktop
│   ├── quickaction/              # sorgente della Quick Action (tasto destro Finder)
│   └── icon/                     # icona (make_icon.py, AppIcon.icns, icon.png)
└── windows/
    ├── install.ps1               # ⟵ installa venv + voce tasto destro
    ├── convert.ps1               # motore di conversione
    ├── convert.bat               # doppio click
    └── icon/AppIcon.ico
```
> `.venv/` viene creato dall'installer in ciascuna macchina e NON è versionato.

## Installazione

### macOS
Prerequisiti: `brew install python@3.12 pandoc tesseract`
```bash
git clone https://github.com/guido1967-lab/markletdown-mcp.git
cd markletdown-mcp
# Doppio click su macos/install.command  (oppure:)
./macos/install.command
```
Ottieni: app **"Converti in Markdown"** sul Desktop + **Quick Action** nel Finder
(tasto destro su file/cartelle → Azioni rapide → Converti in Markdown).

### Windows
Prerequisiti: Python 3.10+ (da python.org, "Add to PATH"); consigliato `winget install JohnMacFarlane.Pandoc`.
```powershell
git clone https://github.com/guido1967-lab/markletdown-mcp.git
cd markletdown-mcp\windows
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
Ottieni: voce **"Converti in Markdown"** nel menu tasto-destro di file e cartelle
(+ `convert.bat` per il doppio click). Per rimuovere: `.\install.ps1 -Uninstall`.

## MCP server (opzionale, Claude Desktop)
Per convertire file su disco **dall'interno** di Claude Desktop, vedi
[QUICK_START.md](QUICK_START.md). Per il puro risparmio di token è preferibile
pre-convertire su disco (app/Quick Action) e passare solo i `.md`.
