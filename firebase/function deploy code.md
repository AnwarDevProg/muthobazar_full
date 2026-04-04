Recommended commands for your case

Since you are adding category reorder callables, use this order:

cd C:\Users\1\AndroidStudioProjects\MuthoBazar\functions
npm install
npm run build


deploy all functions: firebase deploy --only functions

or specific ::
cd ..
firebase deploy --only functions:reorderCategoryGroup,functions:fixCategoryGroupSort