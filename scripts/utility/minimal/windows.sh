#!/bin/bash

current_session=$(tmux display-message -p '#S')

windows=$(tmux list-windows -t "$current_session" -F "#I: #W")

selected=$(echo "$windows" | \
  fzf --no-reverse --header="Windows in $current_session" \
      --delimiter=': ' \
      --with-nth=1.. )

if [ -n "$selected" ]; then
  window_index=$(echo "$selected" | cut -d':' -f1 | tr -d ' ')
  tmux select-window -t "$window_index"
fi
