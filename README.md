# Loadr

A simple plate calculator and 4-week workout planner Progressive Web App (PWA).

## Installation

### Web (Progressive Web App)

Visit the app at: https://channing173.github.io/Loadr/

#### Install on iPhone
1. Open the app in Safari
2. Tap the **Share** button (arrow pointing up from a box)
3. Scroll down and tap **Add to Home Screen**
4. Enter a name for the app (or keep "Loadr")
5. Tap **Add** in the top-right corner
6. The app will now appear on your home screen and can be opened like a native app

#### Install on Android
1. Open the app in Chrome (or your mobile browser)
2. Tap the **menu** button (three vertical dots)
3. Tap **Install app** or **Add to Home Screen**
4. Confirm the installation
5. The app will now appear on your home screen

### Local Development

```bash
# Simply open index.html in a browser (or use a local server)
python -m http.server 8000
# Then visit http://localhost:8000
```

## Features

### Workout Planner
- **Pre-built Programs**: Choose from Powerlifting, Bodybuilding, or General Health
- **Custom Programs**: Create your own 1-7 day workout plans
- **4-Week Cycles**: Intelligent rep and weight progression across weeks
- **Exercise Tracking**: Mark exercises complete with per-set tracking for Week 1
- **Weight Progression**: Auto-calculated weights for weeks 2-4 based on week 1 baseline
- **Rep Transformation**: Reps scale intelligently week-to-week (e.g., 8-10 → 7-9)
- **Persistent Storage**: All workouts and progress saved to device

### Plate Converter
- **Dual Unit Support**: Switch between lbs and kg
- **Barbell Selection**: Calculate plates for 45lb or 55lb bars
- **Visual Display**: Circle representations of plates with totals and per-side counts
- **Accurate Math**: Proper even-plate calculations with no fractional remainder

### Unit Converter
- **Quick Conversions**: Convert between lbs and kg instantly
- **Global Toggle**: Switch units app-wide and see all weights recalculate
- **Persistent Conversions**: Remembers last conversion when switching pages

### Additional Features
- **Dark Mode**: Comfortable viewing in any lighting (default theme)
- **Responsive Design**: Optimized for mobile (430px width standard)
- **Offline Support**: Works completely offline with service worker caching
- **Auto-Update**: Checks for app updates on each launch
- **Data Reset**: Clear all data and start fresh with one button

## App Storage

All data is stored locally on your device:
- Workout programs and exercises
- Exercise weights and reps
- Completed sets and exercises
- User preferences (dark mode, units)
- Application state (current page, expanded sections)

Data is never sent to external servers.

## Version

Current version: **0.83**
