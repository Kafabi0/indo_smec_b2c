Write-Host ""
Write-Host "Cleaning Flutter and Gradle builds..."
Write-Host ""

cd android
Write-Host "Running Gradle clean..."
./gradlew clean

Write-Host "Stopping Gradle daemons..."
./gradlew --stop

cd ..
Write-Host "Running Flutter clean..."
flutter clean

Write-Host "Getting Flutter packages..."
flutter pub get

Write-Host ""
Write-Host "Project cleaned successfully and Gradle daemon stopped!"
