This module provides a performance profiler via MangoHud. Besides theming/layout changes, the main functional change from default MangoHud is that the mode-cycle keybind has been replaced with a single on-ff toggle via F3, which is meant to reflect the bindings of the Minecraft debug menu which serves a similar purposes.

This module will enable MangoHud **session-wide** for all applications that support it, but it will be hidden by default until toggled with F3. Unfortunately, the global auto-enable doesn't seem to work reliably with the Gamescope session created by the Steam module. I'd like to fix this eventually considering it's one of the main use cases for MangoHud, but for now you can still use MangoHud in the Gamescope session by setting it in the launch options on Steam:

```sh
mangohud %command%
```
