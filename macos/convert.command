#!/bin/bash
#
# convert.command — Converte file in Markdown (.md) usando markitdown (Microsoft)
# Obiettivo: ridurre i token. Dai a Claude SOLO i .md generati, mai i file originali.
#
# Uso:
#   - Doppio click  -> converte la cartella indicata sotto (CARTELLA_DEFAULT)
#   - Trascina una cartella o dei file SOPRA l'icona dello script -> converte quelli
#
# Output: i .md finiscono in una sottocartella "_markdown" accanto a ciascun file.

set -euo pipefail

# --- Percorsi ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"   # macos/ -> radice repo
MARKITDOWN="$REPO_ROOT/.venv/bin/markitdown"

# Cartella di default quando si fa doppio click (cambiala se vuoi).
CARTELLA_DEFAULT="$HOME/Documents/Claude"

# Radice dei progetti: i file dentro un progetto qui sotto avranno TUTTI i loro
# markdown raccolti in <progetto>/_markdown/ (struttura interna preservata).
PROJECTS_ROOT="$HOME/solongevity-projects"

# Nome della cartella di output per i markdown.
OUTPUT_SUBDIR="_markdown"

OK=0
KO=0

# Pausa se gira nel Terminale (doppio click / app); altrimenti (Quick Action dal
# Finder) niente attesa di input: mostra una notifica macOS col risultato.
pausa_o_notifica() {
  if [ -t 0 ]; then
    echo
    read -n 1 -s -r -p "Premi un tasto per chiudere..."
    echo
  else
    /usr/bin/osascript -e "display notification \"$OK convertiti, $KO falliti\" with title \"Converti in Markdown\" sound name \"Glass\"" 2>/dev/null || true
  fi
}

# Estensioni supportate da markitdown.
ESTENSIONI="pdf doc docx ppt pptx xls xlsx csv json xml html htm txt epub mp3 wav jpg jpeg png gif bmp tiff zip"

# --- Controlli ---
if [ ! -x "$MARKITDOWN" ]; then
  echo "❌ markitdown non trovato in $MARKITDOWN"
  echo "   Crea il venv e installa: python3.12 -m venv .venv && ./.venv/bin/pip install 'markitdown[all]'"
  pausa_o_notifica
  exit 1
fi

# Calcola la cartella di output per un file.
# - File dentro un progetto in PROJECTS_ROOT  -> <progetto>/_markdown/<sottocartelle interne>
# - Altrove (es. Download)                    -> <cartella del file>/_markdown
out_dir_per() {
  local abs="$1" rest project inner
  if [[ "$abs" == "$PROJECTS_ROOT/"*/* ]]; then
    rest="${abs#$PROJECTS_ROOT/}"     # progetto/.../file.ext
    project="${rest%%/*}"             # progetto
    inner="${rest#*/}"                # .../file.ext (relativo al progetto)
    local subdir
    subdir="$(dirname "$inner")"      # sottocartelle interne (o "." se in radice)
    if [ "$subdir" = "." ]; then
      echo "$PROJECTS_ROOT/$project/$OUTPUT_SUBDIR"
    else
      echo "$PROJECTS_ROOT/$project/$OUTPUT_SUBDIR/$subdir"
    fi
  else
    echo "$(dirname "$abs")/$OUTPUT_SUBDIR"
  fi
}

# Converte un singolo file.
converti_file() {
  local file="$1"
  local dir abs base out_dir out
  dir="$(cd "$(dirname "$file")" && pwd)"
  abs="$dir/$(basename "$file")"
  base="$(basename "$file")"
  out_dir="$(out_dir_per "$abs")"
  out="$out_dir/${base%.*}.md"
  mkdir -p "$out_dir"
  if "$MARKITDOWN" "$file" -o "$out" 2>/dev/null; then
    echo "  ✅ $base  ->  ${out#$PROJECTS_ROOT/}"
    OK=$((OK+1))
  else
    echo "  ⚠️  $base  (conversione fallita)"
    KO=$((KO+1))
  fi
}

# È un'estensione supportata?
supportato() {
  local ext="$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')"
  for e in $ESTENSIONI; do [ "$ext" = "$e" ] && return 0; done
  return 1
}

# Processa una cartella (RICORSIVO: include tutte le sottocartelle) o un singolo file.
processa() {
  local target="$1"
  if [ -d "$target" ]; then
    echo "📂 Cartella (incl. sottocartelle): $target"
    # Scorre ricorsivamente tutti i file, saltando le cartelle _markdown già generate.
    while IFS= read -r -d '' f; do
      supportato "$f" && converti_file "$f"
    done < <(find "$target" -type d -name "_markdown" -prune -o -type f -print0)
  elif [ -f "$target" ]; then
    if supportato "$target"; then
      converti_file "$target"
    else
      echo "  ⏭️  $(basename "$target") (formato non supportato)"
    fi
  else
    echo "  ❓ Non trovato: $target"
  fi
}

echo "🔄 markitdown -> Markdown (per ridurre i token in Claude)"
echo

if [ "$#" -gt 0 ]; then
  # File/cartelle trascinati sopra lo script
  for arg in "$@"; do processa "$arg"; done
else
  # Doppio click -> cartella di default
  if [ ! -d "$CARTELLA_DEFAULT" ]; then
    echo "❌ Cartella di default non trovata: $CARTELLA_DEFAULT"
    echo "   Modifica CARTELLA_DEFAULT nello script, oppure trascina file/cartelle sull'icona."
    pausa_o_notifica
    exit 1
  fi
  processa "$CARTELLA_DEFAULT"
fi

echo
echo "✨ Fatto: $OK convertiti, $KO falliti."
echo "👉 Dai a Claude SOLO i file dentro le cartelle _markdown (non gli originali)."
pausa_o_notifica
