#!/bin/bash
#
# install.command — Setup completo su macOS (doppio click per eseguire).
# Crea il venv, installa markitdown, costruisce l'app sul Desktop e la
# Quick Action nel Finder. Tutti i percorsi sono ricavati automaticamente:
# il repo può stare in qualsiasi cartella.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENV="$REPO_ROOT/.venv"
CONVERT_CMD="$SCRIPT_DIR/convert.command"
APP="$HOME/Desktop/Converti in Markdown.app"
WF="$HOME/Library/Services/Converti in Markdown.workflow"

echo "🛠  Installazione MarkltDown — repo: $REPO_ROOT"
echo

# 1) Trova un Python >= 3.10
PY=""
for c in python3.13 python3.12 python3.11 python3.10 /opt/homebrew/bin/python3 python3; do
  if command -v "$c" >/dev/null 2>&1; then
    v="$("$c" -c 'import sys;print(sys.version_info[0]*100+sys.version_info[1])' 2>/dev/null || echo 0)"
    if [ "$v" -ge 310 ]; then PY="$c"; break; fi
  fi
done
if [ -z "$PY" ]; then
  echo "❌ Serve Python 3.10+. Installa con: brew install python@3.12"
  read -n 1 -s -r -p "Premi un tasto per chiudere..."; exit 1
fi
echo "✅ Python: $("$PY" --version) ($PY)"

# 2) Venv + dipendenze (sempre eseguito: idempotente, ripara venv esistenti)
if [ ! -x "$VENV/bin/python3" ]; then
  echo "📦 Creo il venv..."
  "$PY" -m venv "$VENV"
else
  echo "✅ Venv presente, aggiorno le dipendenze..."
fi
"$VENV/bin/pip" install --quiet --upgrade pip
"$VENV/bin/pip" install --quiet -r "$REPO_ROOT/requirements.txt"
# Solo i formati documentali: niente dipendenze pesanti (audio/azure) che su Python
# recenti possono mancare di wheel e far ripiegare pip su markitdown 0.0.2.
"$VENV/bin/pip" install --quiet --upgrade 'markitdown[pdf,docx,pptx,xlsx,xls,outlook]>=0.1.2'
"$VENV/bin/markitdown" --version >/dev/null && echo "✅ markitdown pronto"

# 3) App sul Desktop (droplet con icona)
echo "🖥  Creo l'app sul Desktop..."
TMP_SCPT="$(mktemp -t convert_app).applescript"
sed "s#^property scriptPath : .*#property scriptPath : \"$CONVERT_CMD\"#" "$SCRIPT_DIR/app.applescript" > "$TMP_SCPT"
rm -rf "$APP"
osacompile -o "$APP" "$TMP_SCPT"
rm -f "$TMP_SCPT"
cp "$SCRIPT_DIR/icon/AppIcon.icns" "$APP/Contents/Resources/droplet.icns" 2>/dev/null || true
cp "$SCRIPT_DIR/icon/AppIcon.icns" "$APP/Contents/Resources/applet.icns" 2>/dev/null || true
rm -f "$APP/Contents/Resources/Assets.car"
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile droplet" "$APP/Contents/Info.plist" 2>/dev/null || true
touch "$APP"; /usr/bin/SetFile -a C "$APP" 2>/dev/null || true
echo "✅ App: $APP"

# 5) Quick Action nel Finder
echo "🔌 Installo la Quick Action (tasto destro nel Finder)..."
mkdir -p "$WF/Contents"
cp "$SCRIPT_DIR/quickaction/Info.plist" "$WF/Contents/Info.plist"
sed "s#__CONVERT_CMD__#$CONVERT_CMD#g" "$SCRIPT_DIR/quickaction/document.wflow.template" > "$WF/Contents/document.wflow"
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
echo "✅ Quick Action: $WF"

# 6) Refresh Finder
killall Finder 2>/dev/null || true

echo
echo "🎉 Fatto!"
echo "   • App sul Desktop: trascina file/cartelle sull'icona"
echo "   • Finder: tasto destro su file/cartelle → Azioni rapide → Converti in Markdown"
echo
read -n 1 -s -r -p "Premi un tasto per chiudere..."
