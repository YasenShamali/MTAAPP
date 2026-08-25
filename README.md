MTA_APP is a Flutter application connected to Supabase for managing sales offers.

## Setup

1. Install Flutter from https://flutter.dev if it is not installed.
2. Ensure the Flutter SDK is available in your PATH.
3. In the project root, run:
   ```bash
   flutter pub get
   ```

## Environment

Create a `.env` file in the project root with these values:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key
```

The `.env` file is already ignored by Git using `.gitignore`.

## Run the app

To launch the application, run:

```bash
flutter run
```

If you do not yet have Flutter project files, run first:

```bash
flutter create .
```

## What is included

- `lib/main.dart`: initializes Supabase and checks configuration.
- `lib/services/auth_service.dart`: authentication and user profile sync.
- `lib/services/offer_service.dart`: offers, media and workflow operations.
- `supabase_schema.sql`: SQL schema for Supabase tables, RLS policies and storage buckets.
