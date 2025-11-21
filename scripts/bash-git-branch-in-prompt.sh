#!/bin/bash

# Script to add Git branch to bash prompt

BASHRC="$HOME/.bashrc"

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
export PS1="\[\033[32m\]\u\[\033[0m\]:\[\033[36m\]\w\[\033[0m\]\[\033[33m\]\$(git_branch_name)\[\033[0m\] % "
'

# Check if the configuration already exists
if grep -q "# ---- Git branch in prompt ----" "$BASHRC" 2>/dev/null; then
  echo "✅ Git branch prompt already exists in $BASHRC"
  exit 0
fi

# Add the configuration to .bashrc
echo "$PROMPT_CONFIG" >> "$BASHRC"

echo "✅ Added Git branch prompt to $BASHRC"
echo "Run 'source ~/.bashrc' to apply changes, or restart your terminal"
