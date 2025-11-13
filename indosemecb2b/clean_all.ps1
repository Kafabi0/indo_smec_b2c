# Write-Host ""
# Write-Host "Cleaning Flutter and Gradle builds..."
# Write-Host ""

# cd android
# Write-Host "Running Gradle clean..."
# ./gradlew clean

# Write-Host "Stopping Gradle daemons..."
# ./gradlew --stop

# cd ..
# Write-Host "Running Flutter clean..."
# flutter clean

# Write-Host "Getting Flutter packages..."
# flutter pub get

# Write-Host ""
# Write-Host "Project cleaned successfully and Gradle daemon stopped!"







Write-Host ""
Write-Host "bersih bersih flutter sama build gradle"
Write-Host ""

cd android
Write-Host "Mulai bersih build gradle"
./gradlew clean
write-host ""

Write-Host "selesai"
./gradlew --stop
write-host ""

cd ..
Write-Host "Mulai bersih  flutter"
flutter clean
write-host ""

Write-Host "ambil kebutuhan flutter"
flutter pub get

Write-Host "bersih bersih flutter sama build gradle selesai"
