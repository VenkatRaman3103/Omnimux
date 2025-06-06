#!/bin/bash

TEMP_FILE="/tmp/tmux_windows_$$"
ORIGINAL_FILE="/tmp/tmux_windows_original_$$"

get_windows() {
    tmux list-windows -F "#{window_index}:#{window_name}" | sort -n > "$TEMP_FILE"
    cp "$TEMP_FILE" "$ORIGINAL_FILE"
}

apply_window_order() {
    local new_index=0
    local -A original_windows
    local -A processed_windows
    local -a window_order
    
    while IFS=':' read -r old_index window_name; do
        original_windows["$old_index"]="$window_name"
    done < "$ORIGINAL_FILE"
    
    while IFS=':' read -r index window_name; do
        if [[ "$index" =~ ^[0-9]+$ ]]; then
            processed_windows["$index"]=1
            window_order+=("$window_name")
            
            if [[ -z "${original_windows[$index]}" ]]; then
                echo "Creating new window $index with name: $window_name"
                tmux new-window -t "$index" -n "$window_name" 2>/dev/null || {
                    tmux new-window -n "$window_name"
                    echo "Created new window with name: $window_name (index auto-assigned)"
                }
            else
                if [[ "${original_windows[$index]}" != "$window_name" ]]; then
                    echo "Renaming window $index from '${original_windows[$index]}' to '$window_name'"
                    tmux rename-window -t "$index" "$window_name" 2>/dev/null || true
                fi
            fi
        fi
    done < "$TEMP_FILE"
    
    local target_index=0
    for window_name in "${window_order[@]}"; do
        local current_index=$(tmux list-windows -F "#{window_index}:#{window_name}" | grep ":${window_name}$" | cut -d: -f1 | head -1)
        if [ -n "$current_index" ] && [ "$current_index" != "$target_index" ]; then
            tmux move-window -s "$current_index" -t "$target_index" 2>/dev/null || true
        fi
        ((target_index++))
    done
    
    tmux move-window -r
}

show_help() {
    cat << 'EOF'
# ╭─────────────────────────────────────────────────────────────────────────────╮
# │                           Omnimux: Mange Windows                            │
# ╰─────────────────────────────────────────────────────────────────────────────╯
# ┌─ USAGE ─────────────────────────────────────────────────────────────────────┐
# │ • CREATE new window:    Add line "99:windowName"                            │
# │ • RENAME window 2:      Change "2:oldName" to "2:newName"                   │
# │ • REORDER windows:      Move lines up/down with dd and p                    │
# │ • DELETE window:        Delete the line (⚠️  KILLS THE WINDOW!)              │
# └─────────────────────────────────────────────────────────────────────────────┘
EOF
}

handle_deletions() {
    local current_window=""
    if [ -n "$TMUX" ]; then
        current_window=$(tmux display-message -p '#I')
    fi
    
    while IFS=':' read -r old_index window_name; do
        if ! grep -q "^$old_index:" "$TEMP_FILE"; then
            if [[ "$old_index" == "$current_window" ]]; then
                echo "WARNING: Cannot kill current window '$old_index' - skipping"
            else
                echo "Killing window: $old_index ($window_name)"
                tmux kill-window -t "$old_index" 2>/dev/null || true
            fi
        fi
    done < "$ORIGINAL_FILE"
}

manage_windows() {
    if [ -z "$TMUX" ]; then
        echo "Error: Not in a tmux session"
        exit 1
    fi
    
    local original_window=""
    if [ -n "$TMUX" ]; then
        original_window=$(tmux display-message -p '#I')
    fi
    
    get_windows
    
    if [ ! -s "$TEMP_FILE" ]; then
        echo "No tmux windows found."
        echo "Would you like to create a new window? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy] ]]; then
            echo "0:default" > "$TEMP_FILE"
        else
            exit 0
        fi
    fi
    
    {
        cat "$TEMP_FILE"
        # echo ""
        # show_help
    } > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    
    nvim \
        -c "set laststatus=0 noshowcmd noshowmode noruler signcolumn=no foldcolumn=0 nocursorline nocursorcolumn" \
        -c "syntax off | hi Comment ctermfg=darkgray | hi Special ctermfg=yellow" \
        -c "match Comment /^#.*/ | 2match Special /\*/" \
        "$TEMP_FILE"
    
    if ! diff -q "$TEMP_FILE" "$ORIGINAL_FILE" >/dev/null 2>&1; then
        grep -v '^#' "$TEMP_FILE" | grep -v '^$' > "${TEMP_FILE}.clean"
        mv "${TEMP_FILE}.clean" "$TEMP_FILE"
        
        handle_deletions
        
        apply_window_order
        
        echo "Windows updated successfully!"
        
        echo ""
        echo "Current windows:"
        tmux list-windows 2>/dev/null || echo "No windows running"
    else
        echo "No changes made."
    fi
    
    if [ -n "$original_window" ]; then
        tmux select-window -t "$original_window" 2>/dev/null || true
    fi
    
    rm -f "$TEMP_FILE" "$ORIGINAL_FILE" "${TEMP_FILE}.clean"
}

show_usage() {
    cat << 'EOF'
Usage: tmux-window-manager.sh [OPTION]

Options:
  -h, --help       Show this help message

Description:
  Interactive tmux window manager with vim-style editing.
  Allows you to reorder, rename, delete, and create windows using neovim.
  
Features:
  - Reorder windows by moving lines
  - Rename windows by editing the name part
  - Delete windows by removing lines (be careful!)
  - Create new windows by adding new lines with format INDEX:NAME

Tmux keybinding (add to your tmux.conf):
  bind-key W run-shell 'tmux-window-manager.sh'

Examples:
  ./tmux-window-manager.sh

EOF
}

case "${1:-}" in
    -h|--help)
        show_usage
        ;;
    *)
        manage_windows
        ;;
esac
