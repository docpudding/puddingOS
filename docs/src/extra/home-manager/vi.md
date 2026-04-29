This module provides a complete Neovim setup configured via Nixvim that includes LSPs for several languages, clipboard integration, autoformatting on save, and several plugins. There are a few opinionated defaults which can be overridden if desired, such as 4-space tab width and autoformat on save.

Once installed, it can be used by running either `vi`, `vim`, or `nvim`. An additional alias, `svi` which allows editing with root permissions while still maintaining the userspace Neovim configurations.

### Overridden Keybinds

The following keybinds have been changed from their Neovim defaults:

| Key     | New Action              | Old Action       |
| ------- | ----------------------- | ---------------- |
| `?`     | Live grep (git-aware).  | Backward search. |
| `` ` `` | List open buffers.      | Jump to mark.    |
| `~`     | Find files (git-aware). | Toggle case.     |

Note that the backward search functionality is still available by using `N` instead of `n` after a normal search. I will probably rebind the case toggle functionality to something else in the future in order to preserve its functionality.

I personally don't use the mark system at all, so I'm considering it free real estate for keybind overrides. If you like using marks, I would recommend either creating new keybinds for the mark system, overriding the puddingOS keybinds that shadow the mark system, or simply not using this module.
