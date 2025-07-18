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

find_tmuxifier() {
    local tmuxifier_paths=(
        "$HOME/.tmuxifier"
        "$HOME/.local/share/tmuxifier"
        "/usr/local/share/tmuxifier"
    )

    for path in "${tmuxifier_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

load_tmuxifier_session() {
    local session=$1
    local tmuxifier_dir=$(find_tmuxifier)

    if [ -z "$tmuxifier_dir" ]; then
        echo "Tmuxifier installation not found"
        return 1
    fi

    local layouts_dir="${TMUXIFIER_LAYOUT_PATH:-$tmuxifier_dir/layouts}"
    local session_file="$layouts_dir/$session.session.sh"

    if [ ! -f "$session_file" ]; then
        echo "Session file not found: $session_file"
        return 1
    fi

    # Kill existing session if it exists
    if tmux has-session -t "$session" 2>/dev/null; then
        echo "Killing existing session: $session"
        current_session=$(tmux display-message -p '#S' 2>/dev/null)
        
        # If we're in the session we want to reload, switch away first
        if [ "$current_session" = "$session" ]; then
            tmux new-session -d -s "temp_reload_$$"
            tmux switch-client -t "temp_reload_$$"
        fi
        
        tmux kill-session -t "$session"
        sleep 0.5
    fi

    # Create a temporary script that properly loads tmuxifier
    local temp_script=$(mktemp -t "tmuxifier_load_XXXXXX.sh")

    cat > "$temp_script" << 'SCRIPT_EOF'
#!/bin/bash

cleanup() {
    local script_path="$0"
    (sleep 2 && rm -f "$script_path") &
}
trap cleanup EXIT

export TMUXIFIER="%TMUXIFIER_DIR%"
export PATH="$TMUXIFIER/bin:$PATH"
export TMUXIFIER_LAYOUT_PATH="%LAYOUTS_DIR%"

if [ -f "$TMUXIFIER/init.sh" ]; then
    source "$TMUXIFIER/init.sh"
fi

if command -v tmuxifier >/dev/null 2>&1; then
    tmuxifier load-session "%SESSION_NAME%"
else
    # Fallback: source the session file directly
    if [ -f "%SESSION_FILE%" ]; then
        source "%SESSION_FILE%"
    else
        echo "Error: Session file not found: %SESSION_FILE%"
        exit 1
    fi
fi
SCRIPT_EOF

    # Replace placeholders
    sed -i "s|%TMUXIFIER_DIR%|$tmuxifier_dir|g" "$temp_script"
    sed -i "s|%LAYOUTS_DIR%|$layouts_dir|g" "$temp_script"
    sed -i "s|%SESSION_NAME%|$session|g" "$temp_script"
    sed -i "s|%SESSION_FILE%|$session_file|g" "$temp_script"

    chmod +x "$temp_script"
    
    # Execute the script and switch to the session
    tmux detach-client -E "exec '$temp_script'"
    
    # Clean up temp session if we created one
    if [ "$current_session" = "$session" ]; then
        tmux kill-session -t "temp_reload_$$" 2>/dev/null &
    fi
}

# Main script
layouts_dir=$(find_layouts_dir)
if [ -z "$layouts_dir" ]; then
    echo "tmuxifier layouts directory not found"
    exit 1
fi

sessions=$(find "$layouts_dir" -name "*.session.sh" -exec basename {} \; | sed 's/\.session\.sh$//' | sort)
selected=$(echo "$sessions" | fzf --no-reverse --header="Tmuxifier Sessions (Enter: load, Esc: cancel)")

if [ -n "$selected" ]; then
    load_tmuxifier_session "$selected"
fi
