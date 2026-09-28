# Developer Keybindings Guide (Ghostty, Tmux & LazyVim)

A fast, terminal-native daily reference for Tmux multiplexing, Neovim editing, and Java/Spring development.

---

## Hierarchy

```text
┌─────────────────────────────────────────────────────────────────┐
│ 🖥️  1. Workspace & Layout (Tmux Projects, Panes & Splits)        │
│   ┌───────────────────────────────────────────────────────────┐ │
│   │ 📄  2. Code Editor (Buffer Lifecycle, File in RAM & Disk) │ │
│   │   ┌─────────────────────────────────────────────────────┐ │ │
│   │   │ 🛠️  3. Tooling & Ecosystem (LSP, Tests, Git)        │ │ │
│   │   │   ┌───────────────────────────────────────────────┐ │ │ │
│   │   │   │ ✏️  4. Inside the Buffer (CRUD Scopes)         │ │ │ │
│   │   │   └───────────────────────────────────────────────┘ │ │ │
│   │   └─────────────────────────────────────────────────────┘ │ │
│   └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

> [!TIP] Action & Context Legend
> **Action Type**: **`N:`** Navigation · **`E:`** Editing · **`R:`** Resizing / Zoom · **`W:`** Workspace / Lifecycle  
> **Multi-Context (`C`)**: 👻 Ghostty Shell · `Tmux` Tmux Multiplexer · ✏️ Code Editor

---

## 1. Workspace & Layout

### Tmux Terminal Panes

| Keybinding       | Action                                                         |
|:-----------------|:---------------------------------------------------------------|
| `Ctrl-b %`       | **W:** Split pane vertically to the right (Editor + Tests)     |
| `Ctrl-b "`       | **W:** Split pane horizontally below                           |
| `Ctrl-b h/j/k/l` | **N:** Move focus to pane on left / bottom / top / right       |
| `Ctrl-b H/J/K/L` | **R:** Resize pane width / height by 5 cells (tap repeatedly)  |
| `Ctrl-b z`       | **R:** Zoom / fullscreen active pane toggle                    |
| Mouse Drag       | **R:** Click and drag pane border with trackpad                |

### Tmux Projects & Sessions (tms)

| Keybinding          | Action                                                          | C    |
|:--------------------|:----------------------------------------------------------------|:-----|
| `Ctrl-f` or `tms`   | **N:** Fuzzy search & jump into any work repo or Eden notes     | 👻   |
| `<space>fp`         | **N:** Project switcher popup from inside the code editor       | ✏️   |
| `Ctrl-b f`          | **N:** Project switcher popup from inside any tmux session      | Tmux |
| `Tab` (in popup)    | **W:** Multi-select sessions (toggle select one or more)        | Tmux |
| `Ctrl-x` (in popup) | **W:** Kill highlighted or Tab-selected session(s) live in popup| Tmux |
| `Ctrl-b s`          | **N:** Interactive session tree list (navigate `j`/`k`, `x` kill)| Tmux |
| `Ctrl-b d`          | **W:** Detach session (leaves editor & background tests running)| Tmux |
| `Ctrl-b X`          | **W:** Kill active session (prompts confirmation `y/n`)         | Tmux |
| `:qa` then `exit`   | **W:** Quit Neovim and terminate active session completely      | ✏️   |

### File & Project Search

| Keybinding                   | Action                                                                        |
|:-----------------------------|:------------------------------------------------------------------------------|
| `<space><space>`             | Search for files by name or fuzzy path across the project                      |
| `<Ctrl-r>` / `<Ctrl-Enter>`  | In picker: Open selected file and **replace / close** current buffer          |
| `<space>/` or `<space>sg`    | Search for text across all files in the project                                |
| `<space>fp`                  | Switch between projects and microservices in `~/Developer/Supply Chain Ops/`  |
| `<space>fr`                  | Search and open a recently visited file across any project                     |
| `<space>fb`                  | Search and switch between currently open buffers                               |
| `<space>k`                   | Open this Keybindings Guide in a vertical split to the right                   |

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

### Splits vs Tabs vs Sessions

| Scope                | What it is                    | When to use it                                                 |
|:---------------------|:------------------------------|:---------------------------------------------------------------|
| **Buffer (Top Bar)** | File loaded into RAM          | Open files you are editing; cycled with `[b` / `]b`            |
| **Window Split**     | Tiled view within same screen | View 2+ files simultaneously (code + test, code + guide)       |
| **Tabpage**          | Full-screen layout page       | Separate visual workspaces within the same project             |
| **Terminal Tab**     | Separate Ghostty tab / tmux   | Completely separate projects (Work repo vs Notes vs Dotfiles)  |

---

## 2. Code Editor

### Buffer Actions (Save, Close & Delete)

