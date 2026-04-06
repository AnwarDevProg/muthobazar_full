echo "# muthobazar_full" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/AnwarDevProg/muthobazar_full.git
git push -u origin main


…////////////////////////////////////or push an existing repository from the command line
git remote add origin https://github.com/AnwarDevProg/muthobazar_full.git
git branch -M main
git push -u origin main




git status git add . git commit -m "New Structure OK" git push origin main



//////////////////Later Push project to GitHub//////////////////
Before pushing, verify:
git status
Make sure you DO NOT see:
.dart_tool
.idea
build
pubspec.lock


git config --global --add safe.directory C:/Users/1/AndroidStudioProjects/MuthoBazar
git status
git init
git remote add origin https://github.com/AnwarDevProg/muthobazar_full.git
git add .
git commit -m "customer app ok, admin ongoing+ side bar has issue"
git branch -M main
git push -u origin main



or use

Set-ExecutionPolicy -Scope CurrentUser RemoteSigned; .\git_push.ps1 "customer app ok, admin ongoing, sidebar has issue"
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force; .\git_push.ps1 "customer app ok, admin ongoing, sidebar has issue"