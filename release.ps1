$release = $args[0]

if (-not $release)
{
    Write-Error "Please provide a release version as the first argument."
    exit 1
}

$apkDir = "app/release"

Copy-Item "$apkDir/app-armeabi-v7a-release.apk" "kcptun-armeabi-v7a-$release.apk"
Copy-Item "$apkDir/app-arm64-v8a-release.apk" "kcptun-arm64-v8a-$release.apk"
Copy-Item "$apkDir/app-x86-release.apk" "kcptun-x86-$release.apk"
Copy-Item "$apkDir/app-x86_64-release.apk" "kcptun-x86_64-$release.apk"
Copy-Item "$apkDir/app-universal-release.apk" "kcptun--universal-$release.apk"
