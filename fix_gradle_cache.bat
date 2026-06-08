@echo off
echo ==================================================
echo   Flutter Gradle Cache Fixer (Deep Clean)
echo ==================================================
echo.
echo [1/5] Stopping existing Gradle, Java, and Kotlin processes...
cd android
call gradlew --stop >nul 2>&1
cd ..

:: Kill any active java or gradle processes to unlock cache files
taskkill /f /im java.exe >nul 2>&1
taskkill /f /im jb_openjdk.exe >nul 2>&1
taskkill /f /im kotlin-daemon.exe >nul 2>&1

echo.
echo [2/5] Cleaning Flutter project build files...
call flutter clean

echo.
echo [3/5] Deleting entire Gradle caches folder...
:: We will delete the whole caches folder to guarantee all bad metadata is cleared
if exist "C:\Users\Mohamed Khaled\.gradle\caches" (
    echo Deleting "C:\Users\Mohamed Khaled\.gradle\caches"...
    rd /s /q "C:\Users\Mohamed Khaled\.gradle\caches"
) else (
    echo Gradle cache folder not found at default location.
)

echo.
echo [4/5] Running flutter pub get...
call flutter pub get

echo.
echo [5/5] Performing a clean Gradle build with dependency refresh...
cd android
call gradlew clean --refresh-dependencies
cd ..

echo.
echo ==================================================
echo   Done! Please try running your project now.
echo ==================================================
pause
