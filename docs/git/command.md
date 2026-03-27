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



git status
git init
git remote add origin https://github.com/AnwarDevProg/muthobazar_full.git
git add .
git commit -m "Initial monorepo setup (Melos + workspace + architecture)"
git branch -M main
git push -u origin main