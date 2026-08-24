#!/usr/bin/env fish

set lockfile /tmp/fuzzel-exit-open
function send_state
    if test -f $lockfile
        echo "{\"class\": \"active\"}"
    else
        echo "{\"class\": \"\"}"
    end
end

# Send the initial state
send_state

# Use inotifywait to watch the lockfile directory
while true
    inotifywait --quiet --event create,delete (dirname $lockfile) | read --local event
    send_state
end
