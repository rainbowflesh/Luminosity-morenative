# Process all JSON files under ./template
Get-ChildItem -Path "./template" -Filter "*.json" -Recurse | ForEach-Object {

    $filePath = $_.FullName
    $content = Get-Content -Path $filePath -Raw

    # Replace any bcr/wcr/mcr with value 8
    # Keeps the original styleConstants[index] unchanged
    $content = [regex]::Replace(
        $content,
        '"(styleConstants\[\d+\])"\s*:\s*"(bcr|wcr|mcr)=\d+"',
        '"$1": "$2=8"'
    )

    # Write back to file
    Set-Content -Path $filePath -Value $content -Encoding UTF8
}