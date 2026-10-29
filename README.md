# CatchAChow — Flutter app + backend starter

CatchAChow is a yellow-and-red South African student food-budgeting and meal-planning app. This updated source adds a Supabase sign-up/login flow, email confirmation code screen, password validation, subscription-plan UI, restaurant-day budgeting, birthday/Black Friday offer watchlists, and a secure-backend pattern for Gemini food-only chat and approved retailer-feed adapters.

github url:https://github.com/KieyaraRamdhani/CatchAChow
website url: https://kieyararamdhani.github.io/CatchAChow/

## What is implemented in this source

- **Sign-up fields:** name, surname, date of birth, email, phone and password.
- **Password rule:** more than 6 characters and at least one special character.
- **Email verification:** Supabase sign-up + OTP verification screen. Supabase project settings and email templates must be configured.
- **Login and sign-out:** Supabase Auth when credentials are configured; demo mode is available without creating an account.
- **Subscription screen:** Free, Premium Monthly (R50/month) and Premium Yearly (R100/year), feature descriptions and renewal UI. Payment processing and paid-entitlement enforcement are NOT connected; selections are demo-only until a payment provider and server-side verification are implemented.
- **Restaurant/cheat-day budget:** allows a restaurant allowance to be counted inside the selected budget or tracked separately, with transparent remaining balance.
- **Birthday specials and Black Friday:** starter watchlists only, not verified live promotions. Users must confirm eligibility, dates and terms with the business.
- **Gemini food-only backend:** `backend/main.py` checks the request topic and sends supported questions to Gemini. The mobile app never needs to contain the Gemini API key.
- **Retailer feed adapter:** backend queries only feed URLs configured by you and returns product results from those feeds. No retailer feed is preconnected, and this project does NOT claim live pricing until approved data feeds are configured.

## 1. Configure Supabase Auth

1. Create a project at https://supabase.com/.
2. In Authentication settings, enable email sign-ups and configure email confirmation.
3. Configure the email template so sign-up sends a short numeric OTP that matches Supabase's OTP verification flow. Test the exact template before launch.
4. Copy the project URL and anon/public key. The anon key is intended for client use; never put a Supabase service-role key in the app.
5. Configure the root `.env` file (it is listed in `.gitignore`) with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `CATCHACHOW_API_URL`. The app loads these values with `flutter_dotenv`. The Supabase URL must be the project root (`https://YOUR_PROJECT.supabase.co`), not the `/rest/v1/` REST endpoint.
6. Run Flutter:

```bash
flutter pub get
flutter run
```

For Android emulator, `10.0.2.2` points to the development host. For a physical phone, use the host computer's LAN IP while on the same network, or a deployed HTTPS backend. The Supabase publishable/anon key is visible in a client app by design; secure database access with Row Level Security (RLS), never a service-role key. A `.env` bundled into Flutter is configuration, not a secure vault.

Supabase stores the extra sign-up fields as user metadata. Before launch, add a profile table only if needed, enable Row Level Security, and ensure users can read/update only their own row. Do not store passwords yourself.

## 2. Run the Gemini backend

Python 3.10+ is recommended.

```bash
cd backend
python -m venv .venv
# Windows PowerShell: .venv\Scripts\Activate.ps1
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
```

The backend loads server-side secrets from `backend/.env` for local development. Keep this file out of Git and never copy its Gemini key into Flutter. Edit `backend/.env` with your Gemini API key and model, then run:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

For production, set secrets in the hosting provider's secret/environment-variable settings instead of uploading `.env`. Since the Gemini key was shared in chat, rotate it in Google AI Studio and replace it in `backend/.env` before using the app.

Set `CATCHACHOW_API_URL` in the Flutter run command to the backend address. Deploy the backend behind HTTPS, add rate limiting, authentication checks, logging controls and abuse protection before public release. Verify the current Gemini model name and API access in Google AI Studio before deployment.

## 3. Live grocery price feeds

Retailer websites do not all provide a public, unrestricted product-pricing API. You must obtain permission and review the provider's licence before connecting a feed. The backend supports configured feed URLs through environment variables:

- `PICK_N_PAY_FEED_URL`
- `CHECKERS_FEED_URL`
- `SPAR_FEED_URL`
- `MAKRO_FEED_URL`
- `BOXER_FEED_URL`
- `GAME_FEED_URL`
- `SHOPRITE_FEED_URL`
- `WOOLWORTHS_FEED_URL`
- `FOOD_LOVERS_FEED_URL`
- `BLUFF_MEAT_FEED_URL`

Each feed URL must return a JSON array with fields such as `name`, `size`, `price`, `checked_at` and `product_url`. The API adapter returns up to 20 items per configured feed. This is an adapter contract, not a claim that the listed stores have provided APIs. `Take n Pay` was interpreted as a likely typo for Pick n Pay; confirm the intended retailer. Makro is spelled Makro.

The UI's existing sample prices remain clearly marked as sample listings, not live store data. Never present sample prices as live prices. Include product size, store/region, timestamp and availability status in the production UI.

## 4. Subscriptions and payments

The app displays the requested prices: R50 monthly and R100 yearly. The yearly price is less than two monthly payments; confirm this is intentional. The current screen is only a selection/renewal prototype. For real subscriptions:

1. Choose a payment provider that supports your business and South African customers.
2. Create the payment/session on the backend, not directly in the app.
3. Verify provider webhooks server-side.
4. Store subscription status and renewal dates in a database protected by Row Level Security.
5. Gate premium features using server-verified entitlements, not a local boolean.
6. Support cancellations, failed renewals, refunds and receipts.

