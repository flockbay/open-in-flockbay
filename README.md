# Open in Flockbay

A Godot 4 editor plugin that opens the project you have open in
[Flockbay](https://flockbay.com), the free AI game maker built on the official
Godot engine.

Flockbay's AI builds and play-tests a whole Godot game: it writes the GDScript
and the scenes, builds the world with tools for terrain, water, sky, weather,
the player controller and props, runs the game, sends it input events, reads
the debugger and captures the viewport to check its work. It runs on free
hosted AI every day, or on your own Claude or ChatGPT, and your own agent
(Claude Code, Codex, Cursor) can work on the same game over MCP. The project
stays a normal Godot project on your disk.

## Use

1. Install the plugin: from the Asset Library, or copy `addons/flockbay` into
   your project.
2. Enable it in **Project > Project Settings > Plugins**.
3. Choose **Project > Tools > Open this project in Flockbay**.

Flockbay adds the project and opens it. It asks once before it adds anything
of its own to the project, and lists what it added.

If Flockbay is not installed, the menu item offers the free download
(Windows, macOS and Linux). If it is installed somewhere unusual, set
**Editor Settings > Flockbay > App Path** to the app (on Windows
`flockbay-desktop.exe`, on macOS `Flockbay.app`, on Linux the `.AppImage`).

Godot 4.2 or later. MIT licensed.
