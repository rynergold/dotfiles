# Developer Keybindings Guide (Ghostty, Tmux & LazyVim)

A fast, terminal-native daily reference for Ghostty terminal, Tmux multiplexing, Neovim editing, and extensible language tooling.

---

## Hierarchy

```text
┌────────────────────────────────────────────────────────┐
│ 🖥️  1. GHOSTTY (Terminal Emulator)                     │
│  ┌──────────────────────────────────────────────────┐  │
│  │ ⚙️  2. TMUX (Workspace & Multiplexer)            │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │ 📄  3. NEOVIM (Editor & Universal Tooling) │  │  │
│  │  │  ┌──────────────────────────────────────┐  │  │  │
│  │  │  │ 🛠️  4. LANGUAGE & LSP (Extensible)   │  │  │  │
│  │  │  └──────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

> [!TIP] Action & Context Legend
> **Action Type**: **`N:`** Navigation · **`E:`** Editing · **`R:`** Resizing / Zoom · **`W:`** Workspace / Lifecycle  
> **Multi-Context (`C`)**: 👻 Ghostty Shell · `Tmux` Tmux Multiplexer · ✏️ Code Editor

---

## 1. Ghostty (Terminal Host)

### Terminal Controls & Shortcuts

| Keybinding            | Action                                                                         |
|:----------------------|:-------------------------------------------------------------------------------|
| `Option + \``         | **W:** Toggle Ghostty dropdown terminal visibility anywhere in macOS            |
| `Cmd + =` / `Cmd + -` | **R:** Increase / decrease terminal font size                                  |
| `Cmd + 0`             | **R:** Reset font size to default (14pt)                                       |
| `Cmd + Shift + ,`     | **W:** Open Ghostty configuration file                                         |
| `Cmd + c` / `Cmd + v` | **E:** Native macOS clipboard copy and paste                                   |
| `Ctrl + r`            | **N:** Fuzzy search shell command history via FZF                              |
| `Ctrl + f` or `tms`   | **N:** Launch tmux-sessionizer repo switcher from prompt                       |
| `Ctrl + Q`            | **W:** Quit Ghostty window (background Tmux sessions remain alive in RAM)     |

---

## 2. Tmux (Workspace & Multiplexer)

### Tmux Sessions (Isolated Workspaces)

| Keybinding          | Action                                                                    | C    |
|:--------------------|:--------------------------------------------------------------------------|:-----|
| `Ctrl-b N`          | **W:** Create new named session on the fly (prompts for name and switches)| Tmux |
| `Ctrl-b $`          | **W:** Rename active session (opens prompt pre-filled with current name)  | Tmux |
| `Ctrl-b f` / `Ctrl-b s` | **N:** Switcher: open sessions, their windows, and saved projects in one list (`tmux-sessionizer`) | Tmux |
| `Ctrl-b S`          | **N:** Classic tmux tree view (`choose-tree` fallback)                              | Tmux |
| `Ctrl-b (` / `)`        | **N:** Instant jump to previous / next active session                     | Tmux |
| `Ctrl-f` or `tms`       | **N:** Launch project switcher from shell prompt                          | 👻   |
| `<space>fp`             | **N:** Project switcher popup from inside Neovim                          | ✏️   |
| `Enter` (in switcher)   | **N:** Jump to the session / window, or create the session for a saved project |
| `Ctrl-a` (in switcher)  | **N:** Save the current folder to the project list (`~/.config/tmux-projects`) |
| `Ctrl-x` (in switcher)  | **N:** Kill the highlighted session / window, or remove a saved project |
| `Ctrl-b d`              | **W:** Detach / minimize session (leaves editor & background tests running in RAM)   | Tmux |
| `Ctrl-b X`              | **W:** Kill active session (auto-switches to next open session; prompts `y/n`)       | Tmux |

### Tmux Windows (Tabs within Current Project)

