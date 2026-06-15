This module provides a complete out-of-the-box gaming environment for NixOS. In addition to installing the Steam client, enabling this module will cause several other things to happen. For starters, there are some miscellaneous configurations designed to improve the gaming experience on NixOS, such as opening ports for remote play and local network transfers as well as installing drivers and kernel modules for various controller types.

## Console Mode

When this module is enabled, it will give you access to a new command, `startgs`, which can be used in a TTY to start the Gamescope Compositor as a standalone X11 session. At first glance, this is a bit like running Big Picture Mode as a minimal desktop environment. In addition to providing a console-like interface, it also enables certain extended features that are normally only possible on Windows, such as HDR support for Steam games running through Proton.

As a general tip, `startgs` is fully compatible with the core module's session management system, which can be used to automatically boot to Console Mode on startup. It also allows you to run the Gamescope session alongside a different type of session running on a different TTY. For example:

```nix
pos.sessions = {
    autologinUser = "gamerman";
    autostart.tty1 = "startgs";
    autostart.tty2 = "hyprland";
};
```

The above configuration would create a hybrid system which simultaneously runs a Console Mode session and a Desktop Mode session which can be toggled by switching between TTYs. In fact, this specific behaviour was the original reason why the `pos.sessions` interface was created to begin with.

### Gamescope HDR Patch

This module also provides an overlay patch for Gamescope designed to fix a specific issue with HDR. When Gamescope is first launched on an HDR-capable display, it will enable HDR mode on the screen, which persists until it is either manually disabled or until the machine is rebooted. This isn't really an issue on devices that are used for Steam, but having HDR enabled when using other applications without HDR support (such as Kodi or Hyprland) can result in a strange-looking color display.

This patch fixes the issue by disabling HDR when a clean Gamescope exit or keyboard VT change is detected. It is **enabled by default** and shouldn't cause any issues or conflicts, but it can be disabled if desired. One limitation to this is that it ONLY detects the TTY switch if it is initiated from a keyboard input (i.e. Ctrl+Alt+F2 or any other function key). Similarly, a non-clean Gamescope exit such as a crash or SIGKILL won't trigger the fix either. These limitations are the primary reason why this fix hasn't been submitted for an upstream push despite Gamescope having a [GitHub issue](https://github.com/ValveSoftware/gamescope/issues/769) for something similar.
