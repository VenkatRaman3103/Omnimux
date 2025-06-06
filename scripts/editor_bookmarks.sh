#!/bin/bash

bookmars_FILE="$HOME/.tmux-bookmars-list"
TEMP_FILE="/tmp/tmux_bookmars_$$"
ORIGINAL_FILE="/tmp/tmux_bookmars_original_$$"
CURRENT_SESSION=$(tmux display-message -p '#S')
CURRENT_WINDOW=$(tmux display-message -p '#I')
CURRENT_TARGET="${CURRENT_SESSION}:${CURRENT_WINDOW}"

create_bookmars_file() {
    if [ ! -f "$bookmars_FILE" ]; then
        touch "$bookmars_FILE"
    fi
}

prepare_editor_file() {
    create_bookmars_file
    
    local line_number=1
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local session=$(echo "$line" | cut -d':' -f1)
            local window=$(echo "$line" | cut -d':' -f2)
            
            if tmux has-session -t "$session" 2>/dev/null; then
                if tmux list-windows -t "$session" -F "#I" 2>/dev/null | grep -q "^${window}$"; then
                    local window_name=$(tmux list-windows -t "$session" -F "#I #W" 2>/dev/null | grep "^${window} " | cut -d' ' -f2-)
                    
                    if [ "$line" = "$CURRENT_TARGET" ]; then
                        echo "$line_number:$line ($window_name) *" >> "$TEMP_FILE"
                    else
                        echo "$line_number:$line ($window_name)" >> "$TEMP_FILE"
                    fi
                else
                    echo "$line_number:$line (invalid - window not found)" >> "$TEMP_FILE"
                fi
            else
                echo "$line_number:$line (invalid - session not found)" >> "$TEMP_FILE"
            fi
            line_number=$((line_number + 1))
        fi
    done < "$bookmars_FILE"
    
    cp "$TEMP_FILE" "$ORIGINAL_FILE"
}

show_editor_help() {
    cat << 'EOF'
# ╭─────────────────────────────────────────────────────────────────────────────╮
# │                      bookmars: DELETE ONLY MODE                             │
# ╰─────────────────────────────────────────────────────────────────────────────╯
# ┌─ USAGE ─────────────────────────────────────────────────────────────────────┐
# │ • DELETE entry:          Delete the entire line (dd in vim)                 │
# │ • REORDER entries:       Move lines up/down with dd and p                   │
# │                                                                             │
# │ WARNING: Creating new entries or modifying existing entries is DISABLED     │
# │          Only deletion and reordering is allowed                            │
# └─────────────────────────────────────────────────────────────────────────────┘
# ┌─ CURRENT ENTRIES ───────────────────────────────────────────────────────────┐
# │ Delete any line below to remove it from your bookmars list                   │
# │ The * marker indicates your current session/window                          │
# └─────────────────────────────────────────────────────────────────────────────┘
EOF
}

