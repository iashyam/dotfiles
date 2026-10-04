export PATH=$PATH:$HOME/go/bin
export PATH="$(brew --prefix)/opt/python/libexec/bin:$PATH"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced


# Function to get current git branch
parse_git_branch() {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
      echo "(${branch})"
  fi
}

# Set prompt with colors and git branch in green
setopt PROMPT_SUBST


PROMPT='%F{cyan}%~%f $(parse_git_branch)%f: '

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias z='cd'
alias v='nvim'
alias gst="git status"
alias gpl='git pull'
alias gpsh='git push'
alias gadd='git add .'
alias c='clear'
alias cls='clear'
alias please='sudo'
alias vim="nvim"
alias backend_run="uvicorn app.main:app"
alias ansible_deploy="ansible-playbook -i inventory/hosts.ini deploy.yml --tags app--vault-password-file ~/.vault_pass --ask-pass"

# Added by Hugging Face CLI installer
export PATH="/Users/shyamsunder/.local/bin:$PATH"


# pnpm
export PNPM_HOME="/Users/shyamsunder/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
