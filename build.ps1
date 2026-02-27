# Source and destination directories
$srcDir = "./template"
$destDir = "./dist"

# Create dist directory if not exists
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

# Resolve source absolute path once
$resolvedSrc = (Resolve-Path $srcDir).Path

# Process all JSON files recursively
Get-ChildItem -Path $srcDir -Filter "*.json" -Recurse | ForEach-Object {

    $sourcePath = $_.FullName
    $relativePath = $sourcePath.Substring($resolvedSrc.Length)
    $targetPath = Join-Path $destDir $relativePath

    # Ensure target subdirectory exists
    $targetDir = Split-Path $targetPath -Parent
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Read file content
    $content = Get-Content -Path $sourcePath -Raw

    # Normalize styleConstants values to *=8
    $content = [regex]::Replace(
        $content,
        '"(styleConstants\[\d+\])"\s*:\s*"(bcr|wcr|mcr)=\d+"',
        '"$1": "$2=8"'
    )

    # Replace IsStaggeringEnabled=\"True\" with False
    $content = $content -replace 'IsStaggeringEnabled=\\"True\\"', 'IsStaggeringEnabled=\"False\"'

    # Replace FromHorizontalOffset ±50 to ±15
    $content = $content -replace 'FromHorizontalOffset=\\"-50\\"', 'FromHorizontalOffset=\"-15\"'
    $content = $content -replace 'FromHorizontalOffset=\\"50\\"', 'FromHorizontalOffset=\"15\"'

    # Replace FromVerticalOffset ±50 to ±15
    $content = $content -replace 'FromVerticalOffset=\\"-50\\"', 'FromVerticalOffset=\"-15\"'
    $content = $content -replace 'FromVerticalOffset=\\"50\\"', 'FromVerticalOffset=\"15\"'

    # Write transformed content to dist
    Set-Content -Path $targetPath -Value $content -Encoding UTF8
}