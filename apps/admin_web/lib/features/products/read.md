1. selecting attribute En name will auto fill bn name and code, 2. after selecting code will auto fill name en and bn.
3. selecting attribute value will fill the label bn and en
4. when click on save variation, it closes the dialog with showing warning if has duplicate variation, but it should not close the dialog, only show the warning, so the user can change the selected variation.


media selection is already croping image, but it should try to get full image inside the ration either full height or weight









Exact resolver rules

Think of price resolution as a pipeline.

A. Resolve the commercial owner

For a simple product:

owner = product

For a variable product:

owner = selected variation

That means price calculation should happen against:

product fields for simple products
variation fields for variable products
B. Apply native sale first

Start with:

workingPrice = base price

If native sale is active at current time:

workingPrice = salePrice

Native sale is active only when:

salePrice exists
salePrice > 0
salePrice < price
now >= saleStartsAt if start exists
now <= saleEndsAt if end exists

If the sale end time passes, price does not need to be written back in Firestore.
The resolver simply stops using salePrice and returns price.

That is the cleanest design.

C. Apply automatic offers next

Offers page should create separate offer documents, not overwrite product price fields.

Each offer should contain at least:

id
targetType: product | variation | category | brand | global
targetId
discountType: flat | percent | promo_price
discountValue
startsAt
endsAt
priority
isActive
stackMode

Now evaluate only active offers for the current owner.

Conflict rule for automatic offers

My recommendation:

collect all applicable active offers
sort by:
highest priority
if same priority, lowest resulting final price
if still same, earliest created or lowest sort order
apply only one automatic offer by default

That keeps behavior predictable.

Offer calculation rules

If offer type is:

flat: workingPrice - value
percent: workingPrice * (1 - value/100)
promo_price: value

Always clamp:

never below 0
never above current workingPrice
D. Apply promo code last

Promo code should be the last layer.

Why:

user enters it intentionally
it is usually cart/checkout specific
it may have usage limits and eligibility rules
it must be validated on backend

So the sequence should be:

base price → native sale → automatic offer → promo code

Promo code at the current stage

Promo code should not mutate:

salePrice
saleStartsAt
saleEndsAt

It should be a separate checkout-time mechanism.

Best current-stage implementation

Add a separate collection such as:

promo_codes

Each code document can contain:

code
isActive
startsAt
endsAt
discountType: flat | percent | promo_price
discountValue
minCartAmount
maxDiscountAmount
totalUsageLimit
perUserUsageLimit
firstOrderOnly
allowedWithNativeSale
allowedWithAutoOffer
scopeType: cart | product | variation | category | brand
targetIds
userEligibility if needed later

This should be validated by backend at cart/checkout time, not trusted from client input.