Do not claim payments or renewals work until this is integrated and tested.

## 5. Food safety and nutrition

Meal output and calorie values are estimates, not medical advice. Calories depend on portions, brands, cooking methods and individual needs. Do not promise that a budget meal plan meets a user's complete nutritional needs without a validated nutrient database and qualified review. Ask about allergies and dietary needs, but do not guarantee allergy safety from AI alone.

## 6. Birthday and Black Friday offers

The current offer screens are starter watchlists and do not show verified active promotions. To make them live, add a permitted offer feed or a curated admin dataset containing the merchant, offer, eligibility, location, source URL, verified date and expiry date. Hide expired deals and tell users to confirm terms with the restaurant or retailer.

## 7. Build an APK

Install Flutter and Android Studio with Android SDK, then run:

```bash
flutter doctor
flutter pub get
flutter analyze
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`.

**Important:** An APK has not been built as part of this source update because the build environment does not have the Flutter SDK/Android toolchain available. Run the commands on a machine with Flutter and Android Studio installed.

## 8. Security and release checklist

- `android:usesCleartextTraffic="true"` is enabled for local HTTP development only; change it to `false` and use HTTPS for any production release.
- Keep `.env` files, Gemini keys, payment secrets and retailer credentials out of Git and out of the APK.
- The current plan selector is not a secure paywall. A production app must check verified subscription status from the backend before enabling premium features.
- The app collects date of birth and phone number. Collect only what is necessary, explain why it is collected, secure access, and provide a privacy policy and deletion path before launch.
- The food-only filter is a guardrail, not a guarantee against every prompt-injection attempt. Keep server-side policy checks, output validation, rate limits and abuse monitoring.
- To make calorie planning reliable, connect a recognised nutrition dataset with portion weights and nutrient values, calculate nutrition deterministically, and have recipes reviewed by a qualified nutrition professional. An optional calorie target field is provided, but the prototype does not calculate individual energy requirements or guarantee nutritional adequacy.

## 8. Added in this iteration: budget-to-meal planner and offline pantry

Open **Build a budget-to-meal plan** from Home or More. The planner currently supports:

- budget amount, number of days and household size;
- vegetarian and microwave/kettle-only filters, plus a no-fridge food-safety reminder;
- pantry ingredient entry, saved locally on the device for offline use;
- a simple rule-based selection of sample meal ideas and a consolidated ingredient list that excludes pantry matches;
- visible estimated totals, remaining budget and per-serving illustrative energy estimates.

**Important:** this is an offline prototype, not a validated dietitian-grade plan. The prices and calorie figures are illustrative, the plan currently selects one main meal per day, and the shopping list is not priced using connected retailer feeds yet. It does not guarantee daily calorie needs or complete nutrition. Do not use it for allergy safety without verified ingredient data. These limits are shown in the app.

The basket has also been updated to resolve products from connected feeds as well as the sample catalogue. Product feeds must still be configured and approved before live prices can appear.

## 9. Verified offers and local business API contracts

Two backend starter endpoints are available:

- `GET /api/offers` reads the optional `OFFERS_FEED_URL` feed and returns only entries with `verified: true`, a `source_url`, and a non-expired `expires_at` date.
- `GET /api/businesses` reads the configured `LOCAL_BUSINESS_FEED_URL` and returns entries with a name, location and source URL.

These endpoints do not create or discover offers by themselves. Configure only permitted partner/curated feeds; otherwise they return an empty result and say that no feed is configured. Do not treat a retailer page or aggregator as an unrestricted API without checking its terms.

## 10. Optional Supabase data model

`backend/supabase_schema.sql` provides reviewed starter tables for user profiles, pantry items, saved meal plans, price alerts, shared baskets and subscriptions, with row-level security policies. It is not automatically applied. Review and run it in Supabase SQL editor only when ready. Subscription writes intentionally have no client policy; a trusted backend must update paid status after verifying payment-provider webhooks.

## 11. Remaining production work

Still not implemented end-to-end: payment-provider checkout and webhook verification; backend-enforced premium gates; persistent cloud sync for the planner; price-alert scheduling/notifications; shared basket membership/invitations; a verified nutrition database and complete meal nutrient calculations; live retailer/offer/local-business partnerships; account deletion/export flows; robust chatbot safety testing and rate limits; automated Flutter tests and device QA. The Flutter SDK was not available in the build environment, so this source has not been compiled into an APK here.


## UI refresh (v1.2)
- Added CatchAChow logo artwork and Android launcher icons so the project displays with a branded app icon after installing/building the APK.
- Added collapsible drawer navigation, a persistent visible scroll thumb, settings entry, and saved light/dark mode.
- Added butter-yellow accents and South African flag touches.
- Expanded the grocery sample catalogue to 20 items (sample prices only; they are not live retailer prices).
- Added 17 additional South African-inspired meal ideas, each with a food image URL and a local fallback image. The home hero now loads a photo of people sharing food from Unsplash, with a local fallback if the network is unavailable.
- AI request failures now show a **Try again** action.

### Image and data notes
Meal and grocery thumbnails use Unsplash image URLs and need internet access; if image requests fail, the app displays the local meal photo or category icon. Sample product prices and recipe descriptions are not verified live prices or nutrition advice.

### Build and install on Android
Run `flutter pub get`, then `flutter run` to test. To create an installable Android app, run `flutter build apk --release`; install the resulting APK on your phone. The branded launcher icon is included under `android/app/src/main/res/mipmap-*`. This environment did not have the Flutter SDK available, so Flutter analysis and APK compilation still need to be run locally.
