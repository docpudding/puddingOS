#!/usr/bin/env fish

set lockfile /tmp/fuzzel-exit-open

# I have no idea why sending the icon data is necessary but it stops working if I get rid of it...
set icon ""

function send_state
    if test -f $lockfile
        echo "{\"class\": \"active\", \"icon\": \"$icon\"}"
    else
        echo "{\"class\": \"\", \"icon\": \"$icon\"}"
    end
end

# Send the initial state
send_state

# Use inotifywait to watch the lockfile directory
while true
    inotifywait --quiet --event create,delete (dirname $lockfile) | read --local event
    send_state
end