| Command                  | Action                                                               |
|:-------------------------|:---------------------------------------------------------------------|
| `:w` or `<Ctrl-s>`       | Save current buffer to disk (auto-formats when format-on-save is on) |
| `:wa`                    | Save all modified open buffers to disk (auto-formats all open)       |
| `[b` / `]b`              | Switch to the previous / next open buffer in tabline                 |
| `<space>bb`              | Toggle between current and last edited buffer                        |
| `<Ctrl-o>` / `<Ctrl-i>`  | Jump back / jump forward in navigation history (like IntelliJ Cmd [ / ]) |
| `<space>fb`              | Fuzzy search and switch between all open buffers                     |
| `<space>bd`              | Close buffer (discards unsaved scratch files without saving)         |
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

---

## 3. Language & Tooling

### Java & Spring Boot

#### Running Applications & Tests

| Keybinding          | Action                                                                         |
|:--------------------|:-------------------------------------------------------------------------------|
| `<space>dc`         | Run `main()` class or Spring Boot app (auto-discovers main classes via JDTLS)  |
| `<Ctrl-/>`          | Toggle project terminal to run `./gradlew bootRun` or `./mvnw spring-boot:run` |
| `<space>tr`         | Run the `@Test` method under cursor                                            |
| `<space>tt`         | Run all unit tests in the current file                                         |
| `<space>tT`         | Pick a specific test method to run from a list                                 |
| `:JdtUpdateConfig`  | Reload Gradle / Maven dependencies and refresh classpath                       |

#### Debugging (DAP)

| Keybinding                              | Action                                                                         |
|:----------------------------------------|:-------------------------------------------------------------------------------|
| `<space>db`                             | Set or clear a breakpoint on current line                                      |
| `<space>dc`                             | Attach to running Spring Boot process (`Debug (Attach) - Remote` on port 5005) |
| `<space>di` / `<space>dO` / `<space>do` | Step into / step over / step out of current function                           |
| `<space>du`                             | Toggle debugger UI panel (watches, variables, stack frames)                    |
| `<space>dq`                             | Terminate debug session / stop running application                             |

#### Navigation & Environment

| Keybinding                   | Action                                                                         |
|:-----------------------------|:-------------------------------------------------------------------------------|
| `<space>ta` or `<space>cgS`  | Switch back and forth between a Java class and its test file (or auto-create)  |
| `gd`                         | Jump to definition (links `@Value` keys directly to `application.yml`)         |
| `<space>co`                  | Organize imports (removes unused imports and sorts them)                       |
| `<space>uF`                  | Turn automatic format on save on or off (`google-java-format`)                 |

#### Java Refactorings (JDTLS)

| Keybinding       | Action                                                              |
|:-----------------|:--------------------------------------------------------------------|
| `<space>cxv`     | Extract variable from expression under cursor                       |
| `<space>cxc`     | Extract constant from value under cursor                            |
| `<space>cxm` (v) | Extract selected lines into a new method                            |
| `<space>cgs`     | Jump to super class implementation                                  |
| `<space>ca`      | Show code actions (generate constructors, getters/setters, imports) |

#### Code Formatting (Buffer & Selection)

| Keybinding                                | Action                                                                |
|:------------------------------------------|:----------------------------------------------------------------------|
| `<space>cf`                               | Format active file (or visual selection) using `google-java-format`   |
| `<space>cF`                               | Format injected languages (embedded SQL, JSON, Markdown in file)      |
| `<space>uf`                               | Toggle auto-format on save for active buffer only                     |
| `<space>uF`                               | Toggle auto-format on save globally across all buffers                |
| `:ConformInfo`                            | Inspect active formatters and linter engines for current buffer       |
| `:wa`                                     | Save all open buffers (triggers auto-format on each when enabled)     |
| `:bufdo lua LazyVim.format({force=true})` | Force reformat across all currently open buffers in Neovim            |

#### Project-Wide Formatting (Spotless)

| Command / Directive            | Action                                                                     |
|:-------------------------------|:---------------------------------------------------------------------------|
| `./gradlew spotlessApply`      | Format **ALL** files across repo (Spotless + Google Java Format + imports) |
| `./gradlew spotlessCheck`      | Check whether any files violate formatting rules without editing them      |
| `git diff` / `<space>gd`       | Inspect formatting diffs applied by Spotless before committing             |
| `// spotless:off` / `on`       | Comments to selectively disable/enable Spotless on specific code blocks    |
| `ratchetFrom("origin/master")` | Spotless setting: formats only changed lines relative to master branch     |

---

## 4. Diagnostics & External Tools

### Diagnostics (Trouble & Inline)

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

### Database, Git & Terminal

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

---

## 5. Inside the Buffer (CRUD)

### C · Create & Insert

