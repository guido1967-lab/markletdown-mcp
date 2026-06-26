# MarkltDown — Windows

## Installazione
1. Installa **Python 3.10+** da [python.org](https://www.python.org/downloads/) — spunta **"Add Python to PATH"**.
2. (Consigliato) Pandoc per PDF/Word/HTML: `winget install --id JohnMacFarlane.Pandoc`.
3. **Doppio click su `INSTALLA-WINDOWS.bat`** e attendi il messaggio "Fatto!".

> ⚠️ Non fare doppio click sui file `.ps1`: Windows li *apre* nell'editor, non li
> esegue. Usa il `.bat` (che invece parte col doppio click). In alternativa, da
> PowerShell aperto **nella cartella `windows`**:
> ```powershell
> powershell -ExecutionPolicy Bypass -File .\install.ps1
> ```

L'installer crea il virtualenv (`..\.venv`), installa `markitdown[all]` e aggiunge la
voce **"Converti in Markdown"** al menu tasto-destro di **file** e **cartelle**.

## Uso
- **File Explorer:** tasto destro su uno o più file/cartelle → **Converti in Markdown**.
  A fine conversione appare un popup col risultato.
- **Doppio click** su `convert.bat`: converte la cartella di default
  (`Documenti\Claude`) oppure i file/cartelle trascinati sul `.bat`.

## Dove vanno i .md
- File in `%USERPROFILE%\solongevity-projects\<progetto>\…` → `<progetto>\_markdown\…`
- Altrove → `_markdown\` accanto al file.

## Note
- Selezionando molti file insieme, Windows lancia il comando una volta per file
  (limite di sistema ~16). Per cartelle grandi, fai tasto-destro sulla **cartella**.
- Rimuovere la voce di menu: `powershell -ExecutionPolicy Bypass -File .\install.ps1 -Uninstall`
