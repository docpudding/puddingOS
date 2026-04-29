#!/usr/bin/env fish
set lockfile /tmp/fuzzel-exit-open

# Use a lockfile to track open/close state.
touch $lockfile
set options " Lock\n Logout\n Reboot\n Shutdown"
set choice (
    printf $options | fuzzel --dmenu \
        --prompt="exit: " \
        --anchor="top-right" \
        --width=12 \
        --lines=4 \
        --border-color="#ed8796ff" \
        --prompt-color="#ed8796ff" \
)
        #--selection-color="#ed8796ff"
rm -f $lockfile

# Match the choice to the command.
switch $choice
    case " Lock"
        hyprlock
    case " Logout"
        hyprctl dispatch exit
    case " Reboot"
        systemctl reboot
    case " Shutdown"
        systemctl poweroff
end
