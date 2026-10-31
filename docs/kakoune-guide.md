# Kakoune quick guide

A cheat sheet for this config, written for someone coming from Helix. Kakoune
and Helix share the same idea, **select first, then act**, but many keys differ.

In Kakoune itself: `:doc keys` lists every key, and pausing after `g`,
`<space>`, `[` or `<a-i>` shows a menu of what can follow.

## How to learn with this guide

Don't try to learn every table at once. Go in stages, and do the
[practice](#practice) exercises at the end of each one:

1. **Day 1–2: survive.** [The core idea](#the-core-idea), [Modes](#modes),
   [Movement](#movement), `d` `c` `y` `p` `u` from [Editing](#editing), `:w` `:q`.
   Read [Coming from Helix](#coming-from-helix): most of your Helix habits work.
2. **Day 3–5: select like Kakoune.** `x` (and `xxx`), objects (`<a-i>` / `<a-a>`),
   `f` / `t`, search. Use `<space>f`, `<space>s` (jump to a procedure by name),
   `gw` (jump to a word on screen) and `gd` instead of scrolling.
3. **Week 2: multiple selections.** `%`, `s`, `S`, `<a-s>`, `<a-k>`, `&`, `C`.
   This is where Kakoune pays off: [Recipes](#recipes-for-fortran) are all built
   from these keys.
4. **Later:** macros, registers, `|` (pipe through shell), surround, sessions.

Tip: when a key does something surprising, press `<a-u>` (undo the selection
change) or `u` (undo the edit) and try again. Nothing is lost.

## The core idea

Every command acts on the current selection(s). Moving the cursor *selects* the
text moved over; you then act on it (`d` delete, `c` change, `y` yank, ...).

- **lowercase** key: move and select
- **Shift** (uppercase) key: *extend* the current selection instead
- **Alt** key: usually the "other direction" or "inverse" of the plain key

### Reading a key sequence

Read keys left to right as a sentence: *select something*, *narrow it*,
*act on it*.

| Keys | Read as |
|---|---|
| `wd` | select the next word, delete it |
| `xxxd` | select this line, add the next 2, delete all 3 |
| `<a-i>(c` | select inside the parentheses, change it |
| `%sfoo<ret>cbar<esc>` | select the whole file, select every `foo`, change them all to `bar` |
| `%<a-s><a-k>print<ret>d` | select the file, split into one per line, keep those with `print`, delete |

Because the selection is always visible *before* you act, you can check it and
fix it (`<a-u>`, `,`, `<a-k>`) before pressing `d` or `c`.

### Coming from Helix

Most keys are the same (`w` `b` `e` `f` `t` `x` `%` `s` `S` `C` `,` `;` `&` `|`
`gd` `gn` `gp` `u` `U` `Q` `q`). The ones that differ:

| Helix | Kakoune (this config) | Note |
|---|---|---|
| `v` (select mode) | hold **Shift** | `W`, `J`, `L` ... extend instead of move |
| `J` | `<a-j>` | `J` extends the selection down |
| `K` / `<a-K>` | `<a-k>` / `<a-K>` | keep / drop selections matching a regex |
| `N` | `<a-n>` | `N` **adds** the next match as a new selection |
| `?` | `<a-/>` | `?` extends the selection to the next match |
| `~` (switch case) | `<a-`>` | Kakoune's `~` is upper case |  |
| `<a-o>` / `<a-i>` (syntax) | `<a-up>` / `<a-down>` | `<a-i>` is "inside object" |
| `z` view mode, `zz` | `v` view mode, `vv` | |
| `gs` | `gi` | first non-blank character |
| `]f` (next function) | `<space>t` then `/f` | `]f` here extends to the function end |
| `<space>y` / `<space>p` | `y` / `<space>p` | `y` already copies to the macOS clipboard |
| `ctrl-c` (comment) | `<space>c` | |
| `]g` / `[g` (next / previous change) | `<space>hn` / `<space>hp` | see [Git](#git) |
| `:bc` | `:db` or `<space>b` `q` | close the buffer |
| `gw` (jump labels) | same | added in this config; `<c-o>` jumps back |
| `mm` `ms` `mr` `md` `mi` `ma` | same | added in this config (see [Surround](#surround-helixs-m-mode)) |
| auto pairs | same | added in this config (see [Auto pairs](#auto-pairs)) |

## Modes

| Key | Action |
|---|---|
| `i` / `a` | insert before / append after the selection |
| `I` / `A` | insert at line start / append at line end |
| `o` / `O` | open a new line below / above |
| `<a-o>` / `<a-O>` | add an empty line below / above, stay in normal mode |
| `<esc>` | back to normal mode |
| `<a-;>` | (in insert mode) run one normal-mode command, then return |
| `:` | command prompt (`:w`, `:q`, `:e file`, ...) |

The cursor is **green in insert mode** (rosewater in normal mode), as in Helix.
Kakoune can't change the terminal cursor's shape, so the colour does that job.
Faint `│` indent guides mark each indent level, like Helix's indent guides.

## Movement

| Key | Action |
|---|---|
| `h` `j` `k` `l` | left, down, up, right |
| `w` / `b` / `e` | next word start / previous word start / word end |
| `<a-w>` `<a-b>` `<a-e>` | same, by WORD (whitespace-separated) |
| `f<c>` / `t<c>` | select to / until the next `<c>` (searches past the end of the line) |
| `<a-f><c>` / `<a-t><c>` | same, backwards |
| `gh` / `gl` / `gi` | line start / line end / first non-blank |
| `gg` / `ge` | file start / file end |
| `gt` / `gc` / `gb` | top / centre / bottom of the screen |
| `<number>g` | go to line `<number>` |
| `gw` | jump to any word on screen: two-letter labels appear over the words, type one to select that word (`<esc>` cancels) |
| `mm` | select to the matching bracket (Helix-style; `M` extends) |
| `<c-o>` / `<c-i>` | jump back / forward in the jump list |
| `<c-d>` / `<c-u>` | half page down / up |
| `vv` | centre the view on the cursor (`v` = view menu) |

Add Shift to extend instead: `W`, `J`, `L`, `F<c>`, `M`, `G`, etc.

## Selecting

| Key | Action |
|---|---|
| `x` | select the line; pressed again, add the next line (Helix-style) |
| `3x` | select 3 lines (on whole lines: add 3 more) |
| `X` | extend to full lines without adding any (Kakoune's own `x`) |
| `<a-x>` | shrink to full lines |
| `J` / `K` | extend the selection a line down / up (`x5J` = this line plus 5) |
| `%` | whole file |
| `<a-i>` / `<a-a>` | inside / around an object, followed by: `w` word, `(` `[` `{` `<` brackets, `"` `'` quotes, `p` paragraph |
| `[` / `]` | to the start / end of an object (same object keys); `{` / `}` extend |
| `;` | collapse each selection to its cursor |
| `<a-;>` | flip cursor and anchor |
| `*` | use the selection as the search pattern |
| `<a-u>` / `<a-U>` | undo / redo a selection change |

### Objects (the key after `<a-i>`, `<a-a>`, `[`, `]`, `mi`, `ma`)

`<a-i>` takes the *inside* (no brackets, no trailing space), `<a-a>` the whole thing.

| Key | Object | Useful for |
|---|---|---|
| `(` `b` / `[` `r` / `{` `B` / `<` `a` | brackets | arguments, array constructors |
| `"` `Q` / `'` `q` / `` ` `` `g` | quoted string | format strings, file names |
| `w` / `<a-w>` | word / WORD | |
| `u` | one argument of a call | `<a-i>u` in `call bar(n, x + 1.0)` on `n` selects `n` |
| `i` | indentation block | `<a-i>i` in a `do` loop body selects the body |
| `n` | number | |
| `p` / `s` | paragraph / sentence | comments, Markdown |
| `<space>` | whitespace | |
| `c` | custom: you type an open and a close regex | see [do loops](#selecting-a-whole-block-eg-a-do-loop) |
| `f` / `t` / `a` | function / type or module / parameter | tree-sitter, see below |

### Multiple selections (multi-cursor)

| Key | Action |
|---|---|
| `s` | inside the selection, select every regex match (`%s foo<ret>` = every `foo`) |
| `S` | split the selection on a regex |
| `<a-s>` | split into one selection per line |
| `C` / `<a-C>` | add a cursor on the line below / above |
| `<a-k>` / `<a-K>` | keep / drop selections matching a regex |
| `,` | keep only the main selection |
| `<a-,>` | drop the main selection |
| `)` / `(` | rotate which selection is the main one |
| `&` | align selections (insert spaces so they line up) |
| `_` | trim whitespace from each selection |
| `<a-_>` | merge touching selections |

In this config, `s`, `S`, `<a-k>`, `<a-K>` and the search prompts start with
`(?i)`, so matching **ignores case** (like Helix). Delete `(?i)` for exact case.

### Selecting a function or subroutine

| Key | Action |
|---|---|
| `<a-i>f` | the body of the procedure around the cursor |
| `<a-a>f` | the whole procedure, from `subroutine`/`function` to `end ...` |
| `[f` / `]f` | extend to the start / end of the procedure |
| `<a-i>t` / `<a-a>t` | inside / whole module, program or derived type |
| `<space>t` then `/f` / `<a-/>f` | jump to the next / previous procedure |

These use tree-sitter (via a patched kak-tree-sitter, see the README).

### Selecting a whole block (e.g. a `do` loop)

The custom object `c` takes an opening and a closing regex, separated by a comma,
and selects the block around the cursor. It understands nesting.

Select the whole `do ... end do` loop:

```text
<a-a>c(?i)^\h*(?:\w+\h*:\h*)?do\b,(?i)^\h*end\h*do\b<ret>
```

- `<a-a>c...` selects the whole loop as full lines; `<a-i>c...` only its body.
- Works from anywhere in the loop: its body, the `do` keyword or the `end do` line.
  The cursor must be on or after `do`, not in the indentation before it.
- Nested loops: from an inner loop it selects that loop; repeat it to grow to
  the outer loop.
- `(?i)` matches `DO` / `END DO` too (fprettier writes them in upper case), and
  `(?:\w+\h*:\h*)?` allows named loops (`outer: do`).
- The same recipe works for other blocks: put that block's opening and closing
  keywords in place of `do` and `end\h*do`.

Tree-sitter's `<a-up>` (select parent node) is not reliable for this: from an
inner loop it jumps straight to the outer one.

## Editing

| Key | Action |
|---|---|
| `d` / `c` | delete / change (delete and insert) the selection |
| `<a-d>` / `<a-c>` | same, without yanking (clipboard untouched) |
| `y` | yank (also copied to the macOS clipboard) |
| `p` / `P` | paste after / before |
| `R` | replace the selection with the yanked text |
| `r<c>` | replace every selected character with `<c>` |
| `u` / `U` | undo / redo |
| `.` | repeat the last insert (`i`, `a`, `c` and its text) |
| `<a-.>` | repeat the last `f`/`t` or object selection |
| `>` / `<` | indent / dedent |
| `<a-j>` | join lines |
| `~` / `` ` `` / ``<a-`>`` | upper case / lower case / swap case |
| `|` | pipe selections through a shell command (`|sort<ret>`) |
| `!` / `<a-!>` | insert command output before / after |
| `<space>p` / `<space>P` | paste from the macOS clipboard after / before |
| `<space>c` | comment / uncomment lines |

In Fortran files, `<ret>` keeps the indent of the line above and adds one level
after a block opener (`do`, `if ... then`, `subroutine`, `contains`, ...);
`end ...`, `else` and `case` dedent as you type them. On a comment line, the new
line continues the comment (`!` or `!!`, plus a space) at the same indent.
`<esc>` trims trailing spaces.

## Surround (Helix's `m` mode)

| Key | Action |
|---|---|
| `ms<c>` | surround each selection with `<c>` (`ms(` → `(foo)`) |
| `mr<from><to>` | replace the surrounding pair (`mr("` → `"foo"`) |
| `md<c>` | delete the surrounding pair |
| `mi<c>` / `ma<c>` | select inside / around (same as `<a-i>` / `<a-a>`) |
| `mm` | go to the matching bracket |

`<c>` is a bracket (either side), a quote, or a Kakoune object letter
(`b` = `()`, `r` = `[]`, `B` = `{}`, `a` = `<>`, `Q` = `"`, `q` = `'`, `g` = `` ` ``).
`ms` also takes any other character (`ms*` → `*foo*`). After `ms` the selection
includes the new pair, as in Helix, so `ms(` `ireal<esc>` gives `real(foo)`.
`mr` / `md` work on the
pair around the cursor, with multiple cursors too; one `u` undoes the change.

## Auto pairs

In insert mode, as in Helix:

- Typing `(` `[` `{` `"` `'` or `` ` `` also inserts the closing character, with
  the cursor between them: `(` gives `(|)`.
- This only happens when the next character is a space, the end of the line or a
  closing bracket, so typing `(` just before a word does not add a `)`.
- A quote also needs no letter or digit just before it, so `don't` and Fortran's
  `'it''s'` come out as typed.
- Typing the closing character when it is already next steps over it, so typing
  `()` or `"hi"` in full gives the same text as before.
- `<backspace>` on the opening character of an empty pair deletes both.

To turn it off until you restart Kakoune, run `:remove-hooks global auto-pairs`.

## Search

| Key | Action |
|---|---|
| `/` / `<a-/>` | search forward / backward |
| `n` / `<a-n>` | next / previous match |
| `N` | **add** the next match as another selection |
| `?` / `<a-?>` | extend the selection to the next / previous match |
| `<space>/` | live grep over the project (fzf) |

## Recipes (for Fortran)

Each recipe is a sentence of the keys above. All were tested in this config.

| Task | Keys |
|---|---|
| Rename `n` everywhere in this subroutine | `<a-a>f` `s\bn\b<ret>` `c` new name `<esc>` |
| ... in the whole file | `%` `s\bn\b<ret>` `c` ... `<esc>` |
| Exact case only (`n`, not `N`) | in the `s` prompt, delete the `(?i)` first |
| Align the `::` of declarations | select the lines (`x` `J`...), `s::<ret>` `&` |
| Delete every `print` line | `%` `<a-s>` `<a-k>print<ret>` `d` |
| Select a `do` loop body | cursor in the body, `<a-i>i` |
| Change one call argument | cursor on it, `<a-i>u` `c` |
| Add `, intent(in)` to several declarations | select the lines, `s\h::<ret>` `i, intent(in)<esc>` |
| Comment out a block | select the lines, `<space>c` |
| Wrap an expression in `real(...)` | select it, `ms(` `ireal<esc>` |
| Sort `use` statements | select the lines, `|sort<ret>` |
| Jump back where you were | `<c-o>` (and `<c-i>` forward) |

`s` in this config ignores case, so `s\bn\b` matches `n` **and** `N` (Fortran
does not care either). Check the selection count in the status line before
pressing `c`.

## Macros and registers

| Key | Action |
|---|---|
| `Q` | start / stop recording a macro |
| `q` | play it back |
| `"<r>` | use register `<r>` for the next yank / paste / macro (`"ay`, `"ap`) |
| `Z` / `z` | save / restore the selections |
| `<c-r><r>` | (in insert mode) insert register `<r>` (`<c-r>"` = last yank) |

Registers worth knowing: `"` last yank/delete, `/` last search, `@` last macro,
`:` last command, `^` saved selections (`Z`), `a`–`z` your own.

## Files, buffers and pickers

| Key | Action |
|---|---|
| `<space>f` | find a file (fzf) |
| `<space>e` | yazi: pick a file, `<ret>` opens it in this session (bulk rename, `r` on selected files, edits the names in your `$EDITOR`) |
| `<space>E` | broot: type to filter the tree, `<ret>` on a file opens it (on a folder, enters it); `<esc>` goes back / quits |
| `<space>,` | pick an open buffer |
| `<space>'` | reopen the last picker with the text you had typed (also after `<esc>`) |
| `ctrl-t` (in a picker) | show / hide the preview, as in Helix |
| `<space>?` | command palette: every key with a description; type a few words (`goto symbol`, `stage`), `<ret>` presses its keys |
| `gn` / `gp` / `ga` | next / previous / last buffer |
| `<space>b` | buffer menu: `q` close, `Q` close and discard, `o` close others, `w` / `W` write / write all |
| `:e <file>` | open a file (`<tab>` completes paths) |
| `gf` | open the file whose name is selected (select it first, e.g. with `<a-i><a-w>`) |
| `:w` / `:wa` | write / write all (formats and trims trailing spaces first) |
| `:q` / `:q!` | close this window / ... discarding changes |

Reopening a file puts the cursor back where it was (kept in
`~/.local/state/kak/positions`). An explicit line still wins: `kak file +10`,
`gd`, grep and picker jumps go where they say.

## Code (LSP, tree-sitter)

| Key | Action |
|---|---|
| `gd` / `gr` / `gy` | definition / references / type definition |
| `<space>k` | hover documentation |
| (automatic) | while typing a call, its signature shows above the cursor (`:lsp-signature-help` to show it on demand) |
| `<space>a` | code actions |
| `<space>r` | rename |
| `<space>d` | diagnostics picker (fzf with a preview), for all open files |
| `<space>D` | diagnostics list (a buffer: `<ret>` jumps) |
| `<c-n>` / `<c-p>` | next / previous error or warning |
| `<space>s` | goto symbol: type part of a name, `<tab>` through matches, `<ret>` jumps (no list buffer) |
| `<space>S` | workspace symbols |
| `<space>=` | format the buffer (also runs on every save) |
| `<space>l` | all LSP commands; `<space>l s` is goto symbol, `<space>l S` lists the document's symbols in a buffer |
| `<space>t` | tree-sitter menu (`f` function, `a` parameter, `t` type, `c` comment) |
| `<a-up>` / `<a-down>` | select the parent / child syntax node |

### Completion and snippets

In insert mode the menu appears as you type:

- `<tab>` / `<s-tab>`, `<down>` / `<up>` (or `<c-n>` / `<c-p>`): move through
  the menu; with no menu open the arrows move the cursor as usual
- `<ret>`: accept the picked item (no newline); a snippet expands with its first
  placeholder selected
- `<tab>` with no menu open: jump to the next snippet placeholder; typing
  replaces the default, skipping keeps it

Snippets are the shared VSCode-style ones in `~/.config/nvim/snippets`.
Editing those `.json` files, you get JSON highlighting (tree-sitter; no JSON
language server or formatter). Restart Kakoune after
editing them so the snippet server reads them again.

## Writing Markdown

No preview and no language server: Markdown is edited as plain text.

- **Highlighting** (tree-sitter): headings coloured by level, bold, italic,
  `` `code` ``, links, list markers, checkboxes, quotes. A fenced code block
  (```` ```fortran ````) is highlighted in its language.
- **Soft wrap**: long lines wrap at word boundaries, `↪` marks a wrapped line.
  It is display only; the file keeps one long line per paragraph.
- **Formatting**: `rumdl fmt` tidies the file on save (`<space>=` to format
  now): heading spacing, blank lines around lists, trailing spaces.
- With no language server there is no link jumping (`gd`), no lint warnings and
  no snippets in Markdown; word completion still works.

Useful keys while writing prose:

| Keys | Action |
|---|---|
| `<a-i>p` / `<a-a>p` | select the paragraph (without / with the blank line after it) |
| `ms*` | wrap the selection in `*` (italic); `ms*` again makes it `**bold**` |
| ``ms` `` | wrap the selection in backticks (inline code) |
| `w` / `b`, `/` | move inside a long paragraph: `j` / `k` move by file line, so they jump over a whole wrapped paragraph |

## Git

Files in a git repo get marks next to the line numbers, like gitsigns or Helix's
diff gutter: **green** added, **blue** changed, **red** `_` / `‾` deleted lines.
They compare the buffer with what is **staged**, so staging a change clears its
marks. They update when the file is shown, after `<esc>` from insert mode, on
save, when you return to the terminal, and when lazygit closes. The status line
shows the branch.

`<space>h` opens the git menu:

| Key | Action |
|---|---|
| `<space>h` `n` / `p` | next / previous change (Helix: `]g` / `[g`) |
| `<space>h` `s` | stage the selected lines (cursor on a line = that line; `x` / `xx` for more) |
| `<space>h` `u` | unstage the selected lines |
| `<space>h` `r` | revert the selected lines to the staged version (save first) |
| `<space>h` `b` | toggle blame; `<ret>` on a line shows its commit |
| `<space>h` `d` | diff of this file in a buffer |
| `<space>h` `h` / `g` | hide / show the marks |
| `<space>g` | lazygit (commit, push, branches) |
| `<space>G` | diffnav: browse all uncommitted changes (staged and not) with a file tree; `q` closes |

Revert changes the file on disk and reloads it, so it refuses while the buffer
has unsaved edits (`:w` first). Check the selection before pressing `r`.

`:diffnav` takes any `git diff` arguments, for other diffs: `:diffnav --cached`
(staged only), `:diffnav main` (against a branch), `:diffnav HEAD~3 -- src`.
It shows saved changes only, and new untracked files are not in `git diff`
until you `git add` them. In diffnav, `e` toggles the file tree and `/` searches.

## easifem

| Key | Action |
|---|---|
| `<space>+` `+` | run the current test file (`easifem run`) in a popup |
| `<space>+` `b` / `c` | build and install base / classes **in the background** |
| `<space>+` `l` | open the log of the latest build |
| `<space>+` `e` | list the compiler errors of the latest build; `<ret>` on one opens the file there |
| `<space>+` `n` / `p` | jump to the next / previous build error |
| `<space>+` `u` or `:split-use` | split `use ..., only: a, b` into one import per line: in the selected lines, or the whole buffer when nothing is selected |
| `:easifem-build-log base` / `classes` | open that package's log (`:easifem-build-errors` takes the same) |
| `<space>g` | lazygit |

Builds run `easifem dev <pkg> -q && easifem install <pkg> --no-download -q` with
no popup, so you keep editing. When the build ends:

- **success**: an info box and a macOS notification ("base: built and installed (2m 13s)")
- **failure**: an info box with the first compiler errors (or the end of the
  log) and a notification; `<space>+` `e` lists every error, `<space>+` `l`
  opens the full log

The error list reads gfortran's `file:line:col:` / `Error: ...` pairs (and
`Fatal Error`) from the log; warnings are left out. Paths inside the current
directory are shown relative to it.

Logs: `~/.cache/easifem/easifem-build-base-log.txt` and
`easifem-build-classes-log.txt`, rewritten by each build (an open log buffer
reloads by itself). Pressing `b` again while that package is building only says
it is already building. Helix's `+` menu still uses the tmux popup scripts.

`:split-use` runs `$easifem/config/scripts/split-use-only.fish` through the
script's stdin mode, so unsaved edits count and the file is not written.

- **Lines selected** (e.g. `x` `x` `x`, or an `<a-i>` object): only those lines
  change. Each selection is widened to whole lines and must hold whole
  statements, `&` continuations included.
- **Only a cursor**: the whole buffer.

Spelling, case, renames and indentation are kept; comments move above the
import group. Statements it can't handle (inside `#ifdef`, `;`-separated, or
cut off by the selection) are left alone and listed in an info box, by line
number (counted from the selection's first line in selection mode). One `u`
undoes it.

## Sessions

One session per project: all its windows share buffers, registers and a single
language server, so zfls indexes easifem once instead of once per window.

| Command | Action |
|---|---|
| `kak -s classes` | start a session named `classes` |
| `kak -c classes [file]` | open another window in that session |
| `:new` | open another window from inside Kakoune |
| `kak -l` | list running sessions |
| `:rename-session <name>` | name the current session |
| `kak -d -s <name>` | start a session in the background (no window) |
| `:q` | close this window (the session keeps running) |
| `:kill` | end the session (refuses if there are unsaved changes) |
| `:kill!` | end the session, discarding unsaved changes |
| `kak -clear` | remove leftovers of crashed sessions |

Close every session (fish), safely: unsaved sessions stay open.

```fish
for s in (kak -l); echo kill | kak -p $s; end
```

## Getting help

- Pause after a prefix key (`g`, `v`, `<a-i>`, `<space>`, `m`): a menu lists what follows.
- `:doc keys`, `:doc faq`, `:doc registers`, `:doc regex` (`<tab>` lists every topic).
- In the `:` prompt, `<tab>` completes commands and shows each one's description.
- `:echo %val{selection_count}` and other expansions help when a command misbehaves.

## Practice

Copy this into a scratch file (`:e /tmp/practice.f90`) and try each exercise.
Press `u` after each one to start again.

```fortran
subroutine foo(n, x)
  integer :: n
  real(dfp), intent(inout) :: x
  integer :: i
  do i = 1, n
    x = x + i
    print *, x
  end do
  print *, N
  call bar(n, x + 1.0, "s")
end subroutine foo
```

1. Delete the whole `do` loop: on `do`, `4x` `d` (or `x` `x` `x` `x` `d`). (Then try `<a-a>c...` from
   [do loops](#selecting-a-whole-block-eg-a-do-loop).)
2. Select every `n` / `N`: `%` `s\bn\b<ret>`. The status line shows 5 selections.
   `<esc>` or `,` to get back to one.
3. Align the declarations: `2g` `3x` `s::<ret>` `&`.
4. Delete both `print` lines in one go: `%` `<a-s>` `<a-k>print<ret>` `d`
   (`<a-s>` already gives whole lines, so no `x`).
5. Change `x + 1.0` to `2.0*x`: on `x` of `x + 1.0`, `<a-i>u` `c2.0*x<esc>`.
6. Swap `"s"` to `'s'`: cursor inside it, `mr"'`.
7. Upper-case every `integer`: `%` `sinteger<ret>` `~`.
8. Put `1` at the start of lines 2–4 with one insert: `2g` `C` `C` `I1<esc>`
   (`C` adds a cursor on the next line).
9. Jump to the subroutine by name: `<space>s`, type `fo`, `<ret>`. In a real
   easifem module, type part of any procedure name; `<tab>` steps through matches.
10. Auto pairs: on the `print *, N` line, `A` and type `, abs(x)` then `<esc>`.
    The `(` adds a `)` and typing `)` steps over it, so the line ends in
    `abs(x)`, not `abs(x))`. Then `o(` `<backspace>`: both characters go.

## Patched tools

Three tools are patched for this config. The patches live in `patches/`; Helix
uses none of these binaries, so rebuilding them never affects Helix.

| Tool | Patch | What it fixes | Symptom without it |
|---|---|---|---|
| scls (`bin/scls-kak`) | `scls-full-sync.patch` | scls ignored the full-document changes kak-lsp sends | no snippets in the completion menu |
| kak-tree-sitter 3.2.2 | `kak-tree-sitter-text-objects.patch` | nodes ending at a line start; `(_)+` captures kept only the first node | `<a-i>f` / `<a-a>f` / `<a-i>t` do nothing or select one line |
| kak-lsp 22.0.0 | `kak-lsp-did-save.patch` | `didSave` was not sent to efm-langserver | no gfortran (efm) errors after `:w` |

Redo the matching step after **any** reinstall or upgrade of that tool (for
example `cargo install --force kak-lsp` puts the unpatched version back).

### scls

A separate Kakoune-only copy, built by a script (needs `git` and `cargo`); Helix's
`simple-completion-language-server` binary is not touched:

```fish
~/.config/kak/bin/build-scls-kak     # writes ~/.config/kak/bin/scls-kak
```

Then restart Kakoune. The script pins the scls version Helix uses; pass another
git revision as an argument to build a different one (the patch may need updating).

### kak-tree-sitter

Download the crate source, apply the patch, install over the stock binary:

```fish
cd (mktemp -d)
curl -sL https://crates.io/api/v1/crates/kak-tree-sitter/3.2.2/download | tar xz
cd kak-tree-sitter-3.2.2
git apply ~/.config/kak/patches/kak-tree-sitter-text-objects.patch
cargo install --locked --path . --force
```

Then restart the tree-sitter server and Kakoune:
`kill (cat $TMPDIR/kak-tree-sitter/pid)` (on Linux: `$XDG_RUNTIME_DIR/kak-tree-sitter/pid`).

### kak-lsp

Same steps with the kak-lsp crate:

```fish
cd (mktemp -d)
curl -sL https://crates.io/api/v1/crates/kak-lsp/22.0.0/download | tar xz
cd kak-lsp-22.0.0
git apply ~/.config/kak/patches/kak-lsp-did-save.patch
cargo install --locked --path . --force
```

Then restart Kakoune (each session starts its own kak-lsp).

### Checking and upgrading

- `command -v kak-lsp kak-tree-sitter` should print paths in `~/.cargo/bin`.
- **Upgrading** to a newer version: put the new version number in the `curl` and
  `cd` lines. If `git apply` fails, the code changed; check whether the newer
  release already fixes the bug (then no patch is needed), otherwise the patch
  must be updated.
- **Undo a patch**: reinstall the stock version, e.g.
  `cargo install --locked --force kak-lsp`.
- Status upstream: the scls bug is reported as
  [estin/simple-completion-language-server#238](https://github.com/estin/simple-completion-language-server/issues/238);
  the kak-tree-sitter and kak-lsp bugs are not reported yet.

## Troubleshooting

- **Errors or LSP messages**: `:buffer *debug*`
- **`<a-i>f` / `<a-a>f` do nothing**: kak-tree-sitter is unpatched; see
  [Patched tools](#kak-tree-sitter)
- **No gfortran errors (efm) after saving**: kak-lsp is unpatched; see
  [Patched tools](#kak-lsp). efm only runs on save, so errors appear after `:w`,
  not while typing
- **No Fortran, TOML, Markdown, CMake or JSON highlighting**: restart the tree-sitter server, then
  restart Kakoune: `kill (cat $TMPDIR/kak-tree-sitter/pid)` (on Linux: `$XDG_RUNTIME_DIR/kak-tree-sitter/pid`)
- **No snippets**: start Kakoune from fish (it sets `SNIPPETS_PATH`), and check
  that `bin/scls-kak` exists; see [Patched tools](#scls)
- **Pickers do nothing**: Kakoune must run inside tmux
- **`<space>E` (broot) opens nothing**: `<ret>` must be on a file, not a folder;
  check `broot/kak.hjson` exists
