
$sourceDir = Get-Location
$zipFile = "flutlab_project.zip"
$exclude = @("build", ".dart_tool", ".git", ".idea", ".vscode", "flutlab_project.zip")

Write-Host "Creating $zipFile from $sourceDir excluding: $($exclude -join ', ')"

# Check if 7z is available, otherwise use Compress-Archive (which might be slower or have issues with long paths, but standard on Windows)
# We will use Compress-Archive but filter files first.
# Actually, a better approach is to copy to a temp dir, then zip.

$tempDir = Join-Path $env:TEMP "flutlab_temp_$(Get-Random)"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "Copying files to temporary directory..."
Get-ChildItem -Path $sourceDir -Exclude $exclude | ForEach-Object {
    $targetPath = Join-Path $tempDir $_.Name
    if ($_.PSIsContainer) {
        Copy-Item -Path $_.FullName -Destination $targetPath -Recurse -Force
    } else {
        Copy-Item -Path $_.FullName -Destination $targetPath -Force
    }
}

# Remove nested excluded folders that might have been copied if they were inside included folders (though Get-ChildItem -Exclude works on the immediate children)
# We need to recursively remove build and .dart_tool if they exist deeper (unlikely for standard flutter structure, but good safety)
Get-ChildItem -Path $tempDir -Include "build",".dart_tool" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Compressing..."
if (Test-Path $zipFile) { Remove-Item $zipFile }
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFile

Write-Host "Cleaning up..."
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Done! Upload $zipFile to FlutLab."
