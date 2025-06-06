# Omnimux: tmux Session Manager

A tmux session manager that combines tmux, tmuxifier, zoxide, and fzf into one interface. Includes bookmark navigation, session/window editors, and quick navigation tools.

![Screenshot 2025-06-01 235635](https://github.com/user-attachments/assets/556b7bc4-a477-4d9b-9185-2e7fa2720bd6)

https://github.com/user-attachments/assets/4860255b-97df-47f9-8e63-8fc5d29e041a

https://github.com/user-attachments/assets/55229664-67e4-4811-b981-6fd23a4e4e6d

https://github.com/user-attachments/assets/c90494d2-de23-4484-bedc-20d458d3386e

https://github.com/user-attachments/assets/843c2dba-7de9-4a99-ac90-bb634962ff3e

https://github.com/user-attachments/assets/1dacec5b-7efb-41ba-a575-fbb2bbf7dac3

https://github.com/user-attachments/assets/f2f54b61-1a56-4c24-8c91-2d7a632871a7

## What It Does

### Session Management

- Browse and switch between tmux sessions, tmuxifier layouts, and zoxide paths in one place
- Preview session content, running processes, and directory contents
- Create sessions from frequently visited directories
- Manage windows within sessions
- Load and edit tmuxifier session layouts

### Bookmarks

- Bookmark important tmux windows for quick access
- Jump between bookmarked windows with one keypress
- Automatically cleans up invalid bookmarks
- Bookmarks persist across sessions and restarts

### Editors

- **Session Editor**: Edit all your tmux sessions in vim/neovim
- **Window Editor**: Manage windows within your current session
- Create, rename, delete, and reorder sessions/windows
- Bulk operations with vim-style editing

### Quick Tools

- **Session Utility**: Switch, rename, or delete sessions with tabs
- **Window Utility**: Manage windows in current session
- **Tmuxifier Utility**: Load and manage layout files

## Requirements

### Required

- **tmux** - Terminal multiplexer
- **fzf** - Fuzzy finder
- **neovim** - For the editors (or vim)

### Optional

- **tmuxifier** - Session layouts
- **zoxide** - Smart directory jumper
- **bat** or **highlight** - Syntax highlighting

## Installation

### With TPM (Recommended)

Add to your `~/.tmux.conf`:

```bash
set -g @plugin 'VenkatRaman3103/Omnimux'
```

Install with `prefix + I`, then reload:

```bash
tmux source-file ~/.tmux.conf
```

Default key bindings:

- `J` - Main session manager
- `H` - Bookmarks interface
- `a` - Add window to bookmarks
- `y` - Session editor
- `Y` - Window editor
- `j` - Session utility
- `k` - Window utility
- `h` - Tmuxifier utility

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/VenkatRaman3103/Omnimux.git ~/.tmux/plugins/omnimux
```

2. Add to `~/.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/omnimux/omnimux.tmux
```

3. Reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

## How to Use

### Main Session Manager (`J`)

- Browse all available sessions and paths
- Press Enter to switch to or create a session
- Use Ctrl+R to rename, Ctrl+D to delete
- Ctrl+W to show windows in selected session

### Bookmarks

- Press `H` to see all bookmarks
- Press `a` to bookmark current window
- Jump to any bookmark by selecting it

### Session Editor (`y`)

Edit all your sessions in vim:

```
0:main
1:development *
2:testing
3:logs
```

- Reorder by moving lines
- Add new sessions by adding lines like `4:newproject`
- Delete by removing lines
- Mark sessions with `*` to switch to them
- Save with `:wq`

### Window Editor (`Y`)

Manage windows in your current session:

```
0:shell
1:editor
2:server
3:logs
```

- Reorder windows by moving lines
- Rename by editing the name
- Add new windows
- Delete by removing lines

### Quick Utilities

Press `j` (sessions), `k` (windows), or `h` (tmuxifier) for tabbed interfaces:

- Tab 1: Switch between items
- Tab 2: Rename items
- Tab 3: Delete items
- Use number keys (1, 2, 3) to switch tabs

## Key Bindings

### Main Interface

| Key      | Action                   |
| -------- | ------------------------ |
| `Enter`  | Select/switch to session |
| `Ctrl+R` | Rename session           |
| `Ctrl+D` | Delete session           |
| `Ctrl+W` | Show windows             |
| `Ctrl+N` | New session              |
| `?`      | Help                     |
| `Escape` | Exit                     |

### Bookmarks Interface

| Key      | Action              |
| -------- | ------------------- |
| `Enter`  | Jump to bookmark    |
| `Ctrl+D` | Remove bookmark     |
| `Ctrl+A` | Add current window  |
| `Ctrl+R` | Clear all bookmarks |
| `?`      | Help                |

### Editors (vim/neovim)

| Key   | Action              |
| ----- | ------------------- |
| `dd`  | Delete line         |
| `p`   | Paste               |
| `i`   | Insert mode         |
| `o`   | New line below      |
| `:wq` | Save and exit       |
| `:q!` | Exit without saving |

### Quick Utilities

| Key     | Action         |
| ------- | -------------- |
| `1`     | Switch tab     |
| `2`     | Rename tab     |
| `3`     | Delete tab     |
| `Enter` | Execute action |

## Configuration

### Basic Setup

```bash
# Change key bindings
set -g @omnimux-key "o"                    # Main interface (default: J)
set -g @omnimux-bookmarks-key "t"          # Bookmarks interface (default: H)
set -g @omnimux-bookmarks-add-key "T"      # Add bookmark (default: a)
set -g @omnimux-edit-session-key "E"       # Session editor (default: y)
set -g @omnimux-edit-windows-key "W"       # Window editor (default: Y)
set -g @omnimux-utility-session-key "s"    # Session utility (default: j)
set -g @omnimux-utility-windows-key "w"    # Window utility (default: k)
set -g @omnimux-utility-tmuxifier-key "u"  # Tmuxifier utility (default: h)

# Display mode
set -g @omnimux-display-mode "popup"       # or "window" (default: popup)
set -g @omnimux-window-width "90%"         # Main window width (default: 100%)
set -g @omnimux-window-height "85%"        # Main window height (default: 100%)

# Border colors
set -g @omnimux-border-fg "#0c0c0c"        # Border foreground (default: #0c0c0c)
set -g @omnimux-border-bg "#0c0c0c"        # Border background (default: #0c0c0c)

# Editor size
set -g @omnimux-editor-window-width "60%"  # Editor width (default: 50%)
set -g @omnimux-editor-window-height "70%" # Editor height (default: 50%)

# Utility size
set -g @omnimux-utility-window-width "50%" # Utility width (default: 40%)
set -g @omnimux-utility-window-height "60%" # Utility height (default: 50%)
set -g @omnimux-utility-mode "verbose"     # or "minimal" (default: verbose)

# Editor
set -g @omnimux-editor "nvim"              # Editor command (default: vim or $EDITOR)
```

### Colors

```bash
# Main interface colors
set -g @omnimux-active-bg "#444444"        # Selected item background
set -g @omnimux-active-fg "#ffffff"        # Selected item text
set -g @omnimux-inactive-bg "#222222"      # Unselected background
set -g @omnimux-inactive-fg "#777777"      # Unselected text

# Bookmarks colors (Note: fix typo 'bookmars' to 'bookmarks' in your code)
set -g @bookmarks-active-color "#87ceeb"     # Active bookmark
set -g @bookmarks-session-color "#ffffff"    # Session names
set -g @bookmarks-window-color "#90ee90"     # Window numbers
set -g @bookmarks-mark-color "#777777"       # Bookmark marks

# Editor colors
set -g @omnimux-editor-active-bg "#2d3748"   # Active tab
set -g @omnimux-editor-active-fg "#e2e8f0"   # Active text
set -g @omnimux-editor-inactive-bg "#1a202c" # Inactive tab
set -g @omnimux-editor-inactive-fg "#718096" # Inactive text

# Utility colors
set -g @omnimux-util-active-bg "#4ecdc4"     # Active selection
set -g @omnimux-util-active-fg "#1a202c"     # Active text
set -g @omnimux-util-tab-active "#4ecdc4"    # Active tab
set -g @omnimux-util-tab-inactive "#718096"  # Inactive tab
```

### Content Colors

```bash
# Session types
set -g @omnimux-tmux-session-color "#ffffff"      # Regular tmux sessions
set -g @omnimux-tmuxifier-session-color "#87ceeb" # Tmuxifier layouts
set -g @omnimux-zoxide-path-color "#90ee90"       # Zoxide paths
set -g @omnimux-find-path-color "#dda0dd"         # Find results

# Marks and indicators
set -g @omnimux-tmux-mark-color "#333333"         # Session type marks
set -g @omnimux-tmux-color "#333333"              # Tmux session color
set -g @omnimux-tmuxifier-mark-color "#333333"    # Tmuxifier marks
set -g @omnimux-zoxide-mark-color "#333333"       # Zoxide marks
set -g @omnimux-find-mark-color "#333333"         # Find marks
set -g @omnimux-active-session-color "#333333"    # Current session indicator
```

### Search and Display

```bash
# Path limits
set -g @omnimux-max-zoxide-paths "20"       # Max zoxide results (default: 20)
set -g @omnimux-max-find-paths "15"         # Max find results (default: 500)
set -g @omnimux-find-base-dir "$HOME"       # Where to search (default: $HOME)
set -g @omnimux-find-max-depth "3"          # Search depth (default: 5)
set -g @omnimux-find-min-depth "1"          # Minimum depth (default: 1)

# Preview settings
set -g @omnimux-preview-enabled "true"      # Enable previews (default: false)
set -g @bookmarks-preview-enabled "true"    # Enable bookmarks preview (default: true)
set -g @omnimux-show-preview-lines "15"     # Preview length (default: 15)
set -g @omnimux-show-process-count "3"      # Processes to show (default: 3)
set -g @omnimux-show-ls-lines "20"          # Directory listing lines (default: 20)
set -g @omnimux-show-git-status-lines "10"  # Git status lines (default: 10)

# Commands
set -g @omnimux-ls-command "ls -la"         # Directory listing (default: ls -la)
set -g @omnimux-editor "nvim"               # Editor for files (default: vim or $EDITOR)
```

### FZF Interface

```bash
# Main interface
set -g @omnimux-fzf-height "100%"                        # FZF height (default: 100%)
set -g @omnimux-fzf-border "none"                        # FZF border (default: none)
set -g @omnimux-fzf-layout "no-reverse"                  # FZF layout (default: no-reverse)
set -g @omnimux-fzf-prompt "> "                          # FZF prompt (default: "> ")
set -g @omnimux-fzf-pointer "▶"                          # FZF pointer (default: "▶")
set -g @omnimux-fzf-preview-position "bottom:60%"        # Preview position (default: bottom:60%)

# Window selection
set -g @omnimux-fzf-window-layout "reverse"              # Window layout (default: reverse)
set -g @omnimux-fzf-window-prompt "> "                   # Window prompt (default: "> ")
set -g @omnimux-fzf-window-pointer "▶"                   # Window pointer (default: "▶")
set -g @omnimux-fzf-preview-window-position "right:75%"  # Window preview position (default: right:75%)

# Bookmarks interface (Note: fix typo 'bookmars' to 'bookmarks' in your code)
set -g @bookmarks-fzf-height "100%"                      # Bookmarks height (default: 100%)
set -g @bookmarks-fzf-border "none"                      # Bookmarks border (default: none)
set -g @bookmarks-fzf-layout "no-reverse"                # Bookmarks layout (default: no-reverse)
set -g @bookmarks-fzf-prompt "Bookmarks > "              # Bookmarks prompt (default: "bookmars > ")
set -g @bookmarks-fzf-pointer "▶"                        # Bookmarks pointer (default: "▶")
set -g @bookmarks-fzf-preview-position "top:60%"         # Bookmarks preview position (default: top:60%)
set -g @bookmarks-show-preview-lines "15"                # Bookmarks preview lines (default: 15)
```

## Example Workflows

### Setting Up a Development Project

1. Press `y` to open Session Editor
2. Add your project sessions:
   ```
   0:main
   1:frontend
   2:backend
   3:database
   4:testing
   ```
3. Save with `:wq`
4. Switch to each session and press `Y` to set up windows
5. Bookmark important windows with `a`
6. Use `H` to quickly jump between bookmarks

### Daily Development Work

1. Press `H` to see your bookmarks and jump to main work
2. Use `j` for quick session switching between projects
3. Use `k` for window navigation within current project
4. Press `a` to bookmark new important windows as you create them

### Cleaning Up Sessions

1. Press `y` to open Session Editor
2. Remove unwanted sessions by deleting lines
3. Reorder sessions by moving lines
4. Save with `:wq`

## Troubleshooting

### Common Problems

**"This script must be run inside a tmux session"**

- Run the commands from within a tmux session

**"neovim is not installed"**

- Install neovim: `brew install neovim` or `apt install neovim`
- Or change editor: `set -g @omnimux-editor "vim"`

**"fzf is not installed"**

- Install fzf: `brew install fzf` or `apt install fzf`

**Key bindings don't work**

- Install via TPM with `prefix + I`
- Reload config: `tmux source-file ~/.tmux.conf`
- Check for key conflicts with other plugins

**Editor changes don't apply**

- Save with `:wq` in vim/neovim
- Don't try to delete your current session/window
- Check tmux permissions

**Utility tabs don't switch**

- Use number keys `1`, `2`, `3` to switch tabs
- Make sure fzf is installed

### Debug Information

**File locations:**

- Session Editor: `/tmp/tmux_sessions_*`
- Window Editor: `/tmp/tmux_windows_*`
- Bookmarks: `~/.tmux-bookmarks-list` (Note: fix typo 'bookmars' to 'bookmarks' in your code)
- Temporary files: `/tmp/tmux_bookmarks_$` and `/tmp/tmux_bookmarks_original_$`

**Check configuration:**

```bash
tmux show-options -g | grep omnimux
```

**Test fzf:**

```bash
tmux list-sessions | fzf
```

## Complete Example Configuration

```bash
# ~/.tmux.conf

# Install omnimux
set -g @plugin 'VenkatRaman3103/Omnimux'

# Custom key bindings
set -g @omnimux-key "o"                      # Main interface
set -g @omnimux-bookmarks-key "t"            # Bookmarks
set -g @omnimux-bookmarks-add-key "T"        # Add bookmark
set -g @omnimux-edit-session-key "E"         # Session editor
set -g @omnimux-edit-windows-key "W"         # Window editor
set -g @omnimux-utility-session-key "s"      # Session utility
set -g @omnimux-utility-windows-key "w"      # Window utility

# Display settings
set -g @omnimux-display-mode "popup"
set -g @omnimux-window-width "90%"
set -g @omnimux-window-height "85%"

# Colors
set -g @omnimux-active-bg "#2d3748"
set -g @omnimux-active-fg "#e2e8f0"
set -g @bookmarks-active-color "#ff6b6b"
set -g @bookmarks-session-color "#4ecdc4"

# Features
set -g @omnimux-preview-enabled "true"
set -g @bookmarks-preview-enabled "true"
set -g @omnimux-editor "nvim"
```

## Contributing

Contributions welcome! The project has these main parts:

- **Core session management** (`omnimux_main.sh`)
- **Bookmarks** (`bookmarks_*.sh`)
- **Editors** (`editor_*.sh`)
- **Utilities** (`utility/`)

Report issues or submit pull requests on GitHub.
