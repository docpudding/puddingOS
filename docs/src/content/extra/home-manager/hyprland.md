This module provides a complete desktop environment built on top of Hyprland and Waybar. It requires the corresponding NixOS module to be enabled as well for this module to have any effect. It provides several features out of the box, including but not limited to:

- Tiling window manager (Hyprland)
- Status bar (Waybar)
- Application launcher (fuzzel)
- Notification system (dunst)

This module is **significantly more opinionated than most of the other modules** due to it being my main desktop setup. If you intend on using this module, I would recommend reading over the keybinds in the [Nix module configuration](https://github.com/docpudding/puddingOS/blob/release-25.11/modules/home-manager/hyprland/default.nix) and overriding as needed.
