Write-Host "Clean up..."
Remove-Item -LiteralPath  "./dist/" -Force -Recurse -ErrorAction SilentlyContinue
New-Item -Path './dist/' -ItemType Directory | Out-Null

Write-Host "Creating LOVE archive..."
Compress-Archive -Update -LiteralPath ./src/main.lua -DestinationPath ./dist/image-viewer.zip
Rename-Item -Path ./dist/image-viewer.zip -NewName ImageViewer.love

Write-Host "Creating executable..."
Get-Content -Encoding Byte -Path "C:\Program Files\LOVE\love.exe", ".\dist\ImageViewer.love" `
| Set-Content -Encoding Byte '.\dist\ImageViewer.exe'

Write-Host "Prepare for distribution..."
Get-ChildItem -Path "C:\Program Files\LOVE\" | Where-Object { $_.Extension -eq ".dll" } `
| Compress-Archive -DestinationPath ".\dist\ImageViewer-final.zip"
Compress-Archive -Path .\dist\ImageViewer.exe -DestinationPath .\dist\ImageViewer-final.zip -Update

