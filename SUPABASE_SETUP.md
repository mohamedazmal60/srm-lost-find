# Supabase connection checklist

This application is Supabase-only. There is no demo backend or local fallback.

## 1. Apply the database schema

1. Open the Supabase project `dpnjzudrxbgeuewpxfnf`.
2. Open **SQL Editor → New query**.
3. Paste the complete contents of `supabase_schema.sql` and run it.
4. Confirm that the tables `profiles`, `items`, `claim_requests`, `content_reports`, `notifications`, and `direct_messages` exist, along with the `item-photos` Storage bucket.

The SQL adds the `register_number` field, a unique index, the `profiles_public` safe view, registration trigger, RLS policies, and storage policies. It is written to be re-runnable. Existing students must update their register number and department from **My Profile** after the migration.

## 2. Configure the app key

For local development, copy `.streamlit/secrets.toml.example` to `.streamlit/secrets.toml`, then set:

```toml
[supabase]
url = "https://dpnjzudrxbgeuewpxfnf.supabase.co"
anon_key = "YOUR_SUPABASE_PUBLISHABLE_KEY"
```

Get the publishable key from **Supabase → Project Settings → API Keys**. A legacy anon key is also acceptable. Never use the `service_role` key or a secret key.

For Streamlit Community Cloud, paste the same TOML block into **App → Settings → Secrets**. Do not commit `.streamlit/secrets.toml` to GitHub.

## 3. Run and verify

```bash
python -m pip install -r requirements.txt
streamlit run app.py
```

Register a test account with full name, unique register number, department, email and password. Verify that the profile row appears in `public.profiles`, then create a Lost report and a Found report. Verify the report rows in `public.items` and uploaded images in Storage → `item-photos`.

If the publishable key is missing or Supabase cannot be initialized, the app displays a configuration error and stops. It does not switch to temporary demo data.

## Privacy

Full register numbers are stored in `profiles` and shown only on the student's own profile (and to administrators). Item cards and report details show a masked value via `profiles_public`. Do not remove that view or make the full `profiles` table publicly readable.

## Basic Smart Matching

The app ranks opposite-type open reports in the same category using title similarity, shared description keywords and whether the campus location matches. It reads report rows from Supabase and does not require an external AI API or additional database table. Scores are suggestions only and must never be treated as proof of ownership.
