# HAA Convention 2026 — Mobile App

**The official mobile app for the Havyaka Association of the Americas (HAA) 21st Biennial Convention.**

July 3–5, 2026 · Rosary High School · Aurora, Illinois

Built with SwiftUI for **iPhone only · iOS 17+ · Xcode 15+**

---

## What It Is

This is the convention companion app attendees use on their phones during HAA 2026. It brings the full program, venue map, convention info, shared photo gallery, and account tools into one place — designed for use on the convention floor, in hotels, and throughout the weekend.

Most of the app works **offline** (schedule, map, convention info). **Account sign-in, check-in, and the photo gallery** require an internet connection and talk to the HAA backend on Bluehost.

---

## How It Works

### App structure (5 tabs)

| Tab | What it does |
|-----|----------------|
| **Home** | Countdown to convention start, quick-access shortcuts, star attractions, and a **Log in here** button when signed out |
| **Schedule** | Full 4-day program (Jul 2–5) with expandable event cards and detail sheets |
| **Map** | Apple Maps with venue, hotel, and food locations; filters, directions, and detail sheets |
| **Photos** | Shared attendee gallery — **login required** to view and upload |
| **More** | Two sections: **Info** (venue, committees, FAQ, sponsors, about HAA) and **Account** (sign up, log in, profile, check-in) |

The Home quick-access cards and **Log in here** button navigate directly to the right tab or section.

### Account & check-in

Attendees who registered for the convention can link the app to their registration:

1. **Sign Up** — enter the registrant email; a 5-digit login code is emailed via the backend
2. **Log In** — enter email + 5-digit code; profile is saved locally on the device
3. **Check In** — once logged in, tap Check In on the profile screen to record arrival at the convention

Auth is handled by `api/auth.php` against the existing MySQL registration table (`sTu_haa2026_convention_registration`).

### Photo gallery

The shared gallery is backed by `api/photos.php` + **Cloudflare R2**:

- **List** — loads photo/video metadata from MySQL on Bluehost
- **Upload** — files go to Cloudflare R2; only the public URL is stored in MySQL
- **Limits** — 10 photos and 2 videos per logged-in user; 45 MB max per file

If the API is unreachable, the Photos tab shows an offline banner and falls back to demo content where configured.

**Setup:** See [`api/migrations/PHOTOS_R2_SETUP.md`](api/migrations/PHOTOS_R2_SETUP.md) for Cloudflare R2 configuration steps.

### Offline behavior

A network monitor shows a banner only on **Account** and **Photos** when there is no service. Home, Schedule, Map, and the Info section of More work without a connection using bundled convention data.

---

## Project Structure

```
havyaka-app/
├── HAAConvention/                  # iOS app (SwiftUI)
│   ├── HAAConventionApp.swift      # App entry point
│   ├── DesignSystem.swift          # Colors, typography, spacing
│   ├── Models/
│   │   └── ConventionModels.swift  # Data models + static schedule/map/info data
│   ├── Services/
│   │   ├── AuthViewModel.swift     # Login state, profile persistence
│   │   ├── RegistrationAPI.swift   # auth.php client
│   │   ├── PhotosAPI.swift         # photos.php client
│   │   └── NetworkMonitor.swift    # Online/offline detection
│   └── Views/
│       ├── ContentView.swift       # Tab bar + navigation
│       ├── HomeView.swift
│       ├── ScheduleView.swift
│       ├── MapView.swift
│       ├── PhotosView.swift
│       ├── InfoView.swift          # More tab (Info + Account)
│       ├── AccountView.swift       # Sign up / log in / profile UI
│       └── SharedComponents.swift
│
├── api/                            # PHP backend (deploy to Bluehost manually)
│   ├── auth.php                    # sendcode, login, checkin
│   ├── photos.php                  # list, upload (→ Cloudflare R2)
│   ├── r2_storage.php              # R2 S3-compatible upload helper
│   ├── config.php / db.php         # DB + R2 credentials (gitignored)
│   └── migrations/                 # SQL + PHOTOS_R2_SETUP.md
│
└── HAAConvention.xcodeproj
```

Convention-specific content (schedule days, map pins, FAQ text, etc.) lives in `ConventionModels.swift` so it can be updated for future conventions without restructuring the app.

---

## Backend (Bluehost)

The app calls:

- `https://havyak.org/api/auth.php` — registration login and check-in
- `https://havyak.org/api/photos.php` — photo gallery (files on Cloudflare R2)

PHP files and `.env` credentials are **gitignored** and deployed to Bluehost separately. SQL migrations in `api/migrations/` must be run on the MySQL database. Photo/video files are stored on **Cloudflare R2**, not Bluehost disk — see [`api/migrations/PHOTOS_R2_SETUP.md`](api/migrations/PHOTOS_R2_SETUP.md).

---

## Open & Run (developers)

1. Open the project:
   ```
   open HAAConvention.xcodeproj
   ```

2. Set your **Development Team** under Signing & Capabilities for the `HAAConvention` target.

3. Run on an iPhone simulator or device (⌘R).

The app expects the live API at `havyak.org`. Local PHP testing is optional; see files under `api/` if you need to run the backend elsewhere.

---

## Design

| Token | Role |
|-------|------|
| `HAA.Colors.charcoal` | Nav bars, dark headers |
| `HAA.Colors.orange` | Primary actions |
| `HAA.Colors.gold` | Accents and highlights |
| `HAA.Colors.cream` | Page backgrounds |
| Georgia (serif) | Display headings and Kannada text |
| System rounded | UI body copy |

---

*Official HAA Convention 2026 mobile app · Havyaka Association of the Americas*
