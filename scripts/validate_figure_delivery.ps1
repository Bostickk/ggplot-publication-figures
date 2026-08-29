[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ReportPath,

    [string]$VaultRoot,

    [string[]]$ExpectedFormats = @('.png', '.pdf', '.svg'),

    [int]$MinimumBytes = 1024,

    [switch]$FailOnDuplicate
)

$ErrorActionPreference = 'Stop'

function Resolve-ExistingPath {
    param([string]$PathValue, [string]$Label)
    if (-not (Test-Path -LiteralPath $PathValue)) {
        throw "$Label does not exist: $PathValue"
    }
    return (Resolve-Path -LiteralPath $PathValue).Path
}

function Find-ObsidianVaultRoot {
    param([string]$StartDirectory)
    $current = Get-Item -LiteralPath $StartDirectory
    while ($null -ne $current) {
        if (Test-Path -LiteralPath (Join-Path $current.FullName '.obsidian')) {
            return $current.FullName
        }
        $current = $current.Parent
    }
    return $null
}

$reportFull = Resolve-ExistingPath -PathValue $ReportPath -Label 'Report'
$reportDirectory = Split-Path -Parent $reportFull

if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Find-ObsidianVaultRoot -StartDirectory $reportDirectory
    if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
        throw 'No .obsidian directory was found above the report. Supply -VaultRoot explicitly.'
    }
}
$vaultFull = Resolve-ExistingPath -PathValue $VaultRoot -Label 'Vault root'

$content = Get-Content -LiteralPath $reportFull -Raw
$records = [System.Collections.Generic.List[object]]::new()

$wikiPattern = '!\[\[([^\]\|]+?\.(?:png|jpg|jpeg|tif|tiff|svg|pdf))(?:\|[^\]]*)?\]\]'
foreach ($match in [regex]::Matches($content, $wikiPattern, 'IgnoreCase')) {
    $records.Add([pscustomobject]@{
        Kind = 'Obsidian'
        Link = $match.Groups[1].Value.Trim()
        Base = $vaultFull
    })
}

$markdownPattern = '!\[[^\]]*\]\(([^)]+?\.(?:png|jpg|jpeg|tif|tiff|svg|pdf))\)'
foreach ($match in [regex]::Matches($content, $markdownPattern, 'IgnoreCase')) {
    $records.Add([pscustomobject]@{
        Kind = 'Markdown'
        Link = $match.Groups[1].Value.Trim().Trim('<', '>')
        Base = $reportDirectory
    })
}

if ($records.Count -eq 0) {
    throw 'No embedded figure links were found in the report.'
}

$failures = [System.Collections.Generic.List[string]]::new()
$resolved = [System.Collections.Generic.List[object]]::new()

foreach ($record in $records) {
    $normalized = [System.Uri]::UnescapeDataString($record.Link).Replace('/', [IO.Path]::DirectorySeparatorChar)
    $candidate = if ([IO.Path]::IsPathRooted($normalized)) {
        $normalized
    } else {
        Join-Path $record.Base $normalized
    }

    $exists = Test-Path -LiteralPath $candidate -PathType Leaf
    if (-not $exists) {
        $failures.Add("Missing embedded file [$($record.Kind)]: $($record.Link) -> $candidate")
        continue
    }

    $full = (Resolve-Path -LiteralPath $candidate).Path
    $item = Get-Item -LiteralPath $full
    if ($item.Length -lt $MinimumBytes) {
        $failures.Add("File is smaller than $MinimumBytes bytes: $full")
    }

    $resolved.Add([pscustomobject]@{
        Kind = $record.Kind
        Link = $record.Link
        FullPath = $full
        Bytes = $item.Length
    })

    $directory = Split-Path -Parent $full
    $stem = [IO.Path]::GetFileNameWithoutExtension($full)
    foreach ($extension in $ExpectedFormats) {
        $normalizedExtension = if ($extension.StartsWith('.')) { $extension } else { ".$extension" }
        $sibling = Join-Path $directory ($stem + $normalizedExtension)
        if (-not (Test-Path -LiteralPath $sibling -PathType Leaf)) {
            $failures.Add("Missing sibling format $normalizedExtension for: $full")
            continue
        }
        $siblingItem = Get-Item -LiteralPath $sibling
        if ($siblingItem.Length -lt $MinimumBytes) {
            $failures.Add("Sibling file is smaller than $MinimumBytes bytes: $sibling")
        }
    }
}

$duplicates = $records | Group-Object Kind, Link | Where-Object Count -gt 1
foreach ($duplicate in $duplicates) {
    $message = "Duplicate embed ($($duplicate.Count)x): $($duplicate.Name)"
    if ($FailOnDuplicate) {
        $failures.Add($message)
    } else {
        Write-Warning $message
    }
}

$resolved | Sort-Object FullPath | Format-Table Kind, Bytes, FullPath -AutoSize
Write-Host "Checked $($records.Count) embeds; resolved $($resolved.Count); expected formats: $($ExpectedFormats -join ', ')."

if ($failures.Count -gt 0) {
    Write-Error ("Figure delivery validation failed:`n- " + ($failures -join "`n- "))
    exit 1
}

Write-Host 'Figure delivery validation passed.'
exit 0