validate_deletion_only() {
    local original_entries=()
    local current_entries=()
    local has_invalid_changes=false
    
    while IFS=':' read -r index session window rest; do
        if [[ "$index" =~ ^[0-9]+$ ]] && [ -n "$session" ] && [ -n "$window" ]; then
            window=$(echo "$window" | awk '{print $1}')
            original_entries+=("$session:$window")
        fi
    done < "$ORIGINAL_FILE"
    
    while IFS=':' read -r index session window rest; do
        if [[ "$index" =~ ^[0-9]+$ ]] && [ -n "$session" ] && [ -n "$window" ]; then
            window=$(echo "$window" | awk '{print $1}')
            current_entries+=("$session:$window")
        fi
    done < "$TEMP_FILE"
    
    for current_entry in "${current_entries[@]}"; do
        local found=false
        for original_entry in "${original_entries[@]}"; do
            if [ "$current_entry" = "$original_entry" ]; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            echo "Error: Creating new entries is not allowed in delete-only mode"
            echo "New entry detected: $current_entry"
            has_invalid_changes=true
        fi
    done
    
    local current_count=${#current_entries[@]}
    local original_count=${#original_entries[@]}
    
    if [ $current_count -gt $original_count ]; then
        echo "Error: Adding entries is not allowed in delete-only mode"
        has_invalid_changes=true
    fi
    
    for current_entry in "${current_entries[@]}"; do
        local entry_found=false
        for original_entry in "${original_entries[@]}"; do
            if [ "$current_entry" = "$original_entry" ]; then
                entry_found=true
                break
            fi
        done
        if [ "$entry_found" = false ]; then
            echo "Error: Modified or new entry detected: $current_entry"
            echo "Only deletion and reordering is allowed"
            has_invalid_changes=true
        fi
    done
    
    if [ "$has_invalid_changes" = true ]; then
        echo ""
        echo "Invalid changes detected. Only deletion and reordering is allowed."
        echo "Aborting operation."
        return 1
    fi
    
    return 0
}

apply_bookmars_changes() {
    local temp_bookmars_file=$(mktemp)
    
    while IFS=':' read -r index session window rest; do
        if [[ "$index" =~ ^[0-9]+$ ]] && [ -n "$session" ] && [ -n "$window" ]; then
            window=$(echo "$window" | awk '{print $1}')
            local new_target="$session:$window"
            echo "$new_target" >> "$temp_bookmars_file"
        fi
    done < "$TEMP_FILE"
    
    mv "$temp_bookmars_file" "$bookmars_FILE"
}

edit_bookmarss() {
    if ! tmux info >/dev/null 2>&1; then
        echo "Error: tmux server is not running"
        exit 1
    fi
    
    prepare_editor_file
    
    if [ ! -s "$TEMP_FILE" ]; then
        echo "No bookmars entries found. Cannot use delete-only mode with empty list."
        echo "Use the regular bookmars editor to create entries first."
        exit 1
    fi
    
    {
        cat "$TEMP_FILE"
        echo ""
        show_editor_help
    } > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    
    ${EDITOR:-nvim} \
        -c "set laststatus=0 noshowcmd noshowmode noruler signcolumn=no foldcolumn=0 nocursorline nocursorcolumn" \
        -c "syntax off | hi Comment ctermfg=darkgray | hi Special ctermfg=yellow | hi ErrorMsg ctermfg=red | hi String ctermfg=green" \
        -c "match Comment /^#.*/ | 2match Special /\*/ | 3match ErrorMsg /invalid/ | syntax match String /([^)]*)/" \
        "$TEMP_FILE"
    
    if ! diff -q "$TEMP_FILE" "$ORIGINAL_FILE" >/dev/null 2>&1; then
        grep -v '^#' "$TEMP_FILE" | grep -v '^$' > "${TEMP_FILE}.clean"
        mv "${TEMP_FILE}.clean" "$TEMP_FILE"
        
        if validate_deletion_only; then
            apply_bookmars_changes
            
            echo "bookmars entries updated successfully!"
            
            echo ""
            echo "Current bookmars entries:"
            if [ -s "$bookmars_FILE" ]; then
                local count=1
                while IFS= read -r line; do
                    if [ -n "$line" ]; then
                        local session=$(echo "$line" | cut -d':' -f1)
                        local window=$(echo "$line" | cut -d':' -f2)
                        
                        if tmux has-session -t "$session" 2>/dev/null; then
                            if tmux list-windows -t "$session" -F "#I" 2>/dev/null | grep -q "^${window}$"; then
                                local window_name=$(tmux list-windows -t "$session" -F "#I #W" 2>/dev/null | grep "^${window} " | cut -d' ' -f2-)
                                if [ "$line" = "$CURRENT_TARGET" ]; then
                                    printf "%d. %s (%s) [current]\n" "$count" "$line" "$window_name"
                                else
                                    printf "%d. %s (%s)\n" "$count" "$line" "$window_name"
                                fi
                            else
                                printf "%d. %s [invalid - window not found]\n" "$count" "$line"
                            fi
                        else
                            printf "%d. %s [invalid - session not found]\n" "$count" "$line"
                        fi
                        count=$((count + 1))
                    fi
                done < "$bookmars_FILE"
            else
                echo "No entries"
            fi
        fi
    else
        echo "No changes made."
    fi
    
    rm -f "$TEMP_FILE" "$ORIGINAL_FILE" "${TEMP_FILE}.clean"
}

show_usage() {
    cat << 'EOF'
Usage: tmux-bookmars-editor-delete-only.sh [OPTION]

Description:
  DELETE-ONLY mode for tmux bookmars entries.
  Allows only deletion and reordering of existing entries.
  Creating new entries or modifying existing ones is disabled.
  
Features:
  - Delete entries by removing lines (dd in vim)
  - Reorder entries by moving lines (dd + p)
  - Validation prevents creation or modification
  - Syntax highlighting for better visibility
  - Shows current session with * marker

Editor Format:
  INDEX:SESSION:WINDOW (window_name) [*]
  
Actions Allowed:
  - Delete entire lines
  - Reorder lines
  
Actions Blocked:
  - Creating new entries
  - Modifying session names
  - Modifying window numbers
  - Adding new lines

Options:
  -h, --help       Show this help message
  
Tmux keybinding (add to your tmux.conf):
  bind-key H run-shell 'tmux-bookmars-editor-delete-only.sh'

Dependencies:
  - tmux
  - vim or neovim (set EDITOR environment variable)

EOF
}

case "${1:-}" in
    -h|--help)
        show_usage
        ;;
    *)
        if [ -z "$TMUX" ]; then
            echo "Error: This script must be run inside a tmux session."
            exit 1
        fi
        
        edit_bookmarss
        ;;
esac
