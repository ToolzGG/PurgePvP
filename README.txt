# PurgePvP

PurgePvP is a World of Warcraft addon for patch 3.3.5 (Project Epoch) designed to help PvE players avoid accidental interactions with PvP-flagged players.
It blocks clicks and tooltips on PvP targets, automatically clears PvP targets, displays warnings, and supports safezones.
The playercharacter and playerframe are excluded from all restrictions, ensuring self-targeted spells always work.

## Features

- **PvP Target Blocking**:
  - Prevents interactions with PvP-flagged players using an invisible Blockframe (50x50 pixels) at the cursor.
  - Changes the cursor to "UnableCrosshair.blp" on mouseover or targeting of PvP players.
  - Suppresses tooltips for PvP targets.
  - Floating Combat Text messages "FCT" (toggleable):
    - "PvP Target detected! Target cleared!" (on targeting).
    - "PvP Target detected! Interaction blocked!" (on mouseover).
    - "Click on PvP-flagged target blocked!" (on left-click).
  - UI Text: "PvP Target!" (5 seconds) on interaction with PvP targets.

- **Automatic Clear-Target**:
  - Instantly clears the selection of PvP-flagged players.

- **Player Exclusion**:
  - The playercharacter and playerframe are exempt from all restrictions:
    - No warnings, no cleartarget, no Blockframe, no cursor change, normal tooltips.
    - Allows casting spells on self, even when PvP-flagged.

- **PvP Status Warnings**:
  - FCT message: "You are PvP-flagged! Avoid combat for 15 minutes!" when PvP flag is activated.
  - UI Text: "YOU ARE PVP FLAGGED! AVOID CASTING!" (10 seconds).
  - Sound: "Raid Warning" (toggleable).

- **Safe Zone Logic**:
  - Addon automatically disables in safe zones (e.g., Orgrimmar, Stormwind) if enabled
  - Warning when leaving a safe zone while PvP-flagged:
    - FCT: "Warning: You are PvP-flagged and left a safe zone!".
    - Sound: "RaidWarning".

- **Options**:
  - /purgepvp: list all options in general chat.
  - /purgepvp toggle: Enable/disable the addon.
  - /purgepvp sound: Toggle sound alerts.
  - /purgepvp warning: Toggle FCT warnings.
  - /purgepvp safezone: Toggle auto-disable in safe zones.
  - /purgepvp leavesafe: Toggle warning when leaving safe zones.

## Requirements

- **Game Version**: World of Warcraft 3.3.5 (Project Epoch).
- **Tested on**: Project Epoch (Kezan, Gurubashi).
- **Dependencies**: None.

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
   
4. **Additional Notes**:

   - Im not a programmer, this Addon was created using AI-Assistance. Error-Detection might take some time. 

## License

This addon is licensed under the MIT License. See the LICENSE file for details.
