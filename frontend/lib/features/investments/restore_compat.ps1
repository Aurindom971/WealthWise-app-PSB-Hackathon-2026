$files = Get-ChildItem -Path "c:\New folder\PSB-Hackathon-Secure-wealth-app\lib\Investments" -Filter "*.dart" -Recurse
foreach ($file in $files) {
    (Get-Content $file.FullName) -replace '\.withOpacity\(([\d\.]+)\)', '.withValues(alpha: $1)' | Set-Content $file.FullName
}
