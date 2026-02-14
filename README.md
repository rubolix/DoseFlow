# DoseFlow 💊

A native iOS app for tracking controlled stimulant medications across a family. Built with SwiftUI and SwiftData.

## Why DoseFlow?

Stimulant medications (like those for ADHD) are Schedule II controlled substances with strict refill rules. You can't just call in a refill whenever — you need to carefully track:

- **When you picked up** each prescription and **how many pills** you received
- **When you'll run out** so you can plan ahead
- **When to order a refill** (typically 7 days before running out)
- **When you can actually pick it up** (typically 4 days before running out, per pharmacy/insurance rules)

When you're managing this for multiple family members, each with different medications and schedules, it gets complicated fast. DoseFlow does all the math for you and keeps everything in one place.

## Features

### 📋 Family Medication Tracking
- Track up to multiple family members, each with their own medications
- Log prescription pickups with date and pill count
- Automatically calculates pills remaining, run-out date, order date, and earliest pickup date
- Color-coded dashboard for quick status overview

### 🏫 School Bottle Tracking
- Track afternoon medication bottles kept at school
- Uses the **Seattle Public Schools 2025–2026 calendar** to calculate when school bottles will run out
- Accounts for weekends, holidays, winter break, spring break, and in-service days

### 📅 Calendar Integration
- Add refill reminders, order dates, and pickup dates directly to your iPhone calendar
- Uses EventKit for native iOS calendar access

### 🔒 Archive/Unarchive
- Pause tracking for medications that are temporarily discontinued
- Pill count freezes at the time of archiving
- Unarchive to resume tracking from the frozen count

### ✏️ Fully Editable
- Add, edit, and delete family members, medications, and pickup entries
- Swipe-to-delete on pickup history and school bottle entries
- Tap any entry to edit it

### 💾 Local Data Storage
- All data is stored on-device using SwiftData
- No accounts, no cloud, no data leaves your phone
- Counts update automatically as days pass

### 📦 Backup & Restore
- Export all your data as a human-readable JSON file
- Save backups to Files, AirDrop, email, or any share destination
- Import from a previously exported backup to restore your data
- Import is non-destructive — it adds data alongside what's already there
- Access via the ⚙️ gear icon on the dashboard

## Screenshots

*Coming soon — app is in active TestFlight testing.*

## Tech Stack

- **SwiftUI** — Declarative UI framework
- **SwiftData** — Apple's native persistence framework
- **EventKit** — Calendar integration
- **Xcode 26+** / **iOS 18+**

## Getting Started (Fork & Run Locally)

### Prerequisites

- A Mac with **Xcode 26** or later installed (free from the Mac App Store)
- An **Apple ID** (free tier works for simulator testing)
- Optional: An **Apple Developer account** ($99/year) for TestFlight or device deployment

### Steps

1. **Fork this repository** on GitHub

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/DoseFlow.git
   cd DoseFlow
   ```

3. **Open in Xcode**
   ```bash
   open DoseFlow.xcodeproj
   ```

4. **Select a simulator** — In Xcode's top toolbar, choose an iPhone simulator (e.g., iPhone 17 Pro)

5. **Run** — Press ▶️ (Cmd+R) to build and launch in the simulator

That's it! No dependencies to install, no package managers, no API keys.

### Running on a Physical iPhone

1. Plug your iPhone into your Mac via USB
2. Enable **Developer Mode** on your iPhone: Settings → Privacy & Security → Developer Mode → ON (restart required)
3. In Xcode: select your iPhone as the run destination
4. Go to **Xcode → Settings → Accounts** and sign in with your Apple ID
5. Select the DoseFlow target → **Signing & Capabilities** → set Team to your Apple ID
6. Press ▶️ to build and install
7. On first launch, your iPhone may say "Untrusted Developer" — go to **Settings → General → VPN & Device Management** and trust your developer profile

> **Note:** With a free Apple ID, the app expires after 7 days and needs to be re-deployed from Xcode. An Apple Developer account ($99/year) removes this limitation.

### Running Tests

The project includes a standalone test suite covering medication calculations, SPS calendar correctness, school bottle tracking, and the archive feature:

```bash
cd DoseFlow
swift run_tests.swift
```

All 61 tests should pass.

## Customizing the School Calendar

The app includes the **Seattle Public Schools 2025–2026 calendar** in `DoseFlow/Utilities/SPSCalendar.swift`. To adapt for your school district:

1. Open `SPSCalendar.swift`
2. Update the `firstDay` and `lastDay` dates to match your school year
3. Update the `breaks` array with your district's holidays, breaks, and in-service days
4. The format is simple — each entry is a date range: `(month, day, year)` to `(month, day, year)`

## Project Structure

```
DoseFlow/
├── DoseFlowApp.swift              # App entry point with SwiftData container
├── Models/
│   ├── Person.swift               # Family member model
│   ├── Medication.swift           # Medication model with calculation logic
│   ├── Pickup.swift               # Prescription pickup record
│   └── SchoolBottle.swift         # School bottle entry
├── Utilities/
│   ├── SPSCalendar.swift          # Seattle Public Schools calendar
│   ├── CalendarManager.swift      # EventKit calendar integration
│   └── ColorExtensions.swift      # Color helpers
├── Views/
│   ├── DashboardView.swift        # Main dashboard
│   ├── PersonDetailView.swift     # Person detail with med list
│   ├── MedicationDetailView.swift # Medication detail with status
│   ├── AddPersonView.swift        # Add family member
│   ├── AddMedicationView.swift    # Add medication
│   ├── LogPickupView.swift        # Log a prescription pickup
│   ├── SchoolBottleView.swift     # Log school bottle count
│   ├── EditPersonView.swift       # Edit family member
│   ├── EditMedicationView.swift   # Edit medication
│   ├── EditPickupView.swift       # Edit pickup entry
│   └── Components/
│       └── PersonCard.swift       # Dashboard card component
└── Assets.xcassets/               # App icon and colors
```

## License

This project is provided as-is for personal use. Feel free to fork and adapt for your own family's needs.
