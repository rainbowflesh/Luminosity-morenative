# Source and destination directories
$srcDir = "./template"
$destDir = "./dist"

# Create dist directory if not exists
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

# Process all JSON files recursively
Get-ChildItem -Path $srcDir -Filter "*.json" -Recurse | ForEach-Object {

    $sourcePath = $_.FullName
    $relativePath = $sourcePath.Substring((Resolve-Path $srcDir).Path.Length)
    $targetPath = Join-Path $destDir $relativePath

    # Ensure target subdirectory exists
    $targetDir = Split-Path $targetPath -Parent
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Read file content
    $content = Get-Content -Path $sourcePath -Raw

    # Replace bcr/wcr/mcr values to 8 while keeping index unchanged
    $content = [regex]::Replace(
        $content,
        '"(styleConstants\[\d+\])"\s*:\s*"(bcr|wcr|mcr)=\d+"',
        '"$1": "$2=8"'
    )

    # Write transformed content to dist
    Set-Content -Path $targetPath -Value $content -Encoding UTF8
}