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
# 
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

mark_current_window() {
    if [ -n "$TMUX" ]; then
        local current_window=$(tmux display-message -p '#I')
        local current_window_name=$(tmux display-message -p '#W')
        echo "$current_window_name" > "/tmp/tmux_current_window_$"
        echo "Debug: Current window is '$current_window' with name '$current_window_name'" >&2
    fi
}

clean_window_names() {
    return 0
}

handle_window_switching() {
    local marked_window=""
    local original_current=""
    local window_name=""
    
    if [ -n "$TMUX" ]; then
        original_current=$(tmux display-message -p '#I')
    fi
    
    while IFS=':' read -r index window_line; do
        if [[ "$window_line" == *" *" ]]; then
            marked_window="$index"
            window_name=$(echo "$window_line" | sed 's/ \*$//')
            break
        fi
    done < "$TEMP_FILE"
    
    if [ -n "$marked_window" ] && [ -n "$TMUX" ]; then
        if [ "$marked_window" != "$original_current" ]; then
            if tmux list-windows -F "#{window_index}" | grep -q "^$marked_window$"; then
                echo "Switching to existing window: $marked_window"
                tmux select-window -t "$marked_window" 2>/dev/null || {
                    echo "Failed to switch to window: $marked_window"
                }
            else
                echo "Window $marked_window ($window_name) will be created and switched to after window operations"
                echo "$window_name" > "/tmp/tmux_switch_target_$"
            fi
        fi
    fi
}

switch_to_target_window() {
    local switch_target_file="/tmp/tmux_switch_target_$"
    
    if [ -f "$switch_target_file" ] && [ -n "$TMUX" ]; then
        local target_window_name=$(cat "$switch_target_file")
        
        sleep 0.2
        
        local actual_index=""
        local line_number=0
        
        while IFS=':' read -r index name_part; do
            if [[ "$name_part" == "$target_window_name" ]]; then
                actual_index="$line_number"
                break
            fi
            ((line_number++))
        done < "$TEMP_FILE"
        
        if [ -n "$actual_index" ]; then
            echo "Switching to window at position: $actual_index (name: $target_window_name)"
            tmux select-window -t "$actual_index" 2>/dev/null || {
                local window_index=$(tmux list-windows -F "#{window_index}:#{window_name}" | grep ":$target_window_name$" | cut -d: -f1 | head -1)
                if [ -n "$window_index" ]; then
                    echo "Fallback: switching to window index: $window_index"
                    tmux select-window -t "$window_index" 2>/dev/null
                else
                    echo "Failed to switch to window: $target_window_name"
                fi
            }
        else
            echo "Could not determine target window position for: $target_window_name"
        fi
        
        rm -f "$switch_target_file"
    fi
}

manage_windows() {
    if [ -z "$TMUX" ]; then
        echo "Error: Not in a tmux session"
        exit 1
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
    
    mark_current_window
    
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
        -c "hi Special ctermfg=yellow" \
        -c "match Comment /^#.*/" \
        -c "2match Special /\*/" \
        -c "normal G" \
        "$TEMP_FILE"
    
    if ! diff -q "$TEMP_FILE" "$ORIGINAL_FILE" >/dev/null 2>&1; then
        grep -v '^#' "$TEMP_FILE" | grep -v '^$' > "${TEMP_FILE}.clean"
        mv "${TEMP_FILE}.clean" "$TEMP_FILE"
        
        handle_window_switching
        
        clean_window_names
        
        handle_deletions
        
        apply_window_order
        
        switch_to_target_window
        
        echo "Windows updated successfully!"
        
        echo ""
        echo "Current windows:"
        tmux list-windows 2>/dev/null || echo "No windows running"
    else
        echo "No changes made."
    fi
    
            rm -f "$TEMP_FILE" "$ORIGINAL_FILE" "${TEMP_FILE}.clean" "/tmp/tmux_current_window_$"
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
  - Current window is preserved after editing

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
