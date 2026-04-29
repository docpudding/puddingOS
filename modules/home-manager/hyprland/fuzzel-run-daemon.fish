#!/usr/bin/env fish

while true
    if test -f /tmp/fuzzel-run-open
        echo '{"class": "active"}'
    else
        echo '{}'
    end

    inotifywait -q -e create -e delete -e modify /tmp 2>/dev/null
end
