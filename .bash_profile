########################################################################
# NOTES:
# 1. set GHC & haskell binaries paths
# 2. PS1, PS2 prompt colored -- see taylor mcgann @ 
#    http://blog.taylormcgann.com/tag/prompt-color/
# 3. to load this file right after changes, type . !$
#    ref: see /u/ hyper_st8 @ https://goo.gl/tU3PFr (so)
#########################################################################
export PATH="${HOME}/bin:${HOME}/.local/bin:${HOME}/.cabal/bin:${PATH}"
export HOMEBREW_GITHUB_API_TOKEN=46ed2e0ca787be20944b88c8a3d63dd0491dcd7f

export PS1="\n\[\033[0;36m\]\h:\d:\w \u ▶ \[\033[0;m\]"  # cyan 
export PS2="\[\033[0;31m\]▶▶ \[\033[0;m\]"               # red

export CLICOLOR=1

alias ghc="ghc -O2 -fforce-recomp -Wall -Werror"
alias ls="ls -laFh"     # "h" for human readable ouput 
alias rm="rm -i"        # "i" for confirmation before removal

# clear terminal tabs @ start-up
#     2 ways to get this done:
#       -- see details @ https://goo.gl/PqSqix (stackoverflow)
#       -- (a) clear && printf '\e[3J'  --> see /u/ fearless_fool 
#       -- (b) printf '\33c\e[3J'       --> see /u/ qiuyi, /u/ luiss
#     (a) ~ (b), as \33c is ~ to the clear command  (see /u/ luiss)
#     we use (b) here, as i felt it is prettier
printf '\33c\e[3J' 
