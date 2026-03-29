$DIR = Get-Location
$TARGET = Join-Path $DIR "bin"
if (Test-Path $TARGET) {
    Remove-Item -Recurse -Force $TARGET
}
Write-Host "Successfully cleaned kcptun binaries"
