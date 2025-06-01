# Termonaut 🚀

A powerful, interactive tmux session manager that brings together tmux, tmuxifier, zoxide, and fzf for a seamless terminal workflow experience.

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
   set -g @plugin 'VenkatRaman3103/Termonaut_Across_the_Tmux_Verse'
   ```

2. **Install the plugin:**
   Press `prefix + I` (default: `Ctrl-b + I`) to install the plugin via TPM.

3. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

The default key binding `<prefix>v` will be automatically configured.

### Option 2: Manual Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/VenkatRaman3103/Termonaut_Across_the_Tmux_Verse.git ~/.tmux/plugins/termonaut
   ```

2. **Add to your `~/.tmux.conf`:**

   ```bash
   # Source termonaut plugin
   run-shell ~/.tmux/plugins/termonaut/termonaut.tmux
   ```

3. **Reload tmux configuration:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### Option 3: Standalone Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/VenkatRaman3103/Termonaut_Across_the_Tmux_Verse.git
   cd Termonaut_Across_the_Tmux_Verse
   ```

2. **Make the script executable:**

   ```bash
   chmod +x script.sh
   ```

3. **Add to your PATH (optional):**

   ```bash
   # Add to your ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/Termonaut_Across_the_Tmux_Verse"
   ```

4. **Set up tmux key binding manually:**
   ```bash
   # Add to your ~/.tmux.conf
   bind-key v run-shell 'path/to/script.sh'
   ```

## Usage 🎯

### Basic Usage

**Default Key Binding**: Press `<prefix>v` from within any tmux session to launch Termonaut.

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

Termonaut supports two display modes:

### Popup Mode (Default)

- Opens Termonaut in a tmux popup overlay
- Non-intrusive and quick to access
- Customizable size and border colors
- Perfect for quick session switching

### Window Mode

- Opens Termonaut in a new tmux window
- Provides more space for complex operations
- Useful when working with many sessions
- Can be easily navigated back to

```bash
# Switch to window mode
set -g @termonaut-display-mode "window"
```

## Complete Configuration Reference ⚙️

### Basic Setup Options

| Option                     | Default     | Description                       |
| -------------------------- | ----------- | --------------------------------- |
| `@termonaut-key`           | `"v"`       | Key binding to launch Termonaut   |
| `@termonaut-display-mode`  | `"popup"`   | Display mode: `popup` or `window` |
| `@termonaut-window-width`  | `"100%"`    | Popup window width                |
| `@termonaut-window-height` | `"100%"`    | Popup window height               |
| `@termonaut-border-fg`     | `"#0c0c0c"` | Popup border foreground color     |
| `@termonaut-border-bg`     | `"#0c0c0c"` | Popup border background color     |

### Visual Appearance Colors

| Option                   | Default     | Description                   |
| ------------------------ | ----------- | ----------------------------- |
| `@termonaut-active-bg`   | `"#444444"` | Active selection background   |
| `@termonaut-active-fg`   | `"#ffffff"` | Active selection foreground   |
| `@termonaut-inactive-bg` | `"#222222"` | Inactive selection background |
| `@termonaut-inactive-fg` | `"#777777"` | Inactive selection foreground |

### Source Type Colors

| Option                            | Default     | Description                    |
| --------------------------------- | ----------- | ------------------------------ |
| `@termonaut-tmuxifier-mark-color` | `"#333333"` | Tmuxifier mark color           |
| `@termonaut-zoxide-mark-color`    | `"#333333"` | Zoxide mark color              |
| `@termonaut-find-mark-color`      | `"#333333"` | Find mark color                |
| `@termonaut-tmux-color`           | `"#333333"` | Tmux session color             |
| `@termonaut-tmux-mark-color`      | `"#333333"` | Tmux mark color                |
| `@termonaut-active-session-color` | `"#333333"` | Active session indicator color |

### Content Colors

| Option                               | Default     | Description                  |
| ------------------------------------ | ----------- | ---------------------------- |
| `@termonaut-tmux-session-color`      | `"#ffffff"` | Tmux session name color      |
| `@termonaut-tmuxifier-session-color` | `"#87ceeb"` | Tmuxifier session name color |
| `@termonaut-zoxide-path-color`       | `"#90ee90"` | Zoxide path color            |
| `@termonaut-find-path-color`         | `"#dda0dd"` | Find path color              |

### FZF Configuration

| Option                          | Default        | Description              |
| ------------------------------- | -------------- | ------------------------ |
| `@termonaut-fzf-height`         | `"100%"`       | FZF interface height     |
| `@termonaut-fzf-border`         | `"none"`       | FZF border style         |
| `@termonaut-fzf-layout`         | `"no-reverse"` | Main FZF layout          |
| `@termonaut-fzf-window-layout`  | `"reverse"`    | Window selection layout  |
| `@termonaut-fzf-prompt`         | `"> "`         | Main interface prompt    |
| `@termonaut-fzf-window-prompt`  | `"> "`         | Window selection prompt  |
| `@termonaut-fzf-pointer`        | `"▶"`         | Main interface pointer   |
| `@termonaut-fzf-window-pointer` | `"▶"`         | Window selection pointer |

### Preview Settings

| Option                                   | Default        | Description                         |
| ---------------------------------------- | -------------- | ----------------------------------- |
| `@termonaut-preview-enabled`             | `"false"`      | Enable/disable preview pane         |
| `@termonaut-fzf-preview-position`        | `"bottom:60%"` | Preview position for main interface |
| `@termonaut-fzf-preview-window-position` | `"right:75%"`  | Preview position for windows        |

### Path & Search Settings

| Option                        | Default   | Description                    |
| ----------------------------- | --------- | ------------------------------ |
| `@termonaut-max-zoxide-paths` | `"20"`    | Maximum zoxide paths to show   |
| `@termonaut-max-find-paths`   | `"15"`    | Maximum find results to show   |
| `@termonaut-find-base-dir`    | `"$HOME"` | Base directory for find search |
| `@termonaut-find-max-depth`   | `"3"`     | Maximum depth for find search  |
| `@termonaut-find-min-depth`   | `"1"`     | Minimum depth for find search  |

### Display & Content Settings

| Option                             | Default            | Description                            |
| ---------------------------------- | ------------------ | -------------------------------------- |
| `@termonaut-ls-command`            | `"ls -la"`         | Command for directory listings         |
| `@termonaut-show-process-count`    | `"3"`              | Number of processes to show in preview |
| `@termonaut-show-preview-lines`    | `"15"`             | Lines to show in session preview       |
| `@termonaut-show-ls-lines`         | `"20"`             | Lines to show in directory listings    |
| `@termonaut-show-git-status-lines` | `"10"`             | Lines to show in git status            |
| `@termonaut-editor`                | `"${EDITOR:-vim}"` | Editor for tmuxifier files             |

## Example Configuration 📝

Here's a complete example configuration showing all available options:

```bash
# ~/.tmux.conf

