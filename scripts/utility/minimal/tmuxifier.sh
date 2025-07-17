#!/bin/bash

find_layouts_dir() {
    local tmuxifier_paths=(
        "$HOME/.tmuxifier/layouts"
        "$HOME/.local/share/tmuxifier/layouts"
        "/usr/local/share/tmuxifier/layouts"
        "${TMUXIFIER_LAYOUT_PATH}"
    )
    
    for path in "${tmuxifier_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

layouts_dir=$(find_layouts_dir)
if [ -z "$layouts_dir" ]; then
    echo "tmuxifier layouts directory not found"
    exit 1
fi

sessions=$(find "$layouts_dir" -name "*.session.sh" -exec basename {} \; | sed 's/\.session\.sh$//' | sort)
selected=$(echo "$sessions" | fzf --no-reverse --header="Tmuxifier Sessions (Enter: load, Esc: cancel)")

if [ -n "$selected" ]; then
    if tmux has-session -t "$selected" 2>/dev/null; then
        # Session already exists, just switch to it
        tmux switch-client -t "$selected"
    else
        # Create new session in detached mode first, then switch
        tmuxifier load-session "$selected" --detached
        tmux switch-client -t "$selected"
    fi
fi
