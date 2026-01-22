# Firefox On-Screen Keyboard Extension

This extension provides a minimal, Android-like on-screen keyboard for Firefox Kiosk mode.

## Features
- **3 Languages**: English (EN), Russian (RU), Kazakh (KZ).
- **Layouts**:
  - **EN/RU**: Standard 3-row letter layout + controls.
  - **KZ**: 4-row letter layout including specific Kazakh characters (Ә, І, Ң, Ғ, Ү, Ұ, Қ, Ө, Һ).
- **Functionality**:
  - **Caps Lock**: Toggleable Caps Lock key (`⇪`).
  - **Symbols**: Dedicated symbols layer (`?123`).
  - **Input**: Supports text insertion at cursor position and proper backspace handling.
- **Theme**: Modern Dark Theme (Material Design inspired).

## Installation
1. Open Firefox.
2. Go to `about:debugging`.
3. Click **This Firefox**.
4. Click **Load Temporary Add-on...**.
5. Select the `manifest.json` file in `/home/amir1330/projects/sway-kiosk/extensions/firefox-osk/`.

## Directory Structure
- `manifest.json`: FF-compatible Manifest V3.
- `src/content.js`: Main logic for keyboard injection and handling.
- `src/background.js`: Background script.
- `styles/keyboard.css`: Stylesheet for the keyboard.

## Layout Details
The Kazakh layout includes a top row with the 9 specific characters to ensure easy access without long-press menus, suitable for Kiosk environments.
