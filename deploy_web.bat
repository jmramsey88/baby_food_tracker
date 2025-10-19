@echo off
REM =============================
REM Flutter Web GitHub Deploy Script
REM =============================

REM Set your repo name (change this to your repo folder name)
set REPO_NAME=weanly

REM Build the Flutter web app
echo Building Flutter web...
flutter build web --base-href /%REPO_NAME%/

IF %ERRORLEVEL% NEQ 0 (
    echo Flutter build failed!
    exit /b %ERRORLEVEL%
)

REM Switch to gh-pages branch
echo Switching to gh-pages branch...
git checkout gh-pages

REM Copy build output
echo Copying build/web files...
xcopy /Y /E build\web\* .

REM Stage changes
git add .

REM Commit with timestamp
for /f "tokens=2 delims==" %%i in ('wmic os get LocalDateTime /value') do set datetime=%%i
set datetime=%datetime:~0,8%_%datetime:~8,6%
git commit -m "Deploy update %datetime%"

REM Push to GitHub
echo Pushing to GitHub...
git push origin gh-pages --force

REM Switch back to main branch
git checkout main

echo Deployment complete!
pause
