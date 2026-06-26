<#
  convert.ps1 — Converte file in Markdown (.md) usando markitdown (Microsoft).
  Obiettivo: ridurre i token. Dai a Claude SOLO i .md generati, mai gli originali.

  Uso:
    - Tasto destro nel File Explorer su file/cartelle -> "Converti in Markdown"
    - Doppio click su convert.bat -> converte la cartella di default
    - PowerShell:  .\convert.ps1 "C:\percorso\file_o_cartella" [...]

  Output: i .md vanno in una sottocartella "_markdown".
  - File dentro un progetto in %USERPROFILE%\solongevity-projects\<progetto>\...
      -> tutti in <progetto>\_markdown\<sottocartelle interne>
  - Altrove -> _markdown accanto al file.
#>
[CmdletBinding()]
param(
    [switch]$ShowDialog,                                   # mostra popup col risultato (context menu)
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Paths
)

$ErrorActionPreference = 'Stop'

$ScriptDir    = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$RepoRoot     = Split-Path -Parent $ScriptDir
$MarkItDown   = Join-Path $RepoRoot '.venv\Scripts\markitdown.exe'
$ProjectsRoot = Join-Path $env:USERPROFILE 'solongevity-projects'
$OutputSubdir = '_markdown'
$DefaultDir   = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Claude'

$Extensions = @('.pdf','.doc','.docx','.ppt','.pptx','.xls','.xlsx','.csv','.json',
                '.xml','.html','.htm','.txt','.epub','.mp3','.wav','.jpg','.jpeg',
                '.png','.gif','.bmp','.tiff','.zip')

$script:OK = 0
$script:KO = 0

function Show-Result {
    $msg = "$($script:OK) convertiti, $($script:KO) falliti.`nDai a Claude SOLO i file nelle cartelle _markdown."
    if ($ShowDialog) {
        Add-Type -AssemblyName System.Windows.Forms | Out-Null
        [System.Windows.Forms.MessageBox]::Show($msg, 'Converti in Markdown') | Out-Null
    }
}

if (-not (Test-Path $MarkItDown)) {
    $err = "markitdown non trovato in:`n$MarkItDown`n`nEsegui prima install.ps1."
    Write-Host "X $err"
    if ($ShowDialog) {
        Add-Type -AssemblyName System.Windows.Forms | Out-Null
        [System.Windows.Forms.MessageBox]::Show($err, 'Converti in Markdown') | Out-Null
    }
    exit 1
}

function Get-OutDir([string]$absPath) {
    $fullProj = [IO.Path]::GetFullPath($ProjectsRoot)
    $full     = [IO.Path]::GetFullPath($absPath)
    if ($full.StartsWith($fullProj + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        $rel    = $full.Substring($fullProj.Length).TrimStart('\')   # progetto\...\file.ext
        $parts  = $rel.Split('\')
        if ($parts.Count -ge 2) {
            $project = $parts[0]
            $innerDir = Split-Path -Parent ($parts[1..($parts.Count-1)] -join '\')
            $base = Join-Path (Join-Path $fullProj $project) $OutputSubdir
            if ($innerDir) { return (Join-Path $base $innerDir) } else { return $base }
        }
    }
    return (Join-Path (Split-Path -Parent $full) $OutputSubdir)
}

function Convert-One([string]$file) {
    $name   = Split-Path -Leaf $file
    $outDir = Get-OutDir $file
    $out    = Join-Path $outDir ([IO.Path]::GetFileNameWithoutExtension($name) + '.md')
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    try {
        & $MarkItDown $file -o $out 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  OK  $name  ->  $out"; $script:OK++
        } else { Write-Host "  !!  $name  (conversione fallita)"; $script:KO++ }
    } catch { Write-Host "  !!  $name  (errore: $_)"; $script:KO++ }
}

function Test-Supported([string]$path) {
    return $Extensions -contains ([IO.Path]::GetExtension($path).ToLower())
}

function Invoke-Target([string]$target) {
    if (Test-Path $target -PathType Container) {
        Write-Host "[Cartella] $target"
        Get-ChildItem -LiteralPath $target -Recurse -File |
            Where-Object { $_.DirectoryName -notmatch "\\$OutputSubdir(\\|$)" -and (Test-Supported $_.FullName) } |
            ForEach-Object { Convert-One $_.FullName }
    } elseif (Test-Path $target -PathType Leaf) {
        if (Test-Supported $target) { Convert-One $target }
        else { Write-Host "  --  $(Split-Path -Leaf $target) (formato non supportato)" }
    } else {
        Write-Host "  ??  Non trovato: $target"
    }
}

Write-Host "Conversione in Markdown (markitdown)..."
Write-Host ""

if (-not $Paths -or $Paths.Count -eq 0) {
    if (Test-Path $DefaultDir) { Invoke-Target $DefaultDir }
    else { Write-Host "Nessun file passato e cartella di default assente: $DefaultDir" }
} else {
    foreach ($p in $Paths) { Invoke-Target $p }
}

Write-Host ""
Write-Host "Fatto: $($script:OK) convertiti, $($script:KO) falliti."
Show-Result
