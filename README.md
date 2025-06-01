# Omnimux 🚀

A powerful, interactive tmux session manager that brings together tmux, tmuxifier, zoxide, and fzf for a seamless terminal workflow experience.

![Screenshot 2025-06-01 235635](https://github.com/user-attachments/assets/556b7bc4-a477-4d9b-9185-2e7fa2720bd6)


https://github.com/user-attachments/assets/4860255b-97df-47f9-8e63-8fc5d29e041a


## Features ✨

- **Unified Session Management**: Browse and switch between active tmux sessions, tmuxifier layouts, zoxide paths, and find results in one interface
- **Interactive Preview**: Real-time preview of session content, running processes, directory contents, and git status
- **Smart Path Integration**: Automatically create sessions from frequently visited directories (zoxide) or discovered paths (find)
- **Window Management**: Navigate, rename, create, and delete windows within sessions
- **Tmuxifier Integration**: Load, edit, rename, and manage tmuxifier session layouts
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

The default key binding `J` will be automatically configured.

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

2. **Make the script executable:**

   ```bash
   chmod +x script.sh
   ```

3. **Add to your PATH (optional):**

   ```bash
   # Add to your ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/Omnimux"
   ```

4. **Set up tmux key binding manually:**
   ```bash
   # Add to your ~/.tmux.conf
   bind-key J run-shell 'path/to/script.sh'
   ```

## Usage 🎯

### Basic Usage

**Default Key Binding**: Press `J` from within any tmux session to launch Omnimux.

You can also run the script directly:

```bash
./script.sh
```

### Keyboard Shortcuts

#### Main Interface

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

#### Window Management

| Key      | Action                    |
| -------- | ------------------------- |
| `Enter`  | Switch to selected window |
| `Ctrl+R` | Rename selected window    |
| `Ctrl+D` | Delete selected window    |
| `Ctrl+N` | Create new window         |
| `Escape` | Return to sessions        |

## Display Modes 🖥️

Omnimux supports two display modes:

### Popup Mode (Default)

- Opens Omnimux in a tmux popup overlay
- Non-intrusive and quick to access
- Customizable size and border colors
- Perfect for quick session switching

### Window Mode

- Opens Omnimux in a new tmux window
- Provides more space for complex operations
- Useful when working with many sessions
- Can be easily navigated back to

```bash
# Switch to window mode
set -g @omnimux-display-mode "window"
```

## Complete Configuration Reference ⚙️

### Basic Setup Options

| Option                   | Default     | Description                       |
| ------------------------ | ----------- | --------------------------------- |
| `@omnimux-key`           | `"J"`       | Key binding to launch Omnimux     |
| `@omnimux-display-mode`  | `"popup"`   | Display mode: `popup` or `window` |
| `@omnimux-window-width`  | `"100%"`    | Popup window width                |
| `@omnimux-window-height` | `"100%"`    | Popup window height               |
| `@omnimux-border-fg`     | `"#0c0c0c"` | Popup border foreground color     |
| `@omnimux-border-bg`     | `"#0c0c0c"` | Popup border background color     |

### Visual Appearance Colors

| Option                 | Default     | Description                   |
| ---------------------- | ----------- | ----------------------------- |
| `@omnimux-active-bg`   | `"#444444"` | Active selection background   |
| `@omnimux-active-fg`   | `"#ffffff"` | Active selection foreground   |
| `@omnimux-inactive-bg` | `"#222222"` | Inactive selection background |
| `@omnimux-inactive-fg` | `"#777777"` | Inactive selection foreground |

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

Here's a complete example configuration showing all available options:

```bash
# ~/.tmux.conf

# Install omnimux via TPM
set -g @plugin 'VenkatRaman3103/Omnimux'

# === Basic Setup ===
set -g @omnimux-key "s"                    # Change key binding from J to s
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
set -g @omnimux-key "s"                    # Use 's' instead of 'J'
set -g @omnimux-preview-enabled "true"     # Enable preview
set -g @omnimux-display-mode "popup"       # Use popup mode
```

### Color Theme Examples

#### Dark Theme

```bash
set -g @omnimux-active-bg "#2d3748"
set -g @omnimux-active-fg "#e2e8f0"
set -g @omnimux-tmuxifier-mark-color "#4299e1"
set -g @omnimux-zoxide-mark-color "#ed8936"
set -g @omnimux-find-mark-color "#48bb78"
```

#### Light Theme

```bash
set -g @omnimux-active-bg "#f7fafc"
set -g @omnimux-active-fg "#1a202c"
set -g @omnimux-tmuxifier-mark-color "#3182ce"
set -g @omnimux-zoxide-mark-color "#d69e2e"
set -g @omnimux-find-mark-color "#38a169"
```

#### Cyberpunk Theme

```bash
set -g @omnimux-active-bg "#0d1117"
set -g @omnimux-active-fg "#00ff41"
set -g @omnimux-tmuxifier-mark-color "#ff0080"
set -g @omnimux-zoxide-mark-color "#00ffff"
set -g @omnimux-find-mark-color "#ffff00"
```

## How It Works 🔍

Omnimux aggregates different sources of sessions and paths:

1. **Active Tmux Sessions** - Currently running tmux sessions (with active session prioritized)
2. **Tmuxifier Layouts** - Predefined session templates (filtered to exclude active ones)
3. **Zoxide Paths** - Frequently visited directories from your zoxide database
4. **Find Results** - Directories discovered through filesystem search

Each source is color-coded and labeled for easy identification. The preview pane shows relevant information like session content, directory listings, git status, and running processes.

## Integration Examples 🔗

### With Tmuxifier

Create session layouts in `~/.tmuxifier/layouts/`:

```bash
# ~/.tmuxifier/layouts/project.session.sh
session_name "myproject"
new_window "editor"
new_window "server"
new_window "logs"
```

### With Zoxide

Your frequently visited directories automatically appear:

```bash
# Visit directories to build zoxide database
z ~/projects/awesome-app
z ~/dotfiles
z ~/documents/notes
```

### Advanced Workflow Integration

```bash
# Custom key bindings for different workflows
set -g @omnimux-key "s"                    # Sessions
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

**Preview not working**

- Check that preview is enabled: `tmux show-option -g @omnimux-preview-enabled`
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

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly in different tmux environments
5. Submit a pull request

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- **tmux** - The amazing terminal multiplexer
- **fzf** - Fantastic fuzzy finder that makes this tool possible
- **tmuxifier** - Excellent tmux session management
- **zoxide** - Smart directory navigation
- The tmux and terminal communities for inspiration

---

**Happy terminal navigation! 🚀**
