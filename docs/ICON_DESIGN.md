# RemindLy — Icon Design Plan

This document captures the icon design brief for the RemindLy app.  
The icon is created manually in Adobe Illustrator and then exported as
`assets/icon/app_icon.png` for use with `flutter_launcher_icons`.

---

## Specs

| Property | Value |
|---|---|
| **Canvas size** | 1024 × 1024 px |
| **Adaptive icon background** | `#0061A4` (configured in `pubspec.yaml`) |
| **Foreground color** | White `#FFFFFF` |
| **Android safe zone** | Keep the mark within the central **66 %** (≈ 680 × 680 px) — everything outside can be cropped by the system's shape mask |
| **Export format** | PNG-24, transparent background (foreground layer only) |
| **Minimum stroke weight** | 60 – 80 px at 1024 px canvas (so it reads at 48 dp on device) |

---

## Design Concepts

### Concept 1 — Bell with a Checkmark ⭐ Recommended
> Classic, instantly readable — the universal "reminder" symbol.

- Bold notification bell silhouette, rounded/thick strokes
- Small filled circle with a ✓ (or a contrasting dot) in the bottom-right corner of the bell
- White foreground on `#0061A4` background
- Bell shape stays well within the adaptive safe zone
- Reads cleanly even at 48 dp launcher size

---

### Concept 2 — Clock + Bell Hybrid
> Communicates "reminder at a specific time."

- Circle clock face — no numerals, just two simple hands at ~10:10
- A small bell merged into the top of the clock (acting as a handle)
- Clean single-weight stroke throughout
- White on blue; very minimal and premium-feeling at small sizes

---

### Concept 3 — Pill / Squircle "R" Wordmark
> Modern, brand-forward approach.

- Rounded rectangle (squircle) background in `#0061A4`
- Stylised bold **R** (for RemindLy) where the leg of the R curves into a bell or a checkmark
- Good choice if you want the icon to hint at the app name

---

### Concept 4 — Ripple / Notification Ping
> Abstract, attention-catching, geometric.

- Three concentric arcs (like a sound-wave ripple) emanating from a central dot
- Evokes an incoming notification ping
- Very geometric — scales and crops cleanly on any Android adaptive mask
- Optional: tiny bell or dot at the centre anchor

---

## Illustrator Workflow

1. **New document** → 1024 × 1024 px, RGB color space
2. Draw the icon mark in **white** (`#FFFFFF`) on a temporary **`#0061A4`** background layer (for visual reference only — this layer is NOT exported)
3. Keep all paths within the **central 680 × 680 px** guide rectangle (adaptive safe zone)
4. Use `Object → Expand` to convert all strokes to filled shapes before export
5. Hide / delete the blue background layer
6. **Export** → `File → Export As → PNG`, 1024 × 1024, transparent background
7. Save output to `assets/icon/app_icon.png`
8. Regenerate platform icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

---

## After Export Checklist

- [ ] `assets/icon/app_icon.png` replaced with new file
- [ ] `flutter pub run flutter_launcher_icons` run successfully
- [ ] App launched on Android emulator — launcher icon looks correct
- [ ] App launched on iOS simulator — launcher icon looks correct
- [ ] Icon tested on circular, squircle, and rounded-square adaptive masks (Android)
