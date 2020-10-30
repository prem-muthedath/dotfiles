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


# add path to PATH
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
# DESIGN:
# addpath(), though far from perfect, handles the following:
#   (a) avoids duplicated custom paths -- see (2) above.
#
#   	the to-be-added path is first searched in PATH, and, if found, 
#	all instances of path are removed from PATH, and then path is 
#	prepended -- always -- to this modified PATH.  in this whole 
#	process, the order of all other paths in PATH is never altered.
#   (b) ensure that loading/sourcing .bash_profile always gives a valid PATH.
#       that is, it ensures that, even if bash_profile execution encounters errors,
#	or even if it fails to add custom paths to PATH for some reason, you will 
#	still end up with a valid PATH, at the very least a valid system PATH, 
#	so that you'll always have a valid bash session.
#
#   	it also addresses, as much as possible, invalid inputs in bash_profile, 
#	as well as issues that may come from (3)
#
# METHOD:
#   -- validates input, and to ensure PATH remains always valid, simply returns if invalid
#   -- ensures PATH has /usr/bin & /bin -- essential to run the shell commands in the script
#   -- checks if PATH has exactly one /usr/local/bin -- a weak, surrogate check for system 
#      path -- and aborts if check fails, and alerts user
#   -- PATH modification done using sed:
#	-- /usr/local/bin used as sed address
#	-- to avoid duplicates, sed first clears to-be-added path from PATH,
#		dealing with 4 cases:
# 		-- (a) path occurs at the start of PATH
#		-- (b) path occurs at the end of PATH
#		-- (c) path is the only path in PATH
#		-- (d) path is somewhere between start and end, both exclusive, of PATH
#	 -- sed then prepends path to PATH
#	 -- finally, sed removes any dangling : at PATH end -- which occurs in (c) prepend
#   -- by design, NEWPATH, a temp, stores result from sed operations. if NEWPATH is null/empty 
#      (happens if sed fails) we throw an error & exit, but PATH, though unchanged, remains valid.
#      we thus insulate PATH from being invalid, only setting PATH=NEWPATH if NEWPATH is valid.
#
# REFERENCES:
# -- parameter expansion check for unset/null/spaces, see /u/elomage @ https://goo.gl/nK65cH (so)
# -- regex match for path in PATH, see /u/ terdon @ https://goo.gl/1S8NV3 (unix.SE)
# -- reset PATH using `source /etc/profile`, see /u/ rjferguson @ https://goo.gl/Vf96oX (apple.SE)
# -- grep regular expressions, see https://goo.gl/BWyKrA (digitalocean LLC)
# -- grep -o | wc -l for multi-match/line count, see /u/ wag, /u/ gilles @ https://goo.gl/iGGfVV (unix.SE)
# -- regex match/remove spaces in wc -l, see /u/ jens, /u/ william pursell @ https://goo.gl/D7NpX4 (so)
# -- for use of ${NEWPATH:?error-message}, see /u/ chepner, /u/ jens @ https://goo.gl/QW52j8 (so)


################ PATH SETUP
function addpath() {
	local IFS=':'
	local NEWPATH

	if [[ ! -d "$1" ]]; then echo -e "\npath '$1' not a directory, so can not add it to PATH"; return; fi
	for DIR in $PATH; do
		if [[ "$DIR" != "$1" ]]; then
			NEWPATH="${NEWPATH:+$NEWPATH:}$DIR"
		fi
	done
	PATH=$1:${NEWPATH:?can not be empty/null.  Aborted adding $1 to PATH, as the attempt results in an invalid new PATH}
}

# ref: for path breakup idea, done here in reverse, see:
# https://github.com/paulirish/dotfiles
if [[ -x ~/dotfiles/bash//bin/pathhelper ]]; then
	#if eval $(~/dotfiles/bin/pathhelper || echo "false"); then
	if eval $(~/dotfiles/bash/bin/pathhelper); then
		addpath "${HOME}/.cabal/bin"
		addpath "${HOME}/.local/bin"
		addpath "${HOME}/bin"
		export PATH
	else
		echo -e "\nPATH validation failed. No custom paths added to PATH"
	fi
fi


################ TERMINAL PROMPT SETTINGS -- FORMAT & COLOR
export PS1="\n\[\033[0;36m\]\h:\d: \w \u ▶ \[\033[0;m\]"  # cyan
export PS2="\[\033[0;31m\]▶▶ \[\033[0;m\]"               # red

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

