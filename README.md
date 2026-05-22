# HAA Convention 2026 — iOS App Demo

A SwiftUI pitch demo for the Havyaka Association of the Americas (HAA) convention app.
**Designed for iPhone only · iOS 17+ · Xcode 15+**

---

## Project Structure

```
HAAConvention/
├── HAAConventionApp.swift          # App entry point (@main)
├── DesignSystem.swift              # Colors, typography, spacing, shared modifiers
│
├── Models/
│   └── ConventionModels.swift      # All data models + ConventionData (static store)
│
└── Views/
    ├── ContentView.swift           # TabView + custom HAATabBar
    ├── SharedComponents.swift      # Reusable components (NavBar, chips, buttons)
    ├── HomeView.swift              # Home tab: hero, countdown, quick access, attractions
    ├── ScheduleView.swift          # Schedule tab: day selector + expandable event cards
    ├── MapView.swift               # Map tab: MapKit live map + location detail sheets
    ├── PhotosView.swift            # Photos tab: grid + upload popup (PhotosPickerItem)
    └── InfoView.swift              # Info tab: accordion FAQ/venue/committees
```

---

## How to Open & Run

1. **Open in Xcode:**
   ```
   open HAAConvention.xcodeproj
   ```

2. **Set your Development Team:**  
   Select the `HAAConvention` target → Signing & Capabilities → set your Apple ID team.

3. **Run on Simulator or Device:**  
   Choose an iPhone simulator (iPhone 15 Pro recommended) → ⌘R

---

## Key Features

### Home
- Live countdown timer to July 3, 2026 convention start
- Quick access grid to all 4 sections
- Star attractions with dark theme highlight cards
- Diagonal decorative pattern on hero

### Schedule
- Day tabs for Thu Jul 2 through Sun Jul 5
- Each event is a tappable card with tag, highlight badge, and 2-line preview
- Sheet modal on tap with full event details, location, and timing

### Map (MapKit — uses Apple Maps natively)
- Live `Map` view with colored annotation pins
- Category filter pills (All / Venue / Hotels / Food)
- Tap a pin OR a list row to highlight and zoom
- Detail sheet with embedded mini-map and "Get Directions" button that opens Apple Maps

### Photos
- 3-column photo grid with album tabs
- "Add yours" button + banner both open `UploadPhotoSheet`
- Upload sheet: `PhotosPicker` for camera roll, caption input, name/chapter input, day selector
- Simulated 1.5s upload with success state
- Tap any photo tile to open full-screen detail sheet

### Info
- Accordion cards (one open at a time): Venue & Dates, Committees, FAQ, Sponsors, About HAA
- Inline committee progress bars
- Expandable FAQ items
- Deep links to haaconvention.org, registration, and email

---

## Design System (`DesignSystem.swift`)

| Token | Value |
|-------|-------|
| `HAA.Colors.charcoal` | `#1A1612` (dark nav/header bg) |
| `HAA.Colors.orange` | `#C8530A` (primary CTA) |
| `HAA.Colors.gold` | `#B87D1A` (accent/highlight) |
| `HAA.Colors.cream` | `#FDFAF6` (page background) |
| Font (serif) | Georgia — used for Kannada text + display headings |
| Font (sans) | `.system(..., design: .rounded)` — UI copy |

---

## What's Placeholder

- Photo tiles use SF Symbols instead of real images (swap `photo.imageName` for `UIImage`)
- Upload simulates a 1.5s network call — wire to your backend / Firebase Storage
- Location coordinates are approximate — refine with exact addresses
- Map uses Apple Maps (MapKit). Google Maps SDK can be substituted with `GoogleMaps` pod

---

## Reusability for Future Conventions

The app is designed to be reusable — all convention-specific data is isolated in `ConventionData` inside `ConventionModels.swift`. For future conventions:

1. Update `ConventionData.days` with the new schedule
2. Update `ConventionData.locations` with new venue/hotel coordinates  
3. Change the convention date in `HomeView.conventionDate()`
4. Photos upload to a backend — the gallery persists across sessions automatically

---

*Built as a pitch demo for the HAA 2026 website team. July 3–5, 2026 · Rosary High School, Aurora, IL.*