| Keybinding                     | Action                                                                              |
| `Ctrl-b c`                     | **W:** Create a new window tab (inherits current pane's working directory)           |
| `Ctrl-b 1` .. `9`              | **N:** Jump directly to window tab 1 .. 9                                           |
| `Ctrl-b n`                     | **N:** Go to next window tab (`n` = next)                                           |
| `Ctrl-b p`                     | **N:** Go to previous window tab (`p` = previous)                                   |
| `Ctrl-b l`                     | **N:** Toggle back-and-forth between last two active tabs (like Alt-Tab)            |
| `Ctrl-b ,`                     | **W:** Rename current window tab                                                    |
| `Ctrl-b &`                     | **W:** Close / kill current window tab and all its splits at once (prompts `y/n`)   |
| `Ctrl-b :` `move-window -t S:` | **W:** Move current tab into another session `S` (e.g. `move-window -t workbench:`)  |

### Tmux Terminal Panes (Splits)

| Keybinding          | Action                                                                    |
|:--------------------|:--------------------------------------------------------------------------|
| `Ctrl-b %`          | **W:** Split pane vertically to the right (Side-by-side in current folder)|
| `Ctrl-b "`          | **W:** Split pane horizontally below (Stacked rows in current folder)     |
| `Ctrl-b <space>`    | **R:** Cycle layout presets (flip vertical columns ↔ horizontal rows, 50/50)|
| `Ctrl-b h/j/k/l`    | **N:** Move focus to pane on left / bottom / top / right                  |
| `Ctrl-b H/J/K/L`    | **R:** Resize pane width / height by 5 cells (smooth tap with 600ms repeat)|
| `Ctrl-b z`          | **R:** Zoom / fullscreen active pane toggle                               |
| Mouse Drag          | **R:** Click and drag pane border with trackpad                           |

### Tmux Scrollback & AI Message Navigation (Vim Mode)

| Keybinding          | Action                                                                    |
|:--------------------|:--------------------------------------------------------------------------|
| `Ctrl-b u`          | **1-Key Prompt Escape:** Enters copy mode & steps above prompt box (step back with `k`/`Ctrl-u`)|
| `Ctrl-b [`          | **N:** Enter Vi scrollback / copy mode without mouse                      |
| `[` / `]`           | **N:** (In copy mode) Jump backward / forward between prompt message turns |
| `k` / `j`           | **N:** (In copy mode) Scroll up / down line-by-line                       |
| `Ctrl-u` / `Ctrl-d` | **N:** (In copy mode) Half-page scroll up / down                          |
| `g` / `G`           | **N:** (In copy mode) Jump to top / bottom of scrollback history          |
| `/` or `?`          | **N:** (In copy mode) Search forward (`/`) or backward (`?`) for text      |
| `v` then `y` or `Enter` | **E:** (In copy mode) Visual select text $\rightarrow$ yank to macOS clipboard (`pbcopy`)|
| Mouse Drag              | **E:** (In copy mode) Highlight text with mouse $\rightarrow$ auto-yanks to clipboard    |
| `q`                     | **N:** Exit scroll mode and return immediately to active prompt typing                   |

### Mental Model: Panes vs Tabs vs Sessions

| Scope                | Analogy                       | What it is                    | How to Kill                               | When to use it                                              |
|:---------------------|:------------------------------|:------------------------------|:------------------------------------------|:------------------------------------------------------------|
| **Split (Pane)**     | Split Screen                  | Tiled views on same screen    | `Ctrl-b x` (kills active split only)      | Code + AI pair (Neovim on left, `agy` on right)             |
| **Window (Tab)**     | Browser Tab (`Ctrl-b c`)      | Full-screen tabs in 1 project | `Ctrl-b X` (kills tab & all its splits)   | Tab 1: Editor/AI pair · Tab 2: Test runner · Tab 3: Git     |
| **Session**          | Separate Window (`Ctrl-b N`)  | Isolated project workspace    | `Ctrl-b C-x` (kills entire workspace)     | Project A: `EasyTab` · Project B: `workbench` · Project C: `api` |

---

## 3. Neovim (Editor & Universal Tooling)

### File & Project Search

| Keybinding                   | Action                                                                        |
|:-----------------------------|:------------------------------------------------------------------------------|
| `<space><space>`             | Search for files by name or fuzzy path across the project                      |
| `<Ctrl-r>` / `<Ctrl-Enter>`  | In picker: Open selected file and **replace / close** current buffer          |
| `<space>sb`                  | Fuzzy search lines in current file (case-insensitive live filter, replaces `/`)|
| `<space>sB`                  | Fuzzy search lines across all currently open buffers                          |
| `<space>/` or `<space>sg`    | Search for text across all files in the project                                |
| `<space>fp`                  | Switch between projects and microservices in `~/Developer/Supply Chain Ops/`  |
| `Enter` (in switcher)   | **N:** Jump to the session / window, or create the session for a saved project |
| `Ctrl-a` (in switcher)  | **N:** Save the current folder to the project list (`~/.config/tmux-projects`) |
| `Ctrl-x` (in switcher)  | **N:** Kill the highlighted session / window, or remove a saved project |
| `<space>cb`                  | **C**ode **B**rowser: Open live synced Web Browser preview (opens browser side-by-side)|
| `<space>um`                  | **U**I **M**arkdown: Toggle in-buffer rendered view (tables, headings, icons) on/off   |
| `<space>uc`                  | **U**I **C**onceal: Toggle Markdown conceal on/off (show/hide raw syntax markers)      |
### File Explorer (CRUD)

| Operation  | Key        | Action                                                         |
|:-----------|:-----------|:---------------------------------------------------------------|
| **C**reate | `a`        | Create a new file (add `/` at the end to create a folder)      |
| **R**ead   | `<CR>`     | Open the selected file or folder                               |
| **U**pdate | `r`        | Rename or move the file, updating references across project    |
| **D**elete | `d`        | Delete the selected file or folder                             |
| Navigate   | `-` or `u` | Navigate up to the parent directory                            |
| Drawer     | `<space>e` | Open or close the file explorer sidebar                         |

### Window Splits (Create, Zoom & Close)

| Keybinding                     | Action                                                         |
|:-------------------------------|:---------------------------------------------------------------|
| `<space>w\|` (Pipe: `Shift+\`) | Split active window vertically to the right                    |
| `<space>w-`                    | Split active window horizontally below                         |
| `:vs <file>`                   | Open file in a vertical split to the right                     |
| `:leftabove vs <file>`         | Open file in a vertical split to the left                      |
| `<space>vf`                    | Open file under cursor in a vertical split to the right        |
| `<space>wm`                    | Toggle zoom / maximize active split (fullscreen toggle)        |
| `<Ctrl-w>=`                    | Equalize width and height across all splits                    |
| `<space>wd` or `<Ctrl-w>c`     | Close / delete the active window split                         |
| `<space>wbd`                   | **Close active window split AND delete its buffer in one go**  |
| `<Ctrl-w>o`                    | Close all other splits (keep only this active window)          |

### Window Splits (Navigate, Move & Rearrange)

| Keybinding                     | Action                                            |
|:-------------------------------|:--------------------------------------------------|
| `<Ctrl-h>` / `<Ctrl-l>`        | Move cursor focus to window on left / right       |
| `<Ctrl-j>` / `<Ctrl-k>`        | Move cursor focus to window below / above         |
| `<Ctrl-w>p`                    | Jump back to previously focused window            |
| `<Ctrl-Left>` / `<Ctrl-Right>` | Decrease / increase active split width            |
| `<Ctrl-Up>` / `<Ctrl-Down>`    | Increase / decrease active split height           |
| `<Ctrl-w>>` / `<Ctrl-w><`      | Alternative: widen / shrink split width           |
| `:vertical resize 80`          | Snap split width to exact column width (e.g. 80)  |
| `<Ctrl-w>H` / `<Ctrl-w>L`      | Move active window to far left / far right        |
| `<Ctrl-w>K` / `<Ctrl-w>J`      | Move active window to top / bottom                |
| `<Ctrl-w>x`                    | Swap active window with next window               |
| `<Ctrl-w>r`                    | Rotate all split window positions clockwise       |

### Tabs (Workspace Pages)

| Keybinding                 | Action                                                         |
|:---------------------------|:---------------------------------------------------------------|
| `<space><tab><tab>`        | Create a completely new empty tab (`:tabnew`)                  |
| `<Ctrl-w>T`                | Break the active split out into its own full new tab           |
| `<space><tab>]` or `gt`    | Switch to the next tab                                         |
| `<space><tab>[` or `gT`    | Switch to the previous tab                                     |
| `<space><tab>d`            | Close the current tab (`:tabclose`)                            |
| `<space><tab>o`            | Close all other tabs (`:tabonly`)                              |
| `<space><tab>f` / `<tab>l` | Jump to the first / last tab                                   |

### Buffer Actions (Save, Close & Delete)

| Command                  | Action                                                               |
|:-------------------------|:---------------------------------------------------------------------|
| `:w` or `<Ctrl-s>`       | Save current buffer to disk (auto-formats when format-on-save is on) |
| `:wa`                    | Save all modified open buffers to disk (auto-formats all open)       |
| `[b` / `]b`              | Switch to the previous / next open buffer in tabline                 |
| `<space>bb`              | Toggle between current and last edited buffer                        |
| `<Ctrl-o>` / `<Ctrl-i>`  | Jump back / jump forward in navigation history (like IntelliJ Cmd [ / ]) |
| `<space>fb`              | Fuzzy search and switch between all open buffers                     |
| `<space>bd`              | Close buffer (keeps window split open)                               |
| `<space>wbd`             | **Close active window split AND delete its buffer in one go**         |
| `<space>bo`              | Close all other open buffers except the active one                   |
| `<space>fD` or `:Delete` | Permanently delete active file from disk and close its buffer        |
| `:q`                     | Close active window                                                  |
| `:qa`                    | Close all windows and exit Neovim                                    |
| `:wqa`                   | Save all modified files and exit Neovim                              |

### Indicators & Git State

| Indicator            | Meaning                                                                |
|:---------------------|:-----------------------------------------------------------------------|
| `•` (dot in top bar) | The buffer has unsaved modifications in memory (RAM)                   |
| Green buffer text    | New file that is not yet tracked by Git                                |
| Yellow buffer text   | Existing file on disk with uncommitted modifications                   |
| Blue buffer text     | File with staged changes ready to commit                               |
| Top bar concept      | The top bar displays open **Buffers** (files in RAM), not Vim tabs.    |
| Saving behavior      | Writing to disk (`:w`) updates physical file. Does not git add/commit. |

### Universal Debugging (DAP)

| Keybinding                              | Action                                                                         |
|:----------------------------------------|:-------------------------------------------------------------------------------|
| `<space>db`                             | Set or clear a breakpoint on current line                                      |
| `<space>dc`                             | Attach to running process (`Debug (Attach) - Remote` on port 5005)             |
| `<space>di` / `<space>dO` / `<space>do` | Step into / step over / step out of current function                           |
| `<space>du`                             | Toggle debugger UI panel (watches, variables, stack frames)                    |
| `<space>dq`                             | Terminate debug session / stop running application                             |

### Universal Diagnostics (Trouble & Inline)

| Keybinding              | Action                                                       |
|:------------------------|:-------------------------------------------------------------|
| `]d` / `[d`             | Jump to next / previous compiler error or warning            |
| `]e` / `[e`             | Jump specifically to next / previous Error (skips warnings) |
| `<space>cd`             | Open full error message in a floating popup card             |
| `<space>ca`             | Show code actions (auto-imports, annotations, quick fixes)   |
| `<space>xx`             | Open project-wide error list in bottom panel (Trouble)       |
| `<space>xX`             | Open error list for current file only                        |
| `]q` / `[q`             | Jump to next / previous error in list without focusing panel |
| `<Ctrl-j>` / `<Ctrl-k>` | Move cursor down into error panel or back up into code       |

### Universal Database, Git & Terminal

| Keybinding                | Action                                                             |
|:--------------------------|:-------------------------------------------------------------------|
| `<space>D`                | Open or close database sidebar (Dadbod UI)                         |
| `a` (in drawer)           | Add database connection string (e.g. `postgresql://...`)           |
| `<space>S` (in `.sql`)    | Run SQL query under cursor or visual selection                     |
| `<space>gg`               | Open LazyGit in a full terminal overlay                            |
| `<Ctrl-/>` or `<space>ft` | Toggle / hide terminal anchored at project root directory          |
| `<space>fT`               | Open terminal anchored in the current buffer's active folder       |
| `exit` or `<Ctrl-d>`      | Kill shell process and automatically close terminal window         |
| `<Esc><Esc>`              | Switch from terminal typing mode back to normal Vim mode           |
| `<space>uh`               | Toggle inline parameter hints on or off                            |
| `<Esc>`                   | Dismiss popups and clear search highlighting                       |
| `u` / `<Ctrl-r>`          | Undo / redo last edit                                              |
| `q`                       | Stop recording macro if `recording @q` appears in status line      |

### Inside the Buffer (Universal CRUD Text Motions)

#### C · Create & Insert

##### Words & Tokens
| Keybinding | Action                     | Scope / Example           |
|:-----------|:---------------------------|:--------------------------|
| `ysiw)`    | Wrap word in parentheses   | `item` becomes `(item)`   |
| `ysiw"`    | Wrap word in double quotes | `key` becomes `"key"`     |
| `ysiw}`    | Wrap word in curly braces  | `props` becomes `{props}` |

##### Blocks, Lines & Selections
| Keybinding | Action                                     | Scope / Example                                              |
|:-----------|:-------------------------------------------|:-------------------------------------------------------------|
| `yy`       | Yank entire line to macOS system clipboard | Copies full line to clipboard (ready for `Cmd+v` in any app) |
| `y` (v)    | Yank visual selection to macOS clipboard   | Copies highlighted text straight to macOS clipboard          |
| `S)` (v)   | Wrap visual selection in parentheses       | `x + y` becomes `(x + y)`                                    |
| `S"` (v)   | Wrap visual selection in double quotes     | `hello world` becomes `"hello world"`                        |
| `o` / `O`  | Insert a new line below / above the cursor | Enters insert mode on fresh line                             |
| `p` / `P`  | Paste clipboard text after / before cursor | Pastes copied words, lines, or blocks                        |

#### R · Read, Jump & Select

##### Identifiers & Navigation
| Keybinding              | Action                              | Scope / Example                                             |
|:------------------------|:------------------------------------|:------------------------------------------------------------|
| `gd`                    | Jump to definition                  | Takes you to where function, class, or variable is declared |
| `gr`                    | Find all references                 | Shows everywhere this symbol is used across codebase        |
| `K`                     | Show documentation and type details | Shows docstrings, type signatures, or error details         |
| `<Ctrl-o>` / `<Ctrl-i>` | Jump back / jump forward            | Retraces cursor position backward/forward across files      |
| `gI`                    | Jump to implementation              | Jumps to concrete class implementing an interface           |

##### Visual Selections (Text Objects)
| Motion        | Action                         | Scope / Example                                      |
|:--------------|:-------------------------------|:-----------------------------------------------------|
| `viw`         | Select word under cursor       | In `config.timeout`, highlights `config` only        |
| `viW`         | Select full token with symbols | In `config.timeout`, highlights full `config.timeout`|
| `vi(` / `vi"` | Select inside delimiters       | In `("active")`, highlights `active` without quotes  |
| `vaf`         | Select entire function         | Highlights function annotations, signature, and body |

#### U · Update & Change

##### Words & Symbols (`w` vs `W`)
| Keybinding  | Action                         | Scope / Example                                                 |
|:------------|:-------------------------------|:----------------------------------------------------------------|
| `ciw`       | Change word only               | In `config.timeout`, changes `config`, keeping `.timeout`       |
| `ciW`       | Change full token              | In `config.timeout`, replaces whole `config.timeout` expression |
| `caw`       | Change word and trailing space | Replaces word and cleans up adjacent spacing                    |
| `<space>cr` | Rename symbol across project   | Renames variable or method everywhere using LSP                 |

##### Blocks, Delimiters & Lines
| Keybinding    | Action                                | Scope / Example                                                  |
|:--------------|:--------------------------------------|:-----------------------------------------------------------------|
| `ci(` / `ci"` | Change inside parentheses or quotes   | Clears inside `("data")` into `("")` and enters insert mode      |
| `ci{` / `cif` | Change inside body                    | Clears method or block body keeping outer curly braces           |
| `cs"'`        | Change surrounding quotes             | Converts `"hello"` into `'hello'`                                |
| `cs)]`        | Change surrounding parentheses        | Converts `(count)` into `[count]`                                |
| `cc` or `S`   | Change entire line                    | Empties current line and indents to right level                  |
| `<space>cf`   | Reformat code according to repo style | Formats file or visual selection (Google Java Format / Spotless) |

#### D · Delete & Strip

##### Words & Symbols (`w` vs `W`)
| Motion | Action                                   | Scope / Example                                                   |
|:-------|:-----------------------------------------|:------------------------------------------------------------------|
| `daw`  | Delete word                              | In `@decorator`, deletes `decorator`, leaving `@` behind          |
| `daW`  | Delete full token with symbols & space   | In `@decorator`, deletes `@decorator` with `@` and trailing space |
| `diw`  | Delete word without trailing space       | In `config.timeout`, deletes `config`, leaving `.timeout`         |
| `diW`  | Delete full token without trailing space | In `config.timeout`, deletes `config.timeout` without eating space|

##### Blocks, Delimiters & Lines
| Motion        | Action                           | Scope / Example                                  |
|:--------------|:---------------------------------|:-------------------------------------------------|
| `di(` / `di"` | Delete inside brackets or quotes | In `("user")`, deletes `user`, leaving `("")`    |
| `di{` / `dif` | Delete inside function body      | Clears method implementation, keeping outer `{}` |
| `ds"`         | Strip double quotes              | Converts `"name"` into `name`                    |
| `ds)`         | Strip parentheses                | Converts `(count)` into `count`                  |
| `dd`          | Delete entire line               | Cuts current line into clipboard register        |
| `D`           | Delete to end of line            | Cuts from cursor to line end (`d$`)              |

---

## 4. Language & LSP (Extensible Stacks)

### Java & Spring Boot

#### Class & Test Navigation

| Keybinding                   | Action                                                                         |
|:-----------------------------|:-------------------------------------------------------------------------------|
| `<space>ta` or `<space>cgS`  | Switch back and forth between a Java class and its test file (or auto-create)  |
| `gd`                         | Jump to definition (links `@Value` keys directly to `application.yml`)         |

#### Running Applications & Tests

| Keybinding          | Action                                                                         |
|:--------------------|:-------------------------------------------------------------------------------|
| `<space>dc`         | Run `main()` class or Spring Boot app (auto-discovers main classes via JDTLS)  |
| `<Ctrl-/>`          | Toggle project terminal to run `./gradlew bootRun` or `./mvnw spring-boot:run` |
| `<space>tr`         | Run the `@Test` method under cursor                                            |
| `<space>tt`         | Run all unit tests in the current file                                         |
| `<space>tT`         | Pick a specific test method to run from a list                                 |
| `:JdtUpdateConfig`  | Reload Gradle / Maven dependencies and refresh classpath                       |

#### Java Refactorings (JDTLS)

| Keybinding       | Action                                                              |
|:-----------------|:--------------------------------------------------------------------|
| `<space>cxv`     | Extract variable from expression under cursor                       |
| `<space>cxc`     | Extract constant from value under cursor                            |
| `<space>cxm` (v) | Extract selected lines into a new method                            |
| `<space>cgs`     | Jump to super class implementation                                  |
| `<space>ca`      | Show code actions (generate constructors, getters/setters, imports) |
| `<space>co`      | Organize imports (removes unused imports and sorts them)              |
| `<space>uF`      | Turn automatic format on save on or off (`google-java-format`)        |

#### Code Formatting & Linters (Spotless)

| Command / Directive            | Action                                                                     |
|:-------------------------------|:---------------------------------------------------------------------------|
| `<space>cf`                    | Format active file (or visual selection) using `google-java-format`        |
| `<space>cF`                    | Format injected languages (embedded SQL, JSON, Markdown in file)           |
| `<space>uf`                    | Toggle auto-format on save for active buffer only                          |
| `<space>uF`                    | Toggle auto-format on save globally across all buffers                     |
| `:ConformInfo`                 | Inspect active formatters and linter engines for current buffer            |
| `:wa`                          | Save all open buffers (triggers auto-format on each when enabled)          |
| `./gradlew spotlessApply`      | Format **ALL** files across repo (Spotless + Google Java Format + imports) |
| `./gradlew spotlessCheck`      | Check whether any files violate formatting rules without editing them      |
| `git diff` / `<space>gd`       | Inspect formatting diffs applied by Spotless before committing             |
| `// spotless:off` / `on`       | Comments to selectively disable/enable Spotless on specific code blocks    |
| `ratchetFrom("origin/master")` | Spotless setting: formats only changed lines relative to master branch     |
