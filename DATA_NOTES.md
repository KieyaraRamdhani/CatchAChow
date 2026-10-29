# CatchAChow — Price Data Notes

The app's included grocery values are seed/example listings, not live API results. They are dated snapshots and may change by date, region, branch, availability or delivery method. The app must not describe them as current verified prices.

For a production version, use only retailer-authorised APIs/feeds or a permitted source. For every item retain:
- retailer and region/branch where available
- product name, package size and unit
- listed price and currency (ZAR)
- source URL or API record identifier
- timestamp fetched and freshness status
- stock/availability if provided

When a retailer feed is unavailable or stale, show “price not verified” and let the user check the retailer. Never fabricate prices or claim a saving without a comparable basket and recorded source data.
