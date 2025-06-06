#!/bin/bash

sessions=$(tmux list-sessions -F "#S #{?session_attached,(active),}" | sort)

selected=$(echo "$sessions" | fzf --reverse --header="Sessions (Enter: select, Esc: cancel)")

if [ -n "$selected" ]; then
  session=$(echo "$selected" | awk '{print $1}')
  tmux switch-client -t "$session"
fi

