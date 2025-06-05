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
    
    while IFS=':' read -r old_index window_name; do
        original_windows["$old_index"]="$window_name"
    done < "$ORIGINAL_FILE"
    
    while IFS=':' read -r index window_name; do
        if [[ "$index" =~ ^[0-9]+$ ]]; then
            processed_windows["$index"]=1
            
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
                
                tmux move-window -s "$index" -t "$new_index" 2>/dev/null || true
            fi
            ((new_index++))
        fi
    done < "$TEMP_FILE"
    
    tmux move-window -r
}

show_help() {
    cat << 'EOF'
# Tmux Window Manager
# 
# Examples:
# - To create new window: Add line "99:windowName" 
# - To rename window 2: Change "2:oldName" to "2:newName"
# - To reorder: Move lines up/down with dd and p
EOF
}

handle_deletions() {
    while IFS=':' read -r old_index window_name; do
        if ! grep -q "^$old_index:" "$TEMP_FILE"; then
            tmux kill-window -t "$old_index" 2>/dev/null || true
        fi
    done < "$ORIGINAL_FILE"
}

manage_windows() {
    if [ -z "$TMUX" ]; then
        echo "Error: Not in a tmux session"
        exit 1
    fi
    
    get_windows
    
    {
        show_help
        echo ""
        cat "$TEMP_FILE"
    } > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    
    nvim \
        -c "set number" \
        -c "set cursorline" \
        -c "syntax off" \
        -c "hi Comment ctermfg=darkgray" \
        -c "match Comment /^#.*/" \
        -c "normal G" \
        "$TEMP_FILE"
    
    if ! diff -q "$TEMP_FILE" "$ORIGINAL_FILE" >/dev/null 2>&1; then
        grep -v '^#' "$TEMP_FILE" | grep -v '^$' > "${TEMP_FILE}.clean"
        mv "${TEMP_FILE}.clean" "$TEMP_FILE"
        
        handle_deletions
        
        apply_window_order
        echo "Windows updated successfully!"
    else
        echo "No changes made."
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
  - Delete windows by removing lines  
  - Create new windows by adding new lines with format INDEX:NAME

Tmux keybinding (add to your tmux.conf):
  bind-key W run-shell 'tmux-window-manager.sh'

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