# Install termonaut via TPM
set -g @plugin 'VenkatRaman3103/Termonaut_Across_the_Tmux_Verse'

# === Basic Setup ===
set -g @termonaut-key "s"                    # Change key binding from v to s
set -g @termonaut-display-mode "popup"       # Use popup mode (default)
set -g @termonaut-window-width "90%"         # Popup width
set -g @termonaut-window-height "85%"        # Popup height
set -g @termonaut-border-fg "#ff6b6b"        # Red border foreground
set -g @termonaut-border-bg "#2d3748"        # Dark border background

# === Visual Appearance ===
set -g @termonaut-active-bg "#2d3748"        # Dark blue active background
set -g @termonaut-active-fg "#e2e8f0"        # Light gray active foreground
set -g @termonaut-inactive-bg "#1a202c"      # Darker inactive background
set -g @termonaut-inactive-fg "#718096"      # Medium gray inactive foreground

# === Source Type Mark Colors ===
set -g @termonaut-tmuxifier-mark-color "#4299e1"  # Blue for tmuxifier
set -g @termonaut-zoxide-mark-color "#ed8936"     # Orange for zoxide
set -g @termonaut-find-mark-color "#48bb78"       # Green for find
set -g @termonaut-tmux-mark-color "#9f7aea"       # Purple for tmux
set -g @termonaut-active-session-color "#f56565"  # Red for active session

