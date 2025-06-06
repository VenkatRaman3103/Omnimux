#!/bin/bash

TEMP_FILE="/tmp/tmux_sessions_$$"
ORIGINAL_FILE="/tmp/tmux_sessions_original_$$"

get_sessions() {
    local index=0
    tmux list-sessions -F "#{session_name}" 2>/dev/null | sort | while read -r session_name; do
        echo "$index:$session_name"
        ((index++))
    done > "$TEMP_FILE"
    cp "$TEMP_FILE" "$ORIGINAL_FILE"
}

apply_session_changes() {
    local -A original_sessions
    local -A processed_sessions
    
    while IFS=':' read -r old_index session_name; do
        original_sessions["$old_index"]="$session_name"
    done < "$ORIGINAL_FILE"
    
    while IFS=':' read -r index session_name; do
        if [[ "$index" =~ ^[0-9]+$ ]]; then
            processed_sessions["$index"]=1
            
            if [[ -z "${original_sessions[$index]}" ]]; then
                echo "Creating new session: $session_name"
                tmux new-session -d -s "$session_name" 2>/dev/null || {
                    echo "Failed to create session: $session_name"
                }
            else
                if [[ "${original_sessions[$index]}" != "$session_name" ]]; then
                    echo "Renaming session from '${original_sessions[$index]}' to '$session_name'"
                    tmux rename-session -t "${original_sessions[$index]}" "$session_name" 2>/dev/null || {
                        echo "Failed to rename session"
                    }
                fi
            fi
        fi
    done < "$TEMP_FILE"
}

show_help() {
    cat << 'EOF'
# ╭─────────────────────────────────────────────────────────────────────────────╮
# │                           Omnimux: Mange Sessions                           │
# ╰─────────────────────────────────────────────────────────────────────────────╯
# ┌─ USAGE ─────────────────────────────────────────────────────────────────────┐
# │ • CREATE new session:    Add line "99:sessionName"                          │
# │ • RENAME session 2:      Change "2:oldName" to "2:newName"                  │
# │ • REORDER sessions:      Move lines up/down with dd and p                   │
# │ • DELETE session:        Delete the line (⚠️  KILLS THE session!)            │
# │ • SWITCH sessions:       Move the ★ to another session line                 │
# └─────────────────────────────────────────────────────────────────────────────┘
EOF
}

handle_deletions() {
    local current_session=""
    if [ -n "$TMUX" ]; then
        current_session=$(tmux display-message -p '#S')
    fi
    
    while IFS=':' read -r old_index session_name; do
        if ! grep -q "^$old_index:" "$TEMP_FILE"; then
            if [[ "$session_name" == "$current_session" ]]; then
                echo "WARNING: Cannot kill current session '$session_name' - skipping"
            else
                echo "Killing session: $session_name"
                tmux kill-session -t "$session_name" 2>/dev/null || true
            fi
        fi
    done < "$ORIGINAL_FILE"
}

mark_current_session() {
    if [ -n "$TMUX" ]; then
        local current_session=$(tmux display-message -p '#S')
        
        awk -v current="$current_session" -F':' '
            $2 == current { 
                print $1 ":" $2 " *"
                next 
            }
            { print }
        ' "$TEMP_FILE" > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    fi
}

clean_session_names() {
    sed -i 's/ \*$//' "$TEMP_FILE" 2>/dev/null || true
}

handle_session_switching() {
    local marked_session=""
    local original_current=""
    
    if [ -n "$TMUX" ]; then
        original_current=$(tmux display-message -p '#S')
    fi
    
    while IFS=':' read -r index session_line; do
        if [[ "$session_line" == *" *" ]]; then
            marked_session="${session_line% *}"
            break
        fi
    done < "$TEMP_FILE"
    
    if [ -n "$marked_session" ] && [ -n "$TMUX" ]; then
        if [ "$marked_session" != "$original_current" ]; then
            echo "Switching to session: $marked_session"
            tmux switch-client -t "$marked_session" 2>/dev/null || {
                echo "Failed to switch to session: $marked_session"
            }
        fi
    fi
}

manage_sessions() {
    if ! tmux info >/dev/null 2>&1; then
        echo "Error: tmux server is not running"
        exit 1
    fi
    
    get_sessions
    
    if [ ! -s "$TEMP_FILE" ]; then
        echo "No tmux sessions found."
        echo "Would you like to create a new session? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy] ]]; then
            echo "0:default" > "$TEMP_FILE"
        else
            exit 0
        fi
    fi
    
    mark_current_session
    
    {
        show_help
        echo ""
        cat "$TEMP_FILE"
    } > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    
    nvim \
        -c "set nonumber norelativenumber laststatus=0 noshowcmd noshowmode noruler signcolumn=no foldcolumn=0 nocursorline nocursorcolumn" \
        -c "syntax off | hi Comment ctermfg=darkgray | hi Special ctermfg=yellow" \
        -c "match Comment /^#.*/ | 2match Special /\*/" \
        -c "normal G" \
        "$TEMP_FILE"
    
    if ! diff -q "$TEMP_FILE" "$ORIGINAL_FILE" >/dev/null 2>&1; then
        grep -v '^#' "$TEMP_FILE" | grep -v '^$' > "${TEMP_FILE}.clean"
        mv "${TEMP_FILE}.clean" "$TEMP_FILE"
        
        handle_session_switching
        
        clean_session_names
        
        handle_deletions
        
        apply_session_changes
        
        echo "Sessions updated successfully!"
        
        echo ""
        echo "Current sessions:"
        tmux list-sessions 2>/dev/null || echo "No sessions running"
    else
        echo "No changes made."
    fi
    
    rm -f "$TEMP_FILE" "$ORIGINAL_FILE" "${TEMP_FILE}.clean"
}

show_usage() {
    cat << 'EOF'
Usage: tmux-session-manager.sh [OPTION]

Options:
  -h, --help       Show this help message
  -a, --attach     Quick attach to a session selection

Description:
  Interactive tmux session manager with vim-style editing.
  Allows you to manage, rename, delete, and create sessions using neovim.
  
Features:
  - Create new sessions by adding new lines with format INDEX:NAME
  - Rename sessions by editing the name part
  - Delete sessions by removing lines (be careful!)
  - Current session is marked with * when editing
  - Switch sessions by moving the * to another session line

Tmux keybinding (add to your tmux.conf):
  bind-key S run-shell 'tmux-session-manager.sh'
  bind-key C-s run-shell 'tmux-session-manager.sh -a'

Examples:
  ./tmux-session-manager.sh
  ./tmux-session-manager.sh -a

EOF
}

case "${1:-}" in
    -h|--help)
        show_usage
        ;;
    *)
        manage_sessions
        ;;
esac
