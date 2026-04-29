This module aims to improve the main shell experience in several different ways. It is built around the Fish shell and includes several other tools and CLI utilities as well as a graphical terminal emulator (Alacritty).

### Utilities

| Tool     | Replaces      | Description                                    | Usage                     |
| -------- | ------------- | ---------------------------------------------- | ------------------------- |
| `lsd`    | `ls`          | Improved file listing with NerdFont icons.     | `ls`                      |
| `bat`    | `cat`         | Improved file viewer with syntax highlighting. | `bat` or `cat` (no pager) |
| `bottom` | `top`         | Improved system monitor                        | `btm`                     |
| `atuin`  | shell history | Improved command history system.               | press up arrow in shell   |
| `pass`   | —             | Password manager.                              | `pass`                    |
| `rng`    | —             | Quick randomizer created for puddingOS.        | `rng --help`              |

### Aliases

| Alias  | Command                | Description                                   |
| ------ | ---------------------- | --------------------------------------------- |
| `cat`  | `bat -pp`              | Print file in plain output mode (no pager).   |
| `dupe` | `alacritty & disown`   | Open a new terminal in the current directory. |
| `nsh`  | `nix-shell --run fish` | Open a `nix-shell` enivormnent with Fish.     |

### Submodules

The shell module has two submodules, which are disabled by default but can be enabled independently of one another.

#### clipboard

This submodule provides a unified system for clipboard management on multiple different environment types. In addition to tracking clipboard history with cliphist, it also provides a new utility, `copy`, which can be used to place data on your clipboard from either a CLI argument or piped input, choosing either `wl-copy` or `xclip` as the backend depending on what kind of session you are using. It also supports copying over SSH sessions. In addition to the base `copy` utility, the clipboard module also provides the `copycat` command, which can be used to place the content of a file on your clipboard:

```sh
copy bruh moment # Places "bruh moment" onto your clipboard.
ls | copy # Places the output of ls onto your clipboard.

copy test.txt # Places the full absolute path of ./test.txt onto your clipboard.
cat test.txt | copy # Places the content of test.txt onto your clipboard
copycat test.txt # Equivalent to above.
```

#### rgr (ranger)

This submodule installs and configures the ranger file explorer and provides some utilities to make working with it easier. It provides two commands: `rgr`, which is a direct alias for launching ranger normally, and `rcd`, which is a custom shell function that allows you to use ranger to change the active shell's working directory.

If you close a ranger session that was started with `rcd`, it will send you back to the shell and then automatically `cd` into wherever you left off in ranger. On the other hand, closing a ranger session that was started with `rgr` will ignore your current location in ranger and simply send you back to wherever you were before starting the ranger session.
