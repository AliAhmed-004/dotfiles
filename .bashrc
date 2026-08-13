# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Initialize starship prompt
eval "$(starship init bash)"

alias ls='eza -l -h --icons '
alias grep='grep --color=auto'
alias glog='git log --oneline --graph'
alias hyprload='hyprctl reload'
PS1='[\u@\h \W]\$ '

# Copolot CLI
export PATH="/home/hyprdev/.local/bin:$PATH"
