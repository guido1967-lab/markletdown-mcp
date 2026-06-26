<#
  install.ps1 - Setup completo su Windows.
  Crea il venv, installa markitdown e aggiunge la voce "Converti in Markdown"
  al menu tasto-destro di file e cartelle. Percorsi ricavati automaticamente.

  Esegui (PowerShell, NON serve admin - usa HKCU):
    powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
[CmdletBinding()]
param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'

# Cartella dello script. Se lanciato come file -> $PSScriptRoot; se il contenuto
# viene incollato nel terminale -> $PSScriptRoot e vuoto, usa la cartella corrente.
$ScriptDir  = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
if (-not (Test-Path (Join-Path $ScriptDir 'convert.ps1'))) {
    Write-Host "X Non trovo convert.ps1 in: $ScriptDir"
    Write-Host "  Esegui questo script DALLA cartella 'windows' del progetto, oppure"
    Write-Host "  meglio: powershell -ExecutionPolicy Bypass -File .\install.ps1"
    return
}
$RepoRoot   = Split-Path -Parent $ScriptDir
$Venv       = Join-Path $RepoRoot '.venv'
$ConvertPs1 = Join-Path $ScriptDir 'convert.ps1'
$IconPath   = Join-Path $ScriptDir 'icon\AppIcon.ico'

$KeyName  = 'ConvertiInMarkdown'
$Label    = 'Converti in Markdown'
$RegFile  = "HKCU:\Software\Classes\*\shell\$KeyName"           # file
$RegDir   = "HKCU:\Software\Classes\Directory\shell\$KeyName"   # cartelle

function Remove-MenuEntries {
    foreach ($k in @($RegFile, $RegDir)) {
        if (Test-Path $k) { Remove-Item $k -Recurse -Force }
    }
}

if ($Uninstall) {
    Remove-MenuEntries
    Write-Host "Voci di menu rimosse. (Il venv in .venv resta; cancellalo a mano se vuoi.)"
    return
}

Write-Host "Installazione MarkltDown - repo: $RepoRoot`n"

# 1) Trova Python >= 3.10. Ritorna un array-comando, es. @('py','-3') o @('python').
function Find-Python {
    $cands = @()
    if (Get-Command py -ErrorAction SilentlyContinue) { $cands += ,@('py','-3') }
    foreach ($n in 'python','python3') {
        if (Get-Command $n -ErrorAction SilentlyContinue) { $cands += ,@($n) }
    }
    foreach ($c in $cands) {
        $exe = $c[0]
        $pre = if ($c.Count -gt 1) { $c[1..($c.Count-1)] } else { @() }
        try {
            $v = & $exe @pre -c 'import sys;print(sys.version_info[0]*100+sys.version_info[1])' 2>$null
            if ([int]$v -ge 310) { return ,$c }
        } catch {}
    }
    return $null
}

$py = Find-Python
if (-not $py) {
    Write-Host "X Serve Python 3.10+. Installalo da https://www.python.org/downloads/ (spunta 'Add to PATH')."
    return
}
$pyExe = $py[0]
$pyPre = if ($py.Count -gt 1) { $py[1..($py.Count-1)] } else { @() }
Write-Host "OK Python: $($py -join ' ')"

# 2) Venv + dipendenze (sempre eseguito: idempotente, e ripara venv esistenti rotti)
$markitdown = Join-Path $Venv 'Scripts\markitdown.exe'
if (-not (Test-Path (Join-Path $Venv 'Scripts\python.exe'))) {
    Write-Host "Creo il venv..."
    & $pyExe @pyPre -m venv $Venv
} else {
    Write-Host "OK Venv presente, aggiorno le dipendenze..."
}
& (Join-Path $Venv 'Scripts\python.exe') -m pip install --quiet --upgrade pip
& (Join-Path $Venv 'Scripts\pip.exe') install --quiet -r (Join-Path $RepoRoot 'requirements.txt')
# Solo i formati documentali (no audio/youtube/azure): evita dipendenze pesanti
# senza wheel su Python recenti. Il floor >=0.1.2 impedisce il fallback a 0.0.2.
& (Join-Path $Venv 'Scripts\pip.exe') install --quiet --upgrade 'markitdown[pdf,docx,pptx,xlsx,xls,outlook]>=0.1.2'
if (-not (Test-Path $markitdown)) { Write-Host "X Installazione markitdown fallita"; return }
Write-Host "OK markitdown pronto"

# 3) Voci nel menu tasto-destro (file + cartelle)
Remove-MenuEntries
$cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ConvertPs1`" -ShowDialog `"%1`""
foreach ($base in @($RegFile, $RegDir)) {
    New-Item -Path $base -Force | Out-Null
    # Il valore predefinito della chiave (etichetta del menu) si imposta con Set-Item,
    # NON con New-ItemProperty -Name '(default)' (che crea un valore chiamato "(default)").
    Set-Item -Path $base -Value $Label
    if (Test-Path $IconPath) {
        New-ItemProperty -Path $base -Name 'Icon' -Value $IconPath -PropertyType String -Force | Out-Null
    }
    New-Item -Path "$base\command" -Force | Out-Null
    Set-Item -Path "$base\command" -Value $cmd
}

Write-Host "`nFatto!"
Write-Host "  - File Explorer: tasto destro su file/cartelle -> Converti in Markdown"
Write-Host "  - Oppure doppio click su convert.bat"
Write-Host "  (Per rimuovere: .\install.ps1 -Uninstall)"
