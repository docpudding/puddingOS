#!/usr/bin/env fish

# Use a lockfile to track open/close state.
set lockfile /tmp/fuzzel-run-open
touch $lockfile
set cmd (fuzzel --anchor=top-left --prompt="run: ")
rm -f $lockfile

# Run selected command if non-empty.
if test -n "$cmd"
    eval $cmd
end
