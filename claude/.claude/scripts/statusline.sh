#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
ctx=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

dir=$(basename "$cwd")
pdir=$(dirname "$cwd")
if [ "$pdir" != "/" ] && [ "$pdir" != "$HOME" ]; then
  dir="$(basename "$pdir")/$dir"
fi

git_info=""
if cd "$cwd" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  st=""
  git --no-optional-locks diff --quiet 2>/dev/null && git --no-optional-locks diff --cached --quiet 2>/dev/null || st="*"
  git_info=" $branch$st"
fi

lang=""
if [ -f "$cwd/build.gradle.kts" ] || [ -f "$cwd/build.gradle" ]; then
  lang=" "
fi
[ -f "$cwd/package.json" ] && lang=" "

t=$(date +%H:%M)
ctxinfo=""
[ -n "$ctx" ] && ctxinfo="$(printf %.0f $ctx)%"

# Powerline right arrow (U+E0B0, Catppuccin Frappe palette)
arrow=$(printf '\xee\x82\xb0')
# Segments: red(210) > peach(216) > yellow(222) > green(150) > lavender(183), crust(235) fg
printf "\033[48;5;210m\033[38;5;235m 󰀵 "
printf "\033[48;5;216m\033[38;5;210m%s\033[38;5;235m  %s " "$arrow" "$dir"
last=216

if [ -n "$git_info" ]; then
  printf "\033[48;5;222m\033[38;5;%dm%s\033[38;5;235m%s " "$last" "$arrow" "$git_info"
  last=222
fi

if [ -n "$lang" ]; then
  printf "\033[48;5;150m\033[38;5;%dm%s\033[38;5;235m%s" "$last" "$arrow" "$lang"
  last=150
fi

printf "\033[48;5;183m\033[38;5;%dm%s\033[38;5;235m  %s " "$last" "$arrow" "$t"
printf "\033[0m\033[38;5;183m%s\033[0m" "$arrow"
[ -n "$ctxinfo" ] && printf " \033[38;5;183m%s\033[0m" "$ctxinfo"
echo
