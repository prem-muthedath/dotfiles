" ==============================================================================
" haskell omnicompletion for pragmas and module imports.
" completion available for GHC language extensions, OPTIONS_GHC values, and 
" modules installed by cabal and ghcup in Prem's system.
"
" this code is modeled after:
"   1. sample code given in :help compl-omni, :h complete-functions
"   2. code by /u/ statox @ https://tinyurl.com/3fxk9a62 (vi.SE)
"   3. default haskell omnicompletion in vim 8.2 by /u/ dundargoc @ 
"      https://tinyurl.com/242xb23x (github)
"
" author: Prem Muthedath
" APR 2023.
"
" NOTE: Prem wrote this code, because the default haskell omnicompletion in vim 
" 8.2 is buggy.  in particular, it does not correctly refresh the menu values.
" ==============================================================================
" on `==#`, see https://learnvimscriptthehardway.stevelosh.com/chapters/22.html
" on `..` use, see :h expr-..
let b:complete = ""
function! haskellcomplete#Complete(findstart, base)
  if a:findstart
    "locate the start of the word
    let l:line  = getline('.')
    let l:start = col('.') - 1
    while l:start > 0 && l:line[start -1] !~ '\s'
      let l:start -= 1
    endwhile
    if l:line =~# '^\s*{-#\s\+LANGUAGE\s\+'
      let b:complete = 'LANGUAGE-EXTENSION'
    elseif l:line =~# '^\s*{-#\s\+OPTIONS_GHC\s\+'
      let b:complete = 'OPTIONS-GHC'
    elseif l:line =~# '^import\s\+'
      let b:complete = 'IMPORT'
    endif
    return l:start
  else
    " find the right type of things matching with "a:base"
    let l:res = []
    if a:base ==# ""
      return s:allValues()
    endif
    for m in s:allValues()
      if m =~# '^' .. a:base
        call add(l:res, m)
      endif
    endfor
    return l:res
  endif
  " reset the flag value; otherwise, we risk carrying on with the old value.
  let b:complete = ""
endfunc

" ==============================================================================
" returns all omnicompletion values associated with the completion flag.
" NOTE: returned values correspond to GHC 8.10.4
" for glob()`use, see /u/ martin tournoij @ https://tinyurl.com/2t7e3asj (so)
" on `==#`, see https://learnvimscriptthehardway.stevelosh.com/chapters/22.html
" on `..` use, see :h expr-..
function! s:allValues()
  let l:dpath = glob('~/dotfiles/vim/haskell/data/')
  if b:complete ==# "LANGUAGE-EXTENSION"
    return readfile(l:dpath .. 'GHC-LANGUAGE-EXTENSIONS-SORTED-LIST.txt')
  elseif b:complete ==# "OPTIONS-GHC"
    return readfile(l:dpath .. 'OPTIONS-GHC-FLAGS-PARSED-LIST.txt')
  elseif b:complete ==# "IMPORT"
    return readfile(l:dpath .. 'cabal-ghcup-installed-modules.txt')
  else
    return []
  endif
endfunc

" ==============================================================================
