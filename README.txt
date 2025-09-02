# PurgePvP

PurgePvP is a World of Warcraft addon designed for version 3.3.5 that blocks interactions with PvP-flagged targets,
clears PvP targets, and provides warnings when you are PvP-flagged. It includes toggle options and safety features.

## Features
- Blocks interactions (e.g., casting, targeting) with PvP-flagged players.
- Automatically clears PvP targets.
- Warns with combat text and sound when PvP-flagged.
- Auto-disable of PvP status.
- Safe zone and Instance/Battleground disable options.
- 60-second PvP status check.
- Safety features include disabling of blocking, targeting and interaction-warning,
  to ensure you can defend yourself if you should get flagged by your AoE-Abilities. This can't be turned off!
- UI options panel with toggle settings, reset button, and GitHub link.

## Installation

1. **Download**: Get the latest version from (https://github.com/ToolzGG/PurgePvP).
2. **Extract**:
   - Extract the PurgePvP folder to ./World of Warcraft/Interface/AddOns/.
   - Folder structure:
     ```
     Interface/AddOns/PurgePvP/
       ├── PurgePvP.toc
       ├── PurgePvP.lua
     ```
3. **Start Game**:
   - Enable "Load out of date addons" in the addon menu.
   - Log in and verify the chat message: "PurgePvP loaded! Use /purgepvp for options."

## Configuration
- Open the options panel with /purgepvp or via the Interface menu (Esc > Interface > AddOns > PurgePvP).
- Available commands:
  - /purgepvp - Open the options panel.
  - /purgepvp toggle - Toggle addon on/off.
  - /purgepvp sound - Toggle sound alerts.
  - /purgepvp warning - Toggle warning messages.
  - /purgepvp safezone - Toggle auto-disable in safe zones.
  - /purgepvp leavesafe - Toggle warning when leaving safe zones.
  - /purgepvp leavesafemessages - Toggle messages when leaving safe zones.
  - /purgepvp interval - Toggle 60-second PvP status check.
  - /purgepvp autopvp - Toggle auto PvP status disable.
  - /purgepvp autopvpmessages - Toggle auto PvP disable messages.
  - /purgepvp instances - Toggle auto-disable in instances/Battlegrounds.

## Options Panel
- Enable PurgePvP: Toggle the addon on or off.
- Sound Alerts: Enable or disable sound warnings.
- Warning Messages: Enable or disable combat text and UI warnings.
- Disable in Safe Zones: Disable features in safe zones (e.g., Dalaran).
- Warn on Leaving Safe Zones: Enable leave safe zone checks.
- Leave Safe Zone Messages: Enable messages when leaving a safe zone while PvP-flagged.
- 60-Second PvP Check: Enable 60-second PvP status checks.
- Auto PvP Disable: Automatically disable PvP status when flagged.
- Auto PvP Disable Messages: Enable messages for auto PvP disable.
- Disable in Instances/Battlegrounds: Disable features in instances and Battlegrounds.
- Reset Defaults: Reset all settings to default values.
- GitHub: Click to visit the PurgePvP GitHub repository (https://github.com/ToolzGG/PurgePvP).

## Requirements

- Game Version: World of Warcraft 3.3.5 (Project Epoch).
- Tested on: Project Epoch (Kezan, Gurubashi).
- Dependencies: None.

## Additional Notes:

   - Im not a programmer, this Addon was created using AI-Assistance. Error-Detection might take some time. 

## License

This addon is licensed under the MIT License. See the LICENSE file for details.
