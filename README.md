# Joe Multiboxer: Basic Core Agents

# Installation
1. **Download** the latest Basic Core Agents: [https://github.com/LavishSoftware/JMB-Basic-Core-Agents/archive/master.zip](https://github.com/LavishSoftware/JMB-Basic-Core-Agents/archive/master.zip)
2. **Extract** the folders from the ZIP into your `Joe Multiboxer\Agents` folder
   * You can choose not to install any of the Agents that you do not want to use.

![Some installed Basic Core Agents](https://cdn.discordapp.com/attachments/780248201638838302/780847652396990474/unknown.png)

# Overview

* `Basic Launcher`: Simple. Tell it how many of which game to launch, and click Launch
* `Basic Window Layout`: **Now with configuration!** Automatically provides the basic, iconic Window Layout (small windows at bottom).
  * Toggle Swap on Activate: `Shift+Ctrl+Alt+A`
  * Toggle Focus Follows Mouse: `Shift+Ctrl+Alt+M`
  * Make current window fullscreen: `Shift+Ctrl+Alt+F`
  * Apply Window Layout from current window: `Shift+Ctrl+Alt+W`
  * Next Window: `Shift+Ctrl+Alt+X`
  * Previous Window: `Shift+Ctrl+Alt+Z`
  * Configure in the file `Joe Multiboxer\Agents\Basic Window Layout\bwl.Settings.json`
* `Basic Global Hotkeys`: Configurable **global hotkeys for window switching** -- one for each window, defaulting to `Ctrl+Alt+1` through `Ctrl+Alt+=`.
  * Previous Window: `Ctrl+Alt+X`
  * Next Window: `Ctrl+Alt+Z`
  * Configure in the file `Joe Multiboxer\Agents\Basic Global Hotkeys\bgh.Settings.json`
  * **Note:** if you use an `Alt Gr` key for typing, the default settings for Basic Global Hotkeys may interfere with your typing `@` and other characters; you may want to change it to `Shift+Alt+1`, etc. Or, just not use this agent :)
* `Basic Round-Robin`: When Round-Robin mode is enabled, the **next window will be activated after the you press and release a key in the game**.
  * Toggle Round-Robin mode: `F12`
* `Basic Performance`: Currently no configuration. Applies 60fps foreground, 30fps background, and "all windows use all cores" CPU strategy.
* `Basic Highlighter`: Highlights the focused window, and places Slot numbers in the corner of non-focused windows