# === Content Colors ===
set -g @termonaut-tmux-session-color "#ffffff"     # White tmux sessions
set -g @termonaut-tmuxifier-session-color "#87ceeb" # Sky blue tmuxifier
set -g @termonaut-zoxide-path-color "#90ee90"      # Light green zoxide paths
set -g @termonaut-find-path-color "#dda0dd"        # Plum find paths

# === FZF Interface ===
set -g @termonaut-fzf-height "100%"          # Full height
set -g @termonaut-fzf-border "rounded"       # Rounded borders
set -g @termonaut-fzf-layout "no-reverse"    # Normal layout
set -g @termonaut-fzf-window-layout "reverse" # Reverse for windows
set -g @termonaut-fzf-prompt "🚀 "          # Rocket emoji prompt
set -g @termonaut-fzf-window-prompt "📋 "    # Clipboard emoji for windows
set -g @termonaut-fzf-pointer "→"           # Arrow pointer
set -g @termonaut-fzf-window-pointer "▸"     # Different arrow for windows

# === Preview Settings ===
set -g @termonaut-preview-enabled "true"     # Enable preview
set -g @termonaut-fzf-preview-position "right:60%" # Preview on right
set -g @termonaut-fzf-preview-window-position "bottom:50%" # Bottom for windows

# === Path & Search ===
set -g @termonaut-max-zoxide-paths "25"      # More zoxide paths
set -g @termonaut-max-find-paths "20"        # More find results
set -g @termonaut-find-base-dir "$HOME/projects" # Search in projects
set -g @termonaut-find-max-depth "4"         # Deeper search
set -g @termonaut-find-min-depth "2"         # Skip immediate subdirs

# === Display Settings ===
set -g @termonaut-ls-command "exa -la --color=always" # Use exa instead of ls
set -g @termonaut-show-process-count "5"      # Show more processes
set -g @termonaut-show-preview-lines "20"     # More preview lines
set -g @termonaut-show-ls-lines "25"          # More directory listing lines
set -g @termonaut-show-git-status-lines "15"  # More git status lines
set -g @termonaut-editor "nvim"               # Use neovim for editing
```

### Minimal Configuration

For a simple setup with just the essentials:

```bash
# ~/.tmux.conf

# Install termonaut
set -g @plugin 'VenkatRaman3103/Termonaut_Across_the_Tmux_Verse'

# Basic customization
set -g @termonaut-key "s"                    # Use 's' instead of 'v'
set -g @termonaut-preview-enabled "true"     # Enable preview
set -g @termonaut-display-mode "popup"       # Use popup mode
```

### Color Theme Examples

#### Dark Theme

```bash
set -g @termonaut-active-bg "#2d3748"
set -g @termonaut-active-fg "#e2e8f0"
set -g @termonaut-tmuxifier-mark-color "#4299e1"
set -g @termonaut-zoxide-mark-color "#ed8936"
set -g @termonaut-find-mark-color "#48bb78"
```

#### Light Theme

```bash
set -g @termonaut-active-bg "#f7fafc"
set -g @termonaut-active-fg "#1a202c"
set -g @termonaut-tmuxifier-mark-color "#3182ce"
set -g @termonaut-zoxide-mark-color "#d69e2e"
set -g @termonaut-find-mark-color "#38a169"
```

#### Cyberpunk Theme

```bash
set -g @termonaut-active-bg "#0d1117"
set -g @termonaut-active-fg "#00ff41"
set -g @termonaut-tmuxifier-mark-color "#ff0080"
set -g @termonaut-zoxide-mark-color "#00ffff"
set -g @termonaut-find-mark-color "#ffff00"
```

## How It Works 🔍

Termonaut aggregates different sources of sessions and paths:

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
set -g @termonaut-key "s"                    # Sessions
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

- Check that preview is enabled: `tmux show-option -g @termonaut-preview-enabled`
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
