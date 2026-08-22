{lib, ...}: {
    wayland.windowManager.hyprland.settings = {
        bind = [
            # Terminal emulator shortcut.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + T"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("alacritty")'')
                ];
            }

            # File explorer shortcut.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + E"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd('alacritty -e fish -c "rcd; exec fish"')'')
                ];
            }

            # Browser shortcut.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + B"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("qutebrowser")'')
                ];
            }

            # Application launcher shortcut.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + Z"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${./fuzzel-run.fish}")'')
                ];
            }

            # Session management shortcut.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + Q"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${./fuzzel-exit.fish}")'')
                ];
            }

            # Session locker shortcut.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + L"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprlock")'')
                ];
            }

            # Screenshot shortcut.
            {
                _args = [
                    "Print"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot --mode region --output-folder $HOME/stuff/screenshots")'')
                ];
            }

            # Manage windows.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + W"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.close()'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + X"'')
                    (lib.generators.mkLuaInline ''hl.dsp.layout("togglesplit")'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + C"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.pseudo()'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + V"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
                ];
            }

            # Select active window.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + left"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "left" })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + right"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "right" })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + up"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "up" })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + down"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "down" })'')
                ];
            }

            # Move active window.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + left"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "left" })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + right"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "right" })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + up"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "up" })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + down"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "down" })'')
                ];
            }

            # Resize active window.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + ALT + left"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = -64, y = 0, relative = true })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + ALT + right"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 64, y = 0, relative = true })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + ALT + up"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 0, y = -64, relative = true })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + ALT + down"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 0, y = 64, relative = true })'')
                ];
            }

            # Swap workspaces.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 1"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 1 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 2"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 2 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 3"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 3 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 4"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 4 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 5"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 5 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 6"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 6 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 7"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 7 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 8"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 8 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 9"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 9 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + 0"'')
                    (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = 10 })'')
                ];
            }

            # Move windows between workspaces.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 1"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 1 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 2"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 2 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 3"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 3 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 4"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 4 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 5"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 5 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 6"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 6 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 7"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 7 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 8"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 8 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 9"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 9 })'')
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + 0"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = 10 })'')
                ];
            }

            # Move/resize windows using the mouse.
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + mouse:272"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.drag()'')
                    {mouse = true;}
                ];
            }
            {
                _args = [
                    (lib.generators.mkLuaInline ''mod .. " + mouse:273"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.resize()'')
                    {mouse = true;}
                ];
            }

            # Media and brightness keys.
            {
                _args = [
                    "XF86AudioRaiseVolume"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86AudioLowerVolume"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86AudioMute"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86AudioPlay"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86AudioNext"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86AudioPrev"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86MonBrightnessUp"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 10%+")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
            {
                _args = [
                    "XF86MonBrightnessDown"
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 10%-")'')
                    {
                        locked = true;
                        repeating = true;
                    }
                ];
            }
        ];
    };
}
