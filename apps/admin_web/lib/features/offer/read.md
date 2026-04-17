2) Do we already have “after sale end date go back to normal price” logic?
For variation:

No, not from the current code.

Your current MBProductVariation only does this:

bool get hasDiscount => salePrice != null && salePrice! > 0 && salePrice! < price;
double get effectivePrice => hasDiscount ? salePrice! : price;

That means variation pricing is currently not date-aware at all. If salePrice exists, effectivePrice uses it, regardless of time.

For product root:

I can confirm the form saves saleStartsAt and saleEndsAt into the product object, but from the files you shared here I cannot safely confirm that the final runtime price resolver already uses those dates everywhere. The preview section in the form is still showing preview.price directly, not a time-aware resolved price.

So the safe conclusion is:

variation: definitely no date-aware sale logic yet
product root: date fields exist, but I cannot confirm a complete resolved-price pipeline from the files shared here
preview UI: not showing a time-aware final selling price right now
3) Recommended pricing model

You now have 3 pricing concepts:

Base price
Native sale price with date window
Future offer/promo/discount page rules

These should not all overwrite the same field blindly.

My recommendation

Keep them as separate layers:

Native product/variation pricing

Stored directly on product or variation:

price
salePrice
saleStartsAt
saleEndsAt
Offer engine

Stored separately in an offers collection:

offer type: flat / percent / promo price
target type: product / variation / category / brand / global
target id
start/end date
priority
active/inactive
maybe stackable or non-stackable

Then at runtime you calculate:

final selling price = pricing resolver(base price + native sale + active offers)

That is much safer than auto-writing offer results into salePrice.

4) Should backend auto-create salePrice from offer page?

My recommendation: no.

Do not let the offer page overwrite product salePrice and saleStartsAt directly.

Why:

it can destroy manual sale configuration
hard to know whether current salePrice came from merchant input or from an offer
editing/removing offers becomes messy
conflict handling becomes painful later
Better approach

Offer page should create its own document, for example:

offerId
targetType = product | variation
targetId
discountType = flat | percent | promo_price
discountValue
startsAt
endsAt
priority
isActive

Then backend or app resolver calculates the effective price.

5) For variable product: target product or target variation?

Exactly as you said, this should support both:

Simple product

Offer can target:

one product
Variable product

Offer can target either:

the whole parent product
or a single variation

That means offer target should support:

product
variation

and later maybe:

category
brand
6) Recommended priority order

I suggest this final precedence:

For simple product
base price
if native sale window active → use native sale
if active offer exists → apply highest-priority offer rule
final resolved price returned
For variable product
variation price
if variation native sale window active → use variation sale
if variation-specific offer exists → apply it
else if parent-product offer exists → apply it
final resolved variation price returned

This gives clear behavior.

7) What fields should be added now
Add to MBProductVariation

I recommend adding:

DateTime? saleStartsAt
DateTime? saleEndsAt

and later also, if you move more per-variation commercial fields:

quantity/package/tolerance fields
maybe variation-level min/max/step qty
Add resolver methods

For both product and variation, make date-aware methods like:

bool get isSaleActiveNow
double get effectivePriceNow

For variation, current hasDiscount and effectivePrice are too simple for your new design.

8) My direct answer to your offer-flow question

Your proposed flow is close, but I would refine it like this:

Not preferred

“Create offer → backend writes salePrice/sale dates into product or variation”

Preferred

“Create offer → backend stores offer rule separately → pricing resolver calculates final price automatically”

That is the scalable way.

9) Best next step

I recommend we do this next in order:

upgrade MBProductVariation with saleStartsAt and saleEndsAt
update VariationDialog to edit those fields
add date-aware variation pricing helpers
then define the offer document schema and priority rules
after that, implement offer page

If you want, I’ll next give you the exact field list and patch plan for MBProductVariation sale date upgrade.