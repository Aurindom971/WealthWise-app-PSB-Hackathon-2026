$path = "c:\New folder\PSB-Hackathon-Secure-wealth-app\lib\Investments\invest.dart"
$content = Get-Content $path
$startIndex = -1
for ($i = 0; $i -lt $content.Length; $i++) {
    if ($content[$i] -like "*Widget _buildMFCategCard(String title, IconData iconData) {*") {
        $startIndex = $i
        break
    }
}

if ($startIndex -ne -1) {
    # Find the end of the method (the next "  }")
    for ($j = $startIndex; $j -lt $content.Length; $j++) {
        if ($content[$j] -eq "  }") {
            # Replace the lines before the closure
            $content[$j-1] = "    ),"
            $content[$j] = "  );"
            # Insert a new closing brace
            $newContent = $content[0..$j] + "  }" + $content[($j+1)..($content.Length-1)]
            $newContent | Set-Content $path
            break
        }
    }
}