#### Words & Tokens
| Keybinding | Action                     | Scope / Example           |
|:-----------|:---------------------------|:--------------------------|
| `ysiw)`    | Wrap word in parentheses   | `item` becomes `(item)`   |
| `ysiw"`    | Wrap word in double quotes | `key` becomes `"key"`     |
| `ysiw}`    | Wrap word in curly braces  | `props` becomes `{props}` |

#### Blocks, Lines & Selections
| Keybinding | Action                                     | Scope / Example                       |
|:-----------|:-------------------------------------------|:--------------------------------------|
| `S)` (v)   | Wrap visual selection in parentheses       | `x + y` becomes `(x + y)`             |
| `S"` (v)   | Wrap visual selection in double quotes     | `hello world` becomes `"hello world"` |
| `o` / `O`  | Insert a new line below / above the cursor | Enters insert mode on fresh line      |
| `p` / `P`  | Paste clipboard text after / before cursor | Pastes copied words, lines, or blocks |

### R · Read, Jump & Select

#### Identifiers & Navigation
| Keybinding              | Action                              | Scope / Example                                             |
|:------------------------|:------------------------------------|:------------------------------------------------------------|
| `gd`                    | Jump to definition                  | Takes you to where function, class, or variable is declared |
| `gr`                    | Find all references                 | Shows everywhere this symbol is used across codebase        |
| `K`                     | Show documentation and type details | Shows docstrings, type signatures, or error details         |
| `<Ctrl-o>` / `<Ctrl-i>` | Jump back / jump forward            | Retraces cursor position backward/forward across files      |
| `gI`                    | Jump to implementation              | Jumps to concrete class implementing an interface           |

#### Visual Selections (Text Objects)
| Motion        | Action                         | Scope / Example                                      |
|:--------------|:-------------------------------|:-----------------------------------------------------|
| `viw`         | Select word under cursor       | In `config.timeout`, highlights `config` only        |
| `viW`         | Select full token with symbols | In `config.timeout`, highlights full `config.timeout`|
| `vi(` / `vi"` | Select inside delimiters       | In `("active")`, highlights `active` without quotes  |
| `vaf`         | Select entire function         | Highlights function annotations, signature, and body |

### U · Update & Change

#### Words & Symbols (`w` vs `W`)
| Keybinding  | Action                         | Scope / Example                                                 |
|:------------|:-------------------------------|:----------------------------------------------------------------|
| `ciw`       | Change word only               | In `config.timeout`, changes `config`, keeping `.timeout`       |
| `ciW`       | Change full token              | In `config.timeout`, replaces whole `config.timeout` expression |
| `caw`       | Change word and trailing space | Replaces word and cleans up adjacent spacing                    |
| `<space>cr` | Rename symbol across project   | Renames variable or method everywhere using LSP                 |

#### Blocks, Delimiters & Lines
| Keybinding    | Action                                | Scope / Example                                                  |
|:--------------|:--------------------------------------|:-----------------------------------------------------------------|
| `ci(` / `ci"` | Change inside parentheses or quotes   | Clears inside `("data")` into `("")` and enters insert mode      |
| `ci{` / `cif` | Change inside body                    | Clears method or block body keeping outer curly braces           |
| `cs"'`        | Change surrounding quotes             | Converts `"hello"` into `'hello'`                                |
| `cs)]`        | Change surrounding parentheses        | Converts `(count)` into `[count]`                                |
| `cc` or `S`   | Change entire line                    | Empties current line and indents to right level                  |
| `<space>cf`   | Reformat code according to repo style | Formats file or visual selection (Google Java Format / Spotless) |

### D · Delete & Strip

#### Words & Symbols (`w` vs `W`)
| Motion | Action                                   | Scope / Example                                                   |
|:-------|:-----------------------------------------|:------------------------------------------------------------------|
| `daw`  | Delete word                              | In `@decorator`, deletes `decorator`, leaving `@` behind          |
| `daW`  | Delete full token with symbols & space   | In `@decorator`, deletes `@decorator` with `@` and trailing space |
| `diw`  | Delete word without trailing space       | In `config.timeout`, deletes `config`, leaving `.timeout`         |
| `diW`  | Delete full token without trailing space | In `config.timeout`, deletes `config.timeout` without eating space|

#### Blocks, Delimiters & Lines
| Motion        | Action                           | Scope / Example                                  |
|:--------------|:---------------------------------|:-------------------------------------------------|
| `di(` / `di"` | Delete inside brackets or quotes | In `("user")`, deletes `user`, leaving `("")`    |
| `di{` / `dif` | Delete inside function body      | Clears method implementation, keeping outer `{}` |
| `ds"`         | Strip double quotes              | Converts `"name"` into `name`                    |
| `ds)`         | Strip parentheses                | Converts `(count)` into `count`                  |
| `dd`          | Delete entire line               | Cuts current line into clipboard register        |
| `D`           | Delete to end of line            | Cuts from cursor to line end (`d$`)              |
