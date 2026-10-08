#!/usr/bin/env bash
# tmux-sessionizer: one picker for open sessions, their windows, and saved projects.
#   tmux-sessionizer          pick from the list
#   tmux-sessionizer <path>   open that folder as a project directly
#
# Rows are "target<TAB>label"; the target says what Enter does:
#   s:<session>             switch to an open session
#   w:<session>:<index>     jump to a window of an open session
#   p:<path>                open (creating the session if needed) a saved project
# Saved projects live in ~/.config/tmux-projects, one path per line, most recently opened first.
# Keys: Enter open | ctrl-a save current dir | ctrl-x kill session/window or unsave project

projects=~/.config/tmux-projects
self=$(command -v -- "$0")

name() { basename -- "$1" | tr . _; }

go() {
  if [[ -z $TMUX ]]; then tmux attach-session -t "=$1"; else tmux switch-client -t "=$1"; fi
}

# Moves (or adds) a path to the top of the projects file.
bump() {
  mkdir -p "$(dirname "$projects")"; touch "$projects"
  { echo "$1"; grep -vxF -- "$1" "$projects"; } > "$projects.tmp"; mv "$projects.tmp" "$projects"
}

list() {
  local open session path
  open=$(tmux list-sessions -F '#{session_last_attached}	#{session_name}' 2>/dev/null | sort -rn | cut -f2)
  while read -r session; do
    [[ -z $session ]] && continue
    printf 's:%s\t● %s\n' "$session" "$session"
    tmux list-windows -t "=$session" -F "w:$session:#{window_index}	    $session › #{window_name}"
  done <<< "$open"
  while read -r path; do
    grep -qxF -- "$(name "$path")" <<< "$open" || printf 'p:%s\t  %s\n' "$path" "$(name "$path")"
  done < "$projects"
}

preview() {
  local target=${1#?:}
  case $1 in
    s:*) tmux list-windows -t "=$target" -F '#{?window_active,●, } #{window_index}: #{window_name}' ;;
    w:*) tmux capture-pane -ep -t "=${target%:*}:${target##*:}" ;;
    p:*) git -C "$target" log --oneline -8 2>/dev/null; echo; ls "$target" ;;
  esac
}

kill_target() {
  local target=${1#?:}
  case $1 in
    s:*) tmux kill-session -t "=$target" ;;
    w:*) tmux kill-window -t "=${target%:*}:${target##*:}" ;;
    p:*) grep -vxF -- "$target" "$projects" > "$projects.tmp"; mv "$projects.tmp" "$projects" ;;
  esac
}

case $1 in
  --list) list; exit ;;
  --preview) preview "$2"; exit ;;
  --kill) kill_target "$2"; exit ;;
  --add) bump "$PWD"; exit ;;
esac

if [[ $# -eq 1 ]]; then
  selected="p:${1%/}"
else
  selected=$(list | fzf --delimiter=$'\t' --with-nth=2 --reverse \
    --header='Enter: open | ^a: save this dir | ^x: kill / remove' \
    --preview "$self --preview {1}" --preview-window='right:50%' \
    --bind "ctrl-a:execute-silent($self --add)+reload($self --list)" \
    --bind "ctrl-x:execute-silent($self --kill {1})+reload($self --list)" | cut -f1)
fi
[[ -z $selected ]] && exit 0

target=${selected#?:}
case $selected in
  s:*) go "$target" ;;
  w:*) tmux select-window -t "=${target%:*}:${target##*:}"; go "${target%:*}" ;;
  p:*)
    n=$(name "$target")
    tmux has-session -t="$n" 2>/dev/null || tmux new-session -ds "$n" -c "$target"
    bump "$target"
    go "$n" ;;
esac
