#!/usr/bin/env fish

# Use a lockfile to track open/close state.
set lockfile /tmp/fuzzel-run-open
touch $lockfile

# Open the application launcher.
fuzzel --anchor=top-left --prompt="run: "

# Remove lockfile.
rm -f $lockfile
