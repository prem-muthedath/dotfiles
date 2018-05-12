########################################################################
# NOTES:
# 1. set GHC & haskell binaries paths
# 2. PS1, PS2 prompt colored -- see taylor mcgann @ 
#    http://blog.taylormcgann.com/tag/prompt-color/
# 3. to load this file RIGHT AFTER any changes, type:
#              . !$
#    ref: see /u/ hyper_st8 @ https://goo.gl/tU3PFr (so)
# 4. to quickly show/hide this & other hidden files 
#    in Finder, use: 
#              CMD + SHIFT + .
#    ref: see https://goo.gl/G2eCwA (ian lunn)
# 5. ~/.bash_profile is symlinked to ~/dotfiles/bash-profile
#    so that we can git version this and other key dotfiles.
#    ref: /u/ sehe comments on /u/ tuxdude @ https://goo.gl/hjXAkw (so)
#########################################################################
export PATH="${HOME}/bin:${HOME}/.local/bin:${HOME}/.cabal/bin:${PATH}"
export HOMEBREW_GITHUB_API_TOKEN=46ed2e0ca787be20944b88c8a3d63dd0491dcd7f

export PS1="\n\[\033[0;36m\]\h:\d:\w \u ▶ \[\033[0;m\]"  # cyan 
export PS2="\[\033[0;31m\]▶▶ \[\033[0;m\]"               # red

export CLICOLOR=1

alias ghc="ghc -O2 -fforce-recomp -Wall -Werror"
alias ls="ls -laFh"            # "h" for human readable ouput 
alias rm="rm -i"               # "i" for confirmation before removal

# alias for listing files, links, directories
# ref: /u/ kenorb @ https://goo.gl/4b9p9s (unix.se)
#      /u/ kleinfreund @ https://goo.gl/32P4vQ (superuser)
alias lf="ls | grep '^-'"      # list only files
alias ll="ls | grep '^l'"      # list only symlinks
alias lp="ls | grep '^[-l]'"   # list only files + symlinks
alias ld="ls | grep '^d'"      # list only directories

# clear terminal tabs @ start-up
#     2 ways to get this done:
#       -- see details @ https://goo.gl/PqSqix (stackoverflow)
#       -- (a) clear && printf '\e[3J'  --> see /u/ fearless_fool 
#       -- (b) printf '\33c\e[3J'       --> see /u/ qiuyi, /u/ luiss
#     (a) ~ (b), as \33c is ~ to the clear command  (see /u/ luiss)
#     we use (b) here, as i felt it is prettier
printf '\33c\e[3J' 
