# 🌦 Product Requirements Document (PRD) – Feature: Weather

**Feature Name**: Weather  
**App**: Bergen!  
**Version**: v1.0  
**Status**: MVP  
**Tab**: Mer  
**Owner**: Kerta

---

## 🎯 Objective

Provide a humorous fullscreen experience that answers the timeless Bergen question:  
**"Regnar det i dag?"**  
Based on real statistical likelihood: 265 rainy days per year (≈ 72.6%).

---

## 🧠 Logic

Use a math-based probability to simulate real Bergen weather stats:

```swift
let rainy = Double.random(in: 0...1) < 0.726
```

No API or network required in v1.  
Later, swap in a real weather provider using `RainCheckProvider`.

---

## 🖼 UI Behavior

### If `rainy == true`
- Fullscreen umbrella icon ☔️
- (Optional) animated falling rain
- Text:  
  **"Ja, det regnar. Alt er som vanleg."**

---

### If `rainy == false`
- Fullscreen sun icon ☀️
- (Optional) sun rays or confetti
- Text:  
  **"NEI! Sola skin i Bergen!"**

#### Additional Share Buttons:
- **[☀️ Del med alle Østlendingar]**  
  > *"Sola skin i Bergen i dag. Tenk på det, du!"*

- **[🔥 Post på X]**  
  > *"Østlendingar brif med sol – men vi har sol vi òg! #BergenSkins"*

---

## 🔩 Implementation Notes

- View: `WeatherView.swift`
- Provider: `RainCheckProvider` protocol
  - Default: `BergenRainStatsProvider`
- Optional animation:
  - Lottie, Canvas, or GIF/looping `Image`
- Share:
  - Use `ShareLink` (iOS 16+) or `UIActivityViewController`

---

## 📦 Assets

| Asset                 | Required | Notes                     |
|----------------------|----------|---------------------------|
| Umbrella Icon        | ✅       | SF Symbol or PNG          |
| Sun Icon             | ✅       | SF Symbol or PNG          |
| Rain Animation       | Optional | Lottie or particle effect |
| Share Text Strings   | ✅       | Localized / randomizable  |

---

## 📍 Navigation & Placement

- Listed in **Mer** tab as: `Weather`
- Can be promoted to main tab in future versions

---

## ✅ MVP Acceptance Criteria

- Opens fullscreen
- Always shows **either** rain or sun based on logic
- Accurate probability (~72.6%)
- Share buttons appear only when it's sunny
- No crashes, no permissions required

---