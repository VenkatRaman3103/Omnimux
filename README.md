# Omnimux 🚀

A powerful, interactive tmux session manager that brings together tmux, tmuxifier, zoxide, and fzf for a seamless terminal workflow experience. Now featuring **Harpoon** - quick bookmark navigation for your favorite tmux windows!

![Screenshot 2025-06-01 235635](https://github.com/user-attachments/assets/556b7bc4-a477-4d9b-9185-2e7fa2720bd6)

https://github.com/user-attachments/assets/4860255b-97df-47f9-8e63-8fc5d29e041a

https://github.com/user-attachments/assets/55229664-67e4-4811-b981-6fd23a4e4e6d

https://github.com/user-attachments/assets/c90494d2-de23-4484-bedc-20d458d3386e

https://github.com/user-attachments/assets/843c2dba-7de9-4a99-ac90-bb634962ff3e

https://github.com/user-attachments/assets/1dacec5b-7efb-41ba-a575-fbb2bbf7dac3

## Features ✨

### Core Session Management

- **Unified Session Management**: Browse and switch between active tmux sessions, tmuxifier layouts, zoxide paths, and find results in one interface
- **Interactive Preview**: Real-time preview of session content, running processes, directory contents, and git status
- **Smart Path Integration**: Automatically create sessions from frequently visited directories (zoxide) or discovered paths (find)
- **Window Management**: Navigate, rename, create, and delete windows within sessions
- **Tmuxifier Integration**: Load, edit, rename, and manage tmuxifier session layouts

### 🎯 Harpoon Feature

- **Quick Bookmarking**: Instantly bookmark your most important tmux windows for rapid access
- **Fast Navigation**: Jump between bookmarked windows with a single keypress
- **Smart Management**: Add, remove, and organize your harpoon entries with intuitive controls
- **Visual Feedback**: Color-coded interface showing active sessions and window status
- **Persistent Storage**: Bookmarks persist across tmux sessions and system restarts
- **Automatic Cleanup**: Intelligently removes invalid entries when sessions/windows are deleted

### Additional Features

- **Highly Customizable**: Extensive configuration options for colors, layout, and behavior
- **Keyboard-Driven**: Fast navigation with intuitive keyboard shortcuts
- **Dual Display Modes**: Choose between popup overlay or dedicated window modes
- **Advanced Color Customization**: Full color control for all UI elements
- **Smart Session Filtering**: Intelligent filtering to avoid duplicate sessions

## Prerequisites 📋

### Required

- **tmux** - Terminal multiplexer
- **fzf** - Fuzzy finder for interactive selection

### Optional (Recommended)

- **tmuxifier** - Tmux session layouts manager
- **zoxide** - Smart directory jumper
- **bat** or **highlight** - Syntax highlighting for session file previews

## Installation 🔧

### Option 1: TPM (Recommended)

If you're using [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm):

1. **Add to your `~/.tmux.conf`:**

   ```bash
   set -g @plugin 'VenkatRaman3103/Omnimux'
   ```

2. **Install the plugin:**
   Press `prefix + I` (default: `Ctrl-b + I`) to install the plugin via TPM.

3. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

The default key bindings will be automatically configured:

- `J` - Launch Omnimux session manager
- `H` - Open Harpoon interface
- `h` - Add current window to Harpoon

### Option 2: Manual Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/VenkatRaman3103/Omnimux.git ~/.tmux/plugins/omnimux
   ```

2. **Add to your `~/.tmux.conf`:**

   ```bash
   # Source omnimux plugin
   run-shell ~/.tmux/plugins/omnimux/omnimux.tmux
   ```

3. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### Option 3: Standalone Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/VenkatRaman3103/Omnimux.git
   cd Omnimux
   ```

2. **Make the scripts executable:**

   ```bash
   chmod +x scripts/*.sh
   chmod +x omnimux.tmux
   ```

3. **Add to your PATH (optional):**

   ```bash
   # Add to your ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/Omnimux"
   ```

4. **Set up tmux key bindings manually:**
   ```bash
   # Add to your ~/.tmux.conf
   bind-key J run-shell 'path/to/scripts/omnimux_main.sh'
   bind-key H run-shell 'path/to/scripts/harpoon_interface.sh'
   bind-key h run-shell 'path/to/scripts/harpoon_add.sh'
   ```

## Usage 🎯

### Session Management

**Default Key Binding**: Press `J` from within any tmux session to launch Omnimux.

You can also run the script directly:

```bash
./scripts/omnimux_main.sh
```

### Harpoon Navigation

**Quick Access**: Press `H` to open the Harpoon interface and see all your bookmarked windows.

**Add Bookmark**: Press `h` to add the current window to your Harpoon list.

**Workflow Example**:

1. Navigate to your most important windows (editor, server, logs, etc.)
2. Press `h` in each window to add them to Harpoon
3. Use `H` anytime to quickly jump between these bookmarked windows
4. Access your bookmarks from any session or window

### Keyboard Shortcuts

#### Main Omnimux Interface

| Key      | Action                              |
| -------- | ----------------------------------- |
| `Enter`  | Select session (switch/load/create) |
| `Ctrl+R` | Rename selected session             |
| `Ctrl+E` | Edit tmuxifier session file         |
| `Ctrl+T` | Terminate active tmux session       |
| `Ctrl+D` | Delete tmuxifier session file       |
| `Ctrl+W` | Show windows in selected session    |
| `Ctrl+N` | Create new session                  |
| `Ctrl+P` | Toggle preview mode                 |
| `Ctrl+F` | Filter/search sessions              |
| `?`      | Show help menu                      |
| `Escape` | Exit                                |

#### Harpoon Interface

| Key      | Action                         |
| -------- | ------------------------------ |
| `Enter`  | Jump to selected harpoon entry |
| `Ctrl+D` | Remove selected harpoon entry  |
| `Ctrl+A` | Add current window to harpoon  |
| `Ctrl+R` | Clear all harpoon entries      |
| `Ctrl+X` | Clean invalid entries          |
| `Ctrl+P` | Toggle preview mode            |
| `?`      | Show help menu                 |
| `Escape` | Exit                           |

#### Window Management

| Key      | Action                    |
| -------- | ------------------------- |
| `Enter`  | Switch to selected window |
| `Ctrl+R` | Rename selected window    |
| `Ctrl+D` | Delete selected window    |
| `Ctrl+N` | Create new window         |
| `Escape` | Return to sessions        |

## Display Modes 🖥️

Omnimux supports two display modes that apply to both the main interface and Harpoon:

### Popup Mode (Default)

- Opens interfaces in a tmux popup overlay
- Non-intrusive and quick to access
- Customizable size and border colors
- Perfect for quick session switching and harpoon navigation

### Window Mode

- Opens interfaces in a new tmux window
- Provides more space for complex operations
- Useful when working with many sessions or harpoon entries
- Can be easily navigated back to

```bash
# Switch to window mode
set -g @omnimux-display-mode "window"
```

## Complete Configuration Reference ⚙️

### Basic Setup Options

| Option                     | Default     | Description                           |
| -------------------------- | ----------- | ------------------------------------- |
| `@omnimux-key`             | `"J"`       | Key binding to launch Omnimux         |
| `@omnimux-harpoon-key`     | `"H"`       | Key binding to open Harpoon interface |
| `@omnimux-harpoon-add-key` | `"h"`       | Key binding to add to Harpoon         |
| `@omnimux-display-mode`    | `"popup"`   | Display mode: `popup` or `window`     |
| `@omnimux-window-width`    | `"100%"`    | Popup window width                    |
| `@omnimux-window-height`   | `"100%"`    | Popup window height                   |
| `@omnimux-border-fg`       | `"#0c0c0c"` | Popup border foreground color         |
| `@omnimux-border-bg`       | `"#0c0c0c"` | Popup border background color         |

### Visual Appearance Colors

| Option                 | Default     | Description                   |
| ---------------------- | ----------- | ----------------------------- |
| `@omnimux-active-bg`   | `"#444444"` | Active selection background   |
| `@omnimux-active-fg`   | `"#ffffff"` | Active selection foreground   |
| `@omnimux-inactive-bg` | `"#222222"` | Inactive selection background |
| `@omnimux-inactive-fg` | `"#777777"` | Inactive selection foreground |

### Harpoon-Specific Configuration

| Option                          | Default        | Description                    |
| ------------------------------- | -------------- | ------------------------------ |
| `@harpoon-active-color`         | `"#87ceeb"`    | Active harpoon entry color     |
| `@harpoon-session-color`        | `"#ffffff"`    | Harpoon session name color     |
| `@harpoon-window-color`         | `"#90ee90"`    | Harpoon window number color    |
| `@harpoon-mark-color`           | `"#777777"`    | Harpoon mark/label color       |
| `@harpoon-fzf-height`           | `"100%"`       | Harpoon FZF interface height   |
| `@harpoon-fzf-border`           | `"none"`       | Harpoon FZF border style       |
| `@harpoon-fzf-layout`           | `"no-reverse"` | Harpoon FZF layout             |
| `@harpoon-fzf-preview-position` | `"top:60%"`    | Harpoon preview position       |
| `@harpoon-fzf-prompt`           | `"Harpoon > "` | Harpoon interface prompt       |
| `@harpoon-fzf-pointer`          | `"▶"`         | Harpoon interface pointer      |
| `@harpoon-preview-enabled`      | `"true"`       | Enable/disable harpoon preview |
| `@harpoon-show-preview-lines`   | `"15"`         | Lines in harpoon preview       |
| `@harpoon-show-process-count`   | `"3"`          | Processes shown in preview     |

### Source Type Colors

| Option                          | Default     | Description                    |
| ------------------------------- | ----------- | ------------------------------ |
| `@omnimux-tmuxifier-mark-color` | `"#333333"` | Tmuxifier mark color           |
| `@omnimux-zoxide-mark-color`    | `"#333333"` | Zoxide mark color              |
| `@omnimux-find-mark-color`      | `"#333333"` | Find mark color                |
| `@omnimux-tmux-color`           | `"#333333"` | Tmux session color             |
| `@omnimux-tmux-mark-color`      | `"#333333"` | Tmux mark color                |
| `@omnimux-active-session-color` | `"#333333"` | Active session indicator color |

### Content Colors

| Option                             | Default     | Description                  |
| ---------------------------------- | ----------- | ---------------------------- |
| `@omnimux-tmux-session-color`      | `"#ffffff"` | Tmux session name color      |
| `@omnimux-tmuxifier-session-color` | `"#87ceeb"` | Tmuxifier session name color |
| `@omnimux-zoxide-path-color`       | `"#90ee90"` | Zoxide path color            |
| `@omnimux-find-path-color`         | `"#dda0dd"` | Find path color              |

### FZF Configuration

| Option                        | Default        | Description              |
| ----------------------------- | -------------- | ------------------------ |
| `@omnimux-fzf-height`         | `"100%"`       | FZF interface height     |
| `@omnimux-fzf-border`         | `"none"`       | FZF border style         |
| `@omnimux-fzf-layout`         | `"no-reverse"` | Main FZF layout          |
| `@omnimux-fzf-window-layout`  | `"reverse"`    | Window selection layout  |
| `@omnimux-fzf-prompt`         | `"> "`         | Main interface prompt    |
| `@omnimux-fzf-window-prompt`  | `"> "`         | Window selection prompt  |
| `@omnimux-fzf-pointer`        | `"▶"`         | Main interface pointer   |
| `@omnimux-fzf-window-pointer` | `"▶"`         | Window selection pointer |

### Preview Settings

| Option                                 | Default        | Description                         |
| -------------------------------------- | -------------- | ----------------------------------- |
| `@omnimux-preview-enabled`             | `"false"`      | Enable/disable preview pane         |
| `@omnimux-fzf-preview-position`        | `"bottom:60%"` | Preview position for main interface |
| `@omnimux-fzf-preview-window-position` | `"right:75%"`  | Preview position for windows        |

### Path & Search Settings

| Option                      | Default   | Description                    |
| --------------------------- | --------- | ------------------------------ |
| `@omnimux-max-zoxide-paths` | `"20"`    | Maximum zoxide paths to show   |
| `@omnimux-max-find-paths`   | `"15"`    | Maximum find results to show   |
| `@omnimux-find-base-dir`    | `"$HOME"` | Base directory for find search |
| `@omnimux-find-max-depth`   | `"3"`     | Maximum depth for find search  |
| `@omnimux-find-min-depth`   | `"1"`     | Minimum depth for find search  |

### Display & Content Settings

| Option                           | Default            | Description                            |
| -------------------------------- | ------------------ | -------------------------------------- |
| `@omnimux-ls-command`            | `"ls -la"`         | Command for directory listings         |
| `@omnimux-show-process-count`    | `"3"`              | Number of processes to show in preview |
| `@omnimux-show-preview-lines`    | `"15"`             | Lines to show in session preview       |
| `@omnimux-show-ls-lines`         | `"20"`             | Lines to show in directory listings    |
| `@omnimux-show-git-status-lines` | `"10"`             | Lines to show in git status            |
| `@omnimux-editor`                | `"${EDITOR:-vim}"` | Editor for tmuxifier files             |

## Example Configuration 📝

Here's a complete example configuration showing all available options including the new Harpoon feature:

```bash
# ~/.tmux.conf

# Install omnimux via TPM
set -g @plugin 'VenkatRaman3103/Omnimux'

# === Basic Setup ===
set -g @omnimux-key "s"                    # Change main key from J to s
set -g @omnimux-harpoon-key "t"            # Change harpoon key from H to t
set -g @omnimux-harpoon-add-key "T"        # Change harpoon add key from h to T
set -g @omnimux-display-mode "popup"       # Use popup mode (default)
set -g @omnimux-window-width "90%"         # Popup width
set -g @omnimux-window-height "85%"        # Popup height
set -g @omnimux-border-fg "#ff6b6b"        # Red border foreground
set -g @omnimux-border-bg "#2d3748"        # Dark border background

# === Visual Appearance ===
set -g @omnimux-active-bg "#2d3748"        # Dark blue active background
set -g @omnimux-active-fg "#e2e8f0"        # Light gray active foreground
set -g @omnimux-inactive-bg "#1a202c"      # Darker inactive background
set -g @omnimux-inactive-fg "#718096"      # Medium gray inactive foreground

# === Harpoon Colors ===
set -g @harpoon-active-color "#ff6b6b"      # Red for active harpoon entry
set -g @harpoon-session-color "#4ecdc4"     # Teal for session names
set -g @harpoon-window-color "#ffe66d"      # Yellow for window numbers
set -g @harpoon-mark-color "#a8a8a8"        # Gray for marks and labels

# === Harpoon Interface Settings ===
set -g @harpoon-fzf-prompt "🎯 "            # Target emoji prompt
set -g @harpoon-fzf-pointer "→"             # Arrow pointer
set -g @harpoon-preview-enabled "true"      # Enable preview
set -g @harpoon-fzf-preview-position "right:60%"  # Preview on right

# === Source Type Mark Colors ===
set -g @omnimux-tmuxifier-mark-color "#4299e1"  # Blue for tmuxifier
set -g @omnimux-zoxide-mark-color "#ed8936"     # Orange for zoxide
set -g @omnimux-find-mark-color "#48bb78"       # Green for find
set -g @omnimux-tmux-mark-color "#9f7aea"       # Purple for tmux
set -g @omnimux-active-session-color "#f56565"  # Red for active session

# === Content Colors ===
set -g @omnimux-tmux-session-color "#ffffff"       # White tmux sessions
set -g @omnimux-tmuxifier-session-color "#87ceeb"  # Sky blue tmuxifier
set -g @omnimux-zoxide-path-color "#90ee90"        # Light green zoxide paths
set -g @omnimux-find-path-color "#dda0dd"          # Plum find paths

# === FZF Interface ===
set -g @omnimux-fzf-height "100%"            # Full height
set -g @omnimux-fzf-border "rounded"         # Rounded borders
set -g @omnimux-fzf-layout "no-reverse"      # Normal layout
set -g @omnimux-fzf-window-layout "reverse"  # Reverse for windows
set -g @omnimux-fzf-prompt "🚀 "             # Rocket emoji prompt
set -g @omnimux-fzf-window-prompt "📋 "      # Clipboard emoji for windows
set -g @omnimux-fzf-pointer "→"              # Arrow pointer
set -g @omnimux-fzf-window-pointer "▸"       # Different arrow for windows

# === Preview Settings ===
set -g @omnimux-preview-enabled "true"                    # Enable preview
set -g @omnimux-fzf-preview-position "right:60%"          # Preview on right
set -g @omnimux-fzf-preview-window-position "bottom:50%"  # Bottom for windows

# === Path & Search ===
set -g @omnimux-max-zoxide-paths "25"            # More zoxide paths
set -g @omnimux-max-find-paths "20"              # More find results
set -g @omnimux-find-base-dir "$HOME/projects"   # Search in projects
set -g @omnimux-find-max-depth "4"               # Deeper search
set -g @omnimux-find-min-depth "2"               # Skip immediate subdirs

# === Display Settings ===
set -g @omnimux-ls-command "exa -la --color=always"    # Use exa instead of ls
set -g @omnimux-show-process-count "5"                 # Show more processes
set -g @omnimux-show-preview-lines "20"                # More preview lines
set -g @omnimux-show-ls-lines "25"                     # More directory listing lines
set -g @omnimux-show-git-status-lines "15"             # More git status lines
set -g @omnimux-editor "nvim"                          # Use neovim for editing
```

### Minimal Configuration

For a simple setup with just the essentials:

```bash
# ~/.tmux.conf

# Install omnimux
set -g @plugin 'VenkatRaman3103/Omnimux'

# Basic customization
set -g @omnimux-key "s"                     # Use 's' instead of 'J'
set -g @omnimux-harpoon-key "a"             # Use 'a' for harpoon interface
set -g @omnimux-harpoon-add-key "A"         # Use 'A' to add to harpoon
set -g @omnimux-preview-enabled "true"      # Enable preview
set -g @harpoon-preview-enabled "true"      # Enable harpoon preview
set -g @omnimux-display-mode "popup"        # Use popup mode
```

### Color Theme Examples

#### Dark Theme

```bash
set -g @omnimux-active-bg "#2d3748"
set -g @omnimux-active-fg "#e2e8f0"
set -g @harpoon-active-color "#4ecdc4"
set -g @harpoon-session-color "#ffffff"
set -g @harpoon-window-color "#90ee90"
```

#### Light Theme

```bash
set -g @omnimux-active-bg "#f7fafc"
set -g @omnimux-active-fg "#1a202c"
set -g @harpoon-active-color "#3182ce"
set -g @harpoon-session-color "#2d3748"
set -g @harpoon-window-color "#38a169"
```

#### Cyberpunk Theme

```bash
set -g @omnimux-active-bg "#0d1117"
set -g @omnimux-active-fg "#00ff41"
set -g @harpoon-active-color "#ff0080"
set -g @harpoon-session-color "#00ffff"
set -g @harpoon-window-color "#ffff00"
```

## How It Works 🔍

### Session Management

Omnimux aggregates different sources of sessions and paths:

1. **Active Tmux Sessions** - Currently running tmux sessions (with active session prioritized)
2. **Tmuxifier Layouts** - Predefined session templates (filtered to exclude active ones)
3. **Zoxide Paths** - Frequently visited directories from your zoxide database
4. **Find Results** - Directories discovered through filesystem search

### Harpoon Navigation

The Harpoon feature provides a persistent bookmark system:

1. **Storage** - Bookmarks are stored in `~/.tmux-harpoon-list`
2. **Format** - Each entry is stored as `session_name:window_number`
3. **Validation** - Automatically validates that sessions and windows still exist
4. **Navigation** - Provides instant access to your most important windows
5. **Management** - Easy addition, removal, and cleanup of bookmarks

Each source is color-coded and labeled for easy identification. The preview pane shows relevant information like session content, directory listings, git status, and running processes.

## Workflow Examples 🔗

### Typical Development Workflow with Harpoon

```bash
# 1. Set up your development environment
tmux new-session -s "myproject"
tmux new-window -n "editor"     # Window 1: Your code editor
tmux new-window -n "server"     # Window 2: Development server
tmux new-window -n "tests"      # Window 3: Running tests
tmux new-window -n "logs"       # Window 4: Application logs

# 2. Bookmark your important windows
# Navigate to each window and press 'h' to add to harpoon:
tmux select-window -t 1  # Go to editor
# Press 'h' to add to harpoon
tmux select-window -t 2  # Go to server
# Press 'h' to add to harpoon
# ... and so on

# 3. Now from anywhere, press 'H' to quickly jump between these windows
# Your harpoon list will show:
# 1. myproject:1 (editor)
# 2. myproject:2 (server)
# 3. myproject:3 (tests)
# 4. myproject:4 (logs)
```

### Multi-Project Workflow

```bash
# Project A
tmux new-session -s "webapp"
tmux new-window -n "frontend"
tmux new-window -n "backend"
# Add both to harpoon with 'h'

# Project B
tmux new-session -s "mobile"
tmux new-window -n "ios"
tmux new-window -n "android"
# Add both to harpoon with 'h'

# Now your harpoon contains windows from multiple projects:
# 1. webapp:1 (frontend)
# 2. webapp:2 (backend)
# 3. mobile:1 (ios)
# 4. mobile:2 (android)

# Access any window instantly with 'H' regardless of current session!
```

### Integration Examples

#### With Tmuxifier

Create session layouts in `~/.tmuxifier/layouts/`:

```bash
# ~/.tmuxifier/layouts/project.session.sh
session_name "myproject"
new_window "editor"
new_window "server"
new_window "logs"
```

#### With Zoxide

Your frequently visited directories automatically appear:

```bash
# Visit directories to build zoxide database
z ~/projects/awesome-app
z ~/dotfiles
z ~/documents/notes
```

#### Advanced Workflow Integration

```bash
# Custom key bindings for different workflows
set -g @omnimux-key "s"                     # Sessions with 's'
set -g @omnimux-harpoon-key "a"             # Harpoon with 'a'
set -g @omnimux-harpoon-add-key "A"         # Add to harpoon with 'A'

# Additional custom bindings
bind-key "p" display-popup -E "cd ~/projects && find . -type d -name .git | head -10 | xargs dirname"
```

## Troubleshooting 🔧

### Common Issues

**"This script must be run inside a tmux session"**

- Ensure you're running the script from within an active tmux session

**"fzf is not installed"**

- Install fzf: `brew install fzf` (macOS) or `apt install fzf` (Ubuntu)

**Key binding not working**

- Make sure you've installed the plugin via TPM (`prefix + I`)
- Try reloading tmux config: `tmux source-file ~/.tmux.conf`
- Check if your key conflicts with other bindings

**Harpoon entries not persisting**

- Check if `~/.tmux-harpoon-list` file exists and is writable
- Verify file permissions: `ls -la ~/.tmux-harpoon-list`

**Harpoon shows "invalid" entries**

- Use `Ctrl+X` in the Harpoon interface to clean up invalid entries
- Or manually edit `~/.tmux-harpoon-list` to remove problematic lines

**Preview not working**

- Check that preview is enabled: `tmux show-option -g @omnimux-preview-enabled`
- For Harpoon: `tmux show-option -g @harpoon-preview-enabled`
- Ensure required commands are available (ls, ps, git)

**Colors not displaying correctly**

- Ensure your terminal supports 256 colors or true color
- Check if your tmux configuration supports color

**Tmuxifier sessions not appearing**

- Verify tmuxifier installation and layout directory
- Check `TMUXIFIER_LAYOUT_PATH` environment variable

**Zoxide paths not showing**

- Install zoxide and ensure it's in your PATH
- Build the zoxide database by visiting directories with `z`

### Debug Mode

To troubleshoot issues, you can add debug output:

```bash
# Temporarily add to the script
set -x  # Enable debug mode
# ... rest of script
set +x  # Disable debug mode
```

### Harpoon File Location

The harpoon bookmarks are stored in `~/.tmux-harpoon-list`. You can:

- View entries: `cat ~/.tmux-harpoon-list`
- Manually edit: `vim ~/.tmux-harpoon-list`
- Clear all: `> ~/.tmux-harpoon-list`
- Backup: `cp ~/.tmux-harpoon-list ~/.tmux-harpoon-list.backup`

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly in different tmux environments
5. Submit a pull request

### Feature Ideas

- Integration with other terminal tools
- Custom bookmark categories
- Shared harpoon lists across team members
- Session templates with pre-configured harpoons
- Keyboard shortcuts customization UI

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- **tmux** - The amazing terminal multiplexer
- **fzf** - Fantastic fuzzy finder that makes this tool possible
- **tmuxifier** - Excellent tmux session management
- **zoxide** - Smart directory navigation
- **Neovim Harpoon** - Inspiration for the bookmark navigation feature
- The tmux and terminal communities for inspiration

---

**Happy terminal navigation! 🚀**
