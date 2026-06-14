# ⚡ Quick Start: MarkltDown-MCP

Get up and running in **5 minutes**!

## 1️⃣ Install Pandoc

```bash
brew install pandoc
```

Verify:
```bash
pandoc --version
```

> ⚠️ Requires **Python 3.10+** (the `mcp` library does not run on the macOS
> system Python 3.9). Install a recent Python with `brew install python@3.12`.
> For image OCR also run `brew install tesseract`.

## 2️⃣ Clone the Repository

```bash
git clone https://github.com/guido1967-lab/markletdown-mcp.git
cd markletdown-mcp
```

## 3️⃣ Create a venv and install dependencies

```bash
python3.12 -m venv .venv
./.venv/bin/pip install -r requirements.txt
```

Get the absolute paths you'll need for the config:
```bash
echo "$(pwd)/.venv/bin/python"          # command
echo "$(pwd)/server/file_to_markdown_mcp.py"   # args
```

## 4️⃣ Configure Claude Desktop

⚠️ The config file lives here (NOT `~/.claude-desktop/`):

```bash
open "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
```

Add the `file-to-markdown` entry to `mcpServers` (replace `/YOUR/PATH`
with the paths printed in step 3). Keep any servers already present:

```json
{
  "mcpServers": {
    "file-to-markdown": {
      "command": "/YOUR/PATH/markletdown-mcp/.venv/bin/python",
      "args": ["/YOUR/PATH/markletdown-mcp/server/file_to_markdown_mcp.py"]
    }
  }
}
```

> Tip: use the venv's Python as `command` so the dependencies are always
> found, regardless of your system Python.

## 5️⃣ Restart Claude Desktop

1. Close Claude Desktop
2. Wait 5 seconds
3. Open Claude Desktop again

## ✅ Done!

Try uploading a file to Claude:
- 📄 PDF
- 📝 Word document
- 📊 Excel spreadsheet
- 🎨 PowerPoint
- 🖼️ Image
- 📈 CSV/JSON file

Claude will automatically convert it to Markdown! 🎉

---

## 🆘 Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| `pandoc: command not found` | Run: `brew install pandoc` |
| `ModuleNotFoundError` / `Missing dependency 'mcp'` | Run: `./.venv/bin/pip install -r requirements.txt` |
| `mcp` won't install | System Python is too old. Use Python 3.10+: `brew install python@3.12` and recreate the venv |
| MCP not showing | 1. Use the **real** config: `~/Library/Application Support/Claude/claude_desktop_config.json` <br> 2. Use absolute paths to the venv Python and script <br> 3. Fully quit & reopen Claude Desktop |
| Image OCR empty | Run: `brew install tesseract` |

## 📍 Important File Locations

| What | Where |
|------|-------|
| Config file | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Script file | Wherever you cloned it (get path with `pwd`) |
| Repo URL | https://github.com/guido1967-lab/markletdown-mcp |

---

## 📚 File Types Supported

✅ PDF, Word (.docx, .doc), Excel (.xlsx, .xls), PowerPoint (.pptx, .ppt)  
✅ Images (JPG, PNG, GIF, BMP, TIFF) with OCR  
✅ CSV, JSON, HTML, Plain Text  

---

**Need more help?** See `README.md` for detailed documentation!
