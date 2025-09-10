# PurgePvP ⚔️

PurgePvP is a World of Warcraft addon designed for version 3.3.5 (Wrath of the Lich King), specifically tailored for the Project Epoch server. It prevents accidental PvP activation by blocking interactions with PvP-flagged targets, clearing PvP targets, and providing customizable warnings when you are PvP-flagged. With a user-friendly options panel and robust safety features, it ensures a seamless experience in PvP-heavy environments.

## 🚀 Features

- **🔒 Block PvP Interactions**: Prevents casting, targeting, or interacting with PvP-flagged players and pets using a 10x10-pixel block frame.
- **🧹 Auto-Clear PvP Targets**: Automatically clears PvP-flagged targets to avoid accidental engagement.
- **🚨 PvP Warnings**: Displays warnings in the `UIErrorsFrame` ("You are PvP-flagged!") with optional `RaidWarning` sound:
  - Initial warning 3 seconds after login or `/reload`.
  - 60-second interval checks (toggleable).
- **🛑 Secure PvP Deactivation**: When PvP-Flagged, automatically enables and disables PvP status when entering safe zones to avoid PvP-Deactivation Timer not getting recognised by the Server (toggleable).
- **🏰 Safe Zone & Instance Support**: Suppresses warnings and interactions in safe zones (e.g., Orgrimmar, Stormwind) and instances/battlegrounds (toggleable).
- **🛡️ Safety Features**: Disables blocking, targeting, and warnings if flagged by AoE abilities to ensure self-defense (non-toggleable).
- **🖥️ Options Panel**: Intuitive UI under Interface > AddOns > PurgePvP with toggle settings, reset button, and GitHub link.
- **⚙️ Slash Commands**: Flexible configuration via commands like `/purgepvp toggle`, `/purgepvp warning`, and more.

## 📥 Installation

1. **Download**:
   - Get the latest version from [https://github.com/ToolzGG/PurgePvP](https://github.com/ToolzGG/PurgePvP).
2. **Extract**:
   - Extract the `PurgePvP` folder to `./World of Warcraft/Interface/AddOns/`.
   - Folder structure:
     ```
     Interface/AddOns/PurgePvP/
       ├── PurgePvP.toc
       ├── PurgePvP.lua
     ```
3. **Start Game**:
   - Enable "Load out of date addons" in the addon menu (Esc > AddOns).
   - Log in and verify the chat message: "PurgePvP loaded! Use /purgepvp for options."

## ⚙️ Configuration

### Slash Commands
Access all settings via the options panel or slash commands:
- `/purgepvp` - Opens the options panel.
- `/purgepvp toggle` - Toggles the addon on/off.
- `/purgepvp sound` - Toggles sound alerts (`RaidWarning` sound).
- `/purgepvp warning` - Toggles warning messages in `UIErrorsFrame`.
- `/purgepvp safezone` - Toggles auto-disable in safe zones (e.g., Dalaran).
- `/purgepvp instances` - Toggles auto-disable in instances and battlegrounds.
- `/purgepvp securepvp`: Toggles secure PvP deactivation in safe zones.
- `/purgepvp flight` - Toggles warning suppression on flight paths.

### Options Panel 🖱️
- **Enable PurgePvP**: Toggle the addon on or off.
- **Sound Alerts**: Enable/disable `RaidWarning` sound for PvP warnings.
- **Warning Messages**: Enable/disable `UIErrorsFrame` warnings ("You are PvP-flagged!").
- **Disable in Safe Zones**: Suppress features in safe zones (e.g., Shattrath, Orgrimmar).
- **Disable in Instances/Battlegrounds**: Suppress features in dungeons, raids, or battlegrounds.
- **Secure PvP Deactivation**: Securely deactivates PvP status in safe zones (default: enabled).
- **Disable on Flight Paths**: Suppress warnings during flight paths.
- **Reset Defaults**: Reset all settings to their default values.
- **GitHub Link**: Visit the PurgePvP repository ([https://github.com/ToolzGG/PurgePvP](https://github.com/ToolzGG/PurgePvP)).

## 🔧 Requirements

- **Game Version**: World of Warcraft 3.3.5 (Wrath of the Lich King).
- **Tested on**: Project Epoch (Kezan, Gurubashi).
- **Dependencies**: None.

## 🛠️ Changelog

### Version 1.1.4 (Latest)
- Set `BLOCK_FRAME_SIZE` to 10x10 pixels for reliable click blocking.

### Previous Versions
- **1.1.3**: Code cleanup (removed comments/blank lines).
- **1.1.2**: Fixed Lua error in `resetButton` handler by storing checkbox frames directly.
- **1.1.1**: Consolidated timers with `InitializePvPChecks`, moved `InitializeBlockFrame` to `PLAYER_LOGIN`, replaced `OnUpdate` with `C_Timer.After` for `SecureDisablePvP`, removed redundant events (`ZONE_CHANGED`, `ZONE_CHANGED_INDOORS`), used table-based UI and slash command creation, increased `OnUpdate` interval to 0.2 seconds.
- **1.1.0**: Stable release with all core features, initial warning after 3 seconds, 60-second interval checks, and safety features.

## 📋 Notes

- **Performance**: Optimized for minimal CPU usage with `C_Timer` and reduced `OnUpdate` frequency (0.2 seconds).
- **Testing**: Extensively tested on Project Epoch.
- **Feedback**: Share issues or suggestions in the `#addons` Discord channel of Project Epoch or on [GitHub](https://github.com/ToolzGG/PurgePvP).
- **Future Features**:
  - Customizable warning intervals (e.g., 30/60/120 seconds).
  - Adjustable warning text, color, and sound.
  - Enhanced pet detection with `UnitCreatureType`.
  - Further event-based optimization to replace `OnUpdate`.

## 📜 License

Distributed under the MIT License. See `LICENSE` file in the repository for details.

## 👨‍💻 Author

Developed by **ToolzGG** with support from Grok 3 (xAI).

---
*PurgePvP: Keep your PvP status in check and stay safe on Epoch! 🛡️*
