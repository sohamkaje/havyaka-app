# Photo Gallery — Cloudflare R2 Setup

Convention photos and videos are stored on **Cloudflare R2**, not Bluehost disk. MySQL on Bluehost only stores metadata (caption, uploader, URL).

---

## Step 1: Create a Cloudflare account and R2 bucket

1. Go to [https://dash.cloudflare.com](https://dash.cloudflare.com) and sign in (or create a free account).
2. In the left sidebar, open **R2 object storage**.
3. Click **Create bucket**.
4. Name it `haa2026-photos` (or any name — use the same name in `config.php` later).
5. Choose a location close to your users (e.g. **Eastern North America**).
6. Create the bucket.

---

## Step 2: Enable public access (so the app can load images)

1. Open your new bucket → **Settings**.
2. Under **Public access**, enable **Allow Access** or connect a **Custom Domain** / **r2.dev** subdomain.
3. Copy the **public bucket URL** — it looks like:
   - `https://pub-xxxxxxxx.r2.dev`
   - or `https://photos.havyak.org` if you use a custom domain

This URL becomes `r2_public_base_url` in `config.php`.

**Test:** After uploading a file, you should be able to open  
`https://YOUR-PUBLIC-URL/haa2026/test.jpg` in a browser.

---

## Step 3: Create R2 API credentials

1. In Cloudflare dashboard → **R2** → **Manage R2 API tokens** (or **Overview** → **Manage API tokens**).
2. Click **Create API token**.
3. Permissions: **Object Read & Write** for your bucket.
4. Copy and save:
   - **Access Key ID**
   - **Secret Access Key**
   - **Account ID** (shown on the R2 overview page)

---

## Step 4: Update Bluehost `config.php`

On your server at `public_html/api/config.php`, add these lines inside the `return [ ... ]` array:

```php
'photos_table' => 'sTu_haa2026_convention_photos',

// Cloudflare R2 (photo/video storage)
'r2_account_id'         => 'YOUR_CLOUDFLARE_ACCOUNT_ID',
'r2_access_key_id'      => 'YOUR_R2_ACCESS_KEY_ID',
'r2_secret_access_key'  => 'YOUR_R2_SECRET_ACCESS_KEY',
'r2_bucket'             => 'haa2026-photos',
'r2_public_base_url'    => 'https://pub-xxxxxxxx.r2.dev',
```

Replace all placeholder values with your real credentials from Steps 2–3.

---

## Step 5: Upload PHP files to Bluehost

Upload these files to `public_html/api/` (overwrite existing):

| File | Purpose |
|------|---------|
| `photos.php` | Gallery list + upload API |
| `r2_storage.php` | R2 upload helper (required by photos.php) |
| `config.php` | Your credentials (do not commit to git) |

Ensure PHP **curl** extension is enabled (standard on Bluehost).

---

## Step 6: Run the photos table migration (if not done yet)

In phpMyAdmin on Bluehost, run:

`api/migrations/add_photos_table.sql`

---

## Step 7: Test from the app

1. Log in on the **Account** tab.
2. Open **Photos** → upload one photo and one short video.
3. Confirm the gallery loads images (URLs should start with your `r2_public_base_url`, not `havyak.org/uploads/`).
4. In Cloudflare R2 dashboard, confirm files appear under `haa2026/`.

---

## Step 8: Free up Bluehost disk (optional)

After R2 is working, delete old files from:

`public_html/uploads/haa2026/`

New uploads will no longer use Bluehost disk.

---

## Upload limits (server-side)

| Limit | Value |
|-------|-------|
| Max file size | 45 MB |
| Photos per logged-in user | 10 |
| Videos per logged-in user | 2 |
| Images | Auto-resized to max 2048px (JPEG 85%) when GD is available |

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Photo storage is not configured` | Add all `r2_*` keys to `config.php` |
| `R2 upload failed (HTTP 403)` | Check API token permissions and bucket name |
| Gallery shows broken images | Verify public access / `r2_public_base_url` is correct |
| `Upload limit reached` | Expected — each account has caps |

---

## Cost

Cloudflare R2 free tier includes **10 GB storage** and **free egress**. A typical convention weekend stays within free tier or costs a few dollars if exceeded.
