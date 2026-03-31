That means:

Firebase root: C:\Users\1\AndroidStudioProjects\MuthoBazar\firebase
Functions root: C:\Users\1\AndroidStudioProjects\MuthoBazar\firebase\functions

So your command flow should be:

Build functions

From functions folder:

cd "C:\Users\1\AndroidStudioProjects\MuthoBazar\firebase\functions"
npm install
npm run build
Deploy functions

From the firebase root folder:

cd "C:\Users\1\AndroidStudioProjects\MuthoBazar\firebase"
firebase deploy --only functions

That part is correct for your monorepo.