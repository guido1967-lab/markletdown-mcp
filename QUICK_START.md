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

## 2️⃣ Install Python Dependencies

```bash
pip3 install openpyxl python-pptx pillow pytesseract
```

Or use requirements.txt:
```bash
pip3 install -r requirements.txt
```

## 3️⃣ Clone or Download the Repository

```bash
git clone https://github.com/guido1967-lab/markletdown-mcp.git
cd markletdown-mcp
```

Get your script path:
```bash
pwd
```

**Copy this path!** Example: `/Users/john/Projects/markletdown-mcp`

## 4️⃣ Configure Claude Desktop

Open the config file:

```bash
nano ~/.claude-desktop/config.json
```

**If file doesn't exist**, create it first:

```bash
mkdir -p ~/.claude-desktop
```

**Then add this content** (replace `/YOUR/PATH` with your actual path):

```json
{
  "mcpServers": {
    "file-to-markdown": {
      "command": "python3",
      "args": ["/YOUR/PATH/file_to_markdown_mcp.py"]
    }
  }
}
```

**To save in nano:**
- Press `Ctrl + X`
- Press `Y`
- Press `Enter`

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
| `ModuleNotFoundError` | Run: `pip3 install -r requirements.txt` |
| MCP not showing | 1. Check config path exists <br> 2. Use absolute path (not relative) <br> 3. Restart Claude Desktop |
| Can't find file path | Open Terminal, go to folder, run `pwd` |

## 📍 Important File Locations

| What | Where |
|------|-------|
| Config file | `~/.claude-desktop/config.json` |
| Script file | Wherever you cloned it (get path with `pwd`) |
| Repo URL | https://github.com/guido1967-lab/markletdown-mcp |

---

## 📚 File Types Supported

✅ PDF, Word (.docx, .doc), Excel (.xlsx, .xls), PowerPoint (.pptx, .ppt)  
✅ Images (JPG, PNG, GIF, BMP, TIFF) with OCR  
✅ CSV, JSON, HTML, Plain Text  

---

**Need more help?** See `README.md` for detailed documentation!
