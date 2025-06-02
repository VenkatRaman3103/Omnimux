#!/bin/bash
FILE="$HOME/.tmux-harpoon-list"
target=$(tmux display -p '#{session_name}:#{window_index}')

grep -Fxq "$target" "$FILE" 2>/dev/null || echo "$target" >> "$FILE"

