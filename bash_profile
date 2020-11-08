#!/bin/bash

########################################################################
# NOTES:
# 1. to load this file RIGHT AFTER any changes, type:
#              . !$
#    ref: see /u/ hyper_st8 @ https://goo.gl/tU3PFr (so)
# 2. to quickly show/hide this & other hidden files in Finder, use:
#              CMD + SHIFT + .
#    ref: see https://goo.gl/G2eCwA (ian lunn)
# 3. ~/.bash_profile is symlinked to ~/dotfiles/bash-profile
#    so that we can git version this and other key dotfiles.
#    ref: /u/ sehe comments on /u/ tuxdude @ https://goo.gl/hjXAkw (so)
#########################################################################

################ TERMINAL CLEARING
# clear terminal tabs @ start-up
#     2 ways to get this done:
#       -- see details @ https://goo.gl/PqSqix (stackoverflow)
#       -- (a) clear && printf '\e[3J'  --> see /u/ fearless_fool
#       -- (b) printf '\33c\e[3J'       --> see /u/ qiuyi, /u/ luiss
#     (a) ~ (b), as \33c is ~ to the clear command  (see /u/ luiss)
#     we use (b) here, as i felt it is prettier
#
# NOTE:
# place this code right at the top, before any other code; otherwise,
# when you/system sources ~/.bash_profile, you will see nothing on the screen,
# as this code will clear screen (stdout) of all bash_profile output!!
printf '\33c\e[3J'

################ PATH SETUP
# PATH, in Terminal, is set under the following conditions:
#  -- 1. when you open a new tab, bash starts a new login, interactive shell session.
#        bash sources /etc/profile, and then ~/.bash_profile. PATH is initially 
# 	 empty, /etc/profile then sets PATH to the default system path,
#	 and .bash_profile then adds custom paths to PATH
#  -- 2. when you manually source ~/.bash_profile in an existing bash session 
#   	 (i.e., existing Terminal tab), bash just loads bash_profile, but not 
# 	 /etc/profile.  in this process, existing PATH for the session, available 
#        in the environment, is taken, and paths defined in bash_profile gets 
#        added again to this PATH, even though they may already exist in PATH.
#        so you may end up with duplicated custom paths in PATH.
#  -- 3. you can also manually set PATH for an existing bash session, by typing
#        PATH=some-value @ the Terminal.  if you then source bash_profile, 
#	 bash will take the PATH you've manually set, and use it to do (2).
#
#        this is a process you often follow when you want to test .bash_profile.
#        you manually modify PATH, and then source bash_profile to see if 
#        everything is handled well under a variety of conditions.
#
#        if the PATH is invalid (say, "") or missing key paths 
#        (say, /usr/bin, /bin), when you source bash_profile, it may throw errors
#        and you may end up with a null/empty invalid PATH, so bash will not 
#        recognize basic shell commands like ls and cat.
#  -- 4. finally, you can manually source /etc/profile in an existing bash
#	 session, and if you do that, bash grabs the existing PATH in the environment
#	 for that session, and prepends the system path to it. this abruptly modifies 
#        the path order you had in PATH, so you may have to source .bash_profile 
#        manually to have your custom paths reset ahead of the system path in PATH.
#
#	 you can use (4) to fix a mangled PATH, using the below sequence of 
#	 commands @ the Terminal:
#		(a) PATH=
#		(b) source /etc/profile
#		(c) source ~/.bash_profile
#
# GOAL:
# 1. Apple's process can -- and do -- result in dups & unexpected path order.
# 2. we want to avoid that as much as possible by ensuring that loading/sourcing 
#    ~/.bash_profile always gives a valid PATH.
# 3. but our custom process may fail for unexpected reasons, so we want to also 
#    ensure that even if bash_profile execution encounters errors, or even if it 
#    fails to add custom paths to PATH for some reason, user will still end up, 
#    at the very least, with a valid system PATH, so that he/she will always 
#    have a valid bash session.
#
# VALID PATH:
# (a) has no duplicates;
# (b) has paths (both custom & system) in expected order
#
# DESIGN:
# 1. initialize PATH, no what matter what, to system path, the core PATH Apple 
#    sets.  to do this, we call ~/dotfiles/bash/bin/pathhelper executable from 
#    ~/.bash_profile whenever you load/source ~/.bash_profile. since PATH is 
#    initialized/reset to system path, we build PATH afresh every time, avoiding 
#    duplicates & bad path order. see pathhelper file for details.
# 2. if (1) succeeds, in ~/.bash_profile, we PREPEND each user-defined custom 
#    path to PATH by calling `addpath()`.  `addpath()` ensures the following:
#       a) no duplicates -- the to-be-added path is first searched in PATH, and, 
#          if found, all instances of path are removed from PATH;
#       b) path order -- the to-be-added path is PREPENDED to PATH.
#       c) mishaps -- on errors, skips prepending custom path to PATH.
# 3. if (1) fails, display warning to user, and skip prepending any custom paths 
#    to PATH.  PATH will then be that set by Apple's process.  PATH, at the very 
#    least, will have system paths, so users will have a valid bash session.
#
# REFERENCES:
# -- reset PATH using `source /etc/profile`, see /u/ rjferguson @ 
#    https://goo.gl/Vf96oX (apple.SE)
# -- for PATH iteration idea using IFS, see http://mywiki.wooledge.org/IFS
# -- for NEWPATH="${NEWPATH:+$NEWPATH:}$DIR", see /u/ sancho.s @ 
#    https://tinyurl.com/y3ts4mle
# -- for use of ${NEWPATH:?error-message}, see /u/ chepner, /u/ jens @ 
#    https://goo.gl/QW52j8 (so)

