#!/bin/bash
FILE="$HOME/.tmux-bookmars-list"
target=$(tmux display -p '#{session_name}:#{window_index}')

grep -Fxq "$target" "$FILE" 2>/dev/null || echo "$target" >> "$FILE"

tmux display-message "Session: #S, Window: #W, Pane: #P is added to the list"
