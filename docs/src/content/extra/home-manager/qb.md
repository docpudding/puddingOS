This module provides a minimal configuration for qutebrowser with a few quality of life changes. It also changes the downloads directory from `~/Downloads` to `~/stuff/downloads` which is based on how my personal file system is set up. If you don't like it you can override it fairly easily.

## Keybinds

| Key      | New Action       |
| -------- | ---------------- |
| `u`      | Browser back     |
| `Ctrl+r` | Browser forward  |
| `Ctrl+o` | Private tab open |

The forward/back keybind changes are meant to reflect traditional undo/redo behaviour in Vim. You can still use the old keybinds as well (`H` and `L`). The `u` key was original bound to reopen the last closed tab. This functionality has been moved to `U`, which was previously unbound. The `Ctrl+r` key was not previously bound, so no functionality has been lost due to these keybind changes.