function addpath() {
  # by design, we introduce NEWPATH, a temp, that stores value of new path, 
  # formed from PATH, for PREPENDING custom path to PATH.  After creation of 
  # NEWPATH, we ensure NEWPATH is neither empty nor null, and only then set PATH 
  # = custom-path:NEWPATH.  we thus insulate PATH from being invalid.
  # args: custom_path
  local NEWPATH custom_path

  custom_path="$1"
  if [[ ! -d "$custom_path" ]]; then echo -e "\npath \"$custom_path\" not a directory, so can not add it to PATH"; return; fi
  IFS=':'   # for parsing PATH
  for DIR in $PATH; do    # don't quote $PATH
    if [[ "$DIR" != "$custom_path" ]]; then   # ignore duplicate
      NEWPATH="${NEWPATH:+$NEWPATH:}$DIR"
    fi
  done
  unset IFS
  : ${NEWPATH:?can not be empty/null. Aborted adding "$custom_path" to PATH, as it will result in invalid PATH. NO custom paths added to PATH.}
  PATH="$1":"$NEWPATH"
}

# ref: for path breakup idea, done here in reverse, see:
# https://github.com/paulirish/dotfiles
pathexec="$HOME"/dotfiles/bash/bin/pathhelper   # customized path-init executable
if [[ -x "$pathexec" ]]; then
  if eval "$("$pathexec")"; then
    addpath "${HOME}/.cabal/bin"  # haskell cabal binaries
    addpath "${HOME}/.local/bin"
    addpath "${HOME}/bin"
    export PATH
  else
    echo -e "\ncustomized PATH initialization failed; as a result, PATH may be missing custom paths."
  fi
else
  echo -e "\ncustomized PATH-initialization executable \"$pathexec\" missing or does not have execute permission. as a result, PATH may be missing custom paths."
fi

################ TERMINAL PROMPT SETTINGS -- FORMAT & COLOR
# PS1, PS2 prompt colored -- see taylor mcgann @ 
# http://blog.taylormcgann.com/tag/prompt-color/
export PS1="\n\[\033[0;36m\]\h:\d: \w \u ▶ \[\033[0;m\]"  # cyan
export PS2="\[\033[0;31m\]▶▶ \[\033[0;m\]"                # red

export CLICOLOR=1


################ PYTHON SETTINGS
# https://blog.mozilla.org/webdev/2015/10/27/eradicating-those-nasty-pyc-files/
export PYTHONDONTWRITEBYTECODE=1 # prevent python from creating .pyc files

# https://opensource.com/article/19/5/python-3-default-mac
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi


################ HOMEBREW SETTINGS
export HOMEBREW_GITHUB_API_TOKEN=46ed2e0ca787be20944b88c8a3d63dd0491dcd7f


################ ALIASES
# haskell command
alias ghc="ghc -O2 -fforce-recomp -Wall -Werror"

# file listing, removal
alias ls="ls -laFh"            # "h" for human readable ouput
alias rm="rm -i"               # "i" for confirmation before removal

# alias for listing files, links, directories
# ref: /u/ kenorb @ https://goo.gl/4b9p9s (unix.se)
#      /u/ kleinfreund @ https://goo.gl/32P4vQ (superuser)
alias lf="ls | grep '^-'"      # list only files
alias ll="ls | grep '^l'"      # list only symlinks
alias lp="ls | grep '^[-l]'"   # list only files + symlinks
alias ld="ls | grep '^d'"      # list only directories

# commonly used dirs
sd="$HOME/software-development/code"
df="$HOME/dotfiles"
alias sd="cd $sd"
alias df="cd $df"

# bash profile testing
alias bp=". $HOME/dotfiles/bash/test/bp"
alias pl="cat -e $HOME/dotfiles/bash/log/path.log"
alias pyt="$HOME/dotfiles/bash/bin/py-exp"

# clear screen
alias clr="printf '\33c\e[3J'"

#########################################################################


