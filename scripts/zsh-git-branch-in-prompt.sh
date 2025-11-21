#!/bin/bash

# Script to add Git branch to zsh prompt

ZSHRC="$HOME/.zshrc"

# The prompt configuration to add
PROMPT_CONFIG='
# ---- Git branch in prompt ----
git_branch_name() {
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    echo " ($branch)"
  fi
}

# ---- Prompt config ----
setopt prompt_subst
autoload -U colors && colors

prompt='\''%{$fg[green]%}%n%{$reset_color%}:%{$fg[cyan]%}%~%{$reset_color%}%{$fg[yellow]%}$(git_branch_name)%{$reset_color%} % '\''
'

# Check if the configuration already exists
if grep -q "# ---- Git branch in prompt ----" "$ZSHRC" 2>/dev/null; then
  echo "✅ Git branch prompt already exists in $ZSHRC"
  exit 0
fi

# Add the configuration to .zshrc
echo "$PROMPT_CONFIG" >> "$ZSHRC"

echo "✅ Added Git branch prompt to $ZSHRC"
echo "Run 'source ~/.zshrc' to apply changes, or restart your terminal"
