" ==============================================================================
" haskell omnicompletion for pragmas and module imports.
" completion available for GHC language extensions, OPTIONS_GHC values, and 
" modules installed by cabal and ghcup in Prem's system.
"
" this code is modeled after:
"   1. sample code given in :help compl-omni, :h complete-functions
"   2. code by /u/ statox @ https://tinyurl.com/xn6fbrmm (vi.SE)
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
    else
      let b:complete = ""
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
endfunc

" ==============================================================================
" returns all omnicompletion values associated with the completion flag.
" on `==#`, see https://learnvimscriptthehardway.stevelosh.com/chapters/22.html
" immutable global variables, such as g:phask_ops_ghc_parsed_ofile, come from 
" vim/plugin/haskell-pragma-import.vim.
function! s:allValues()
  if b:complete ==# "LANGUAGE-EXTENSION"
    return readfile(g:phask_lang_extns_ofile)
  elseif b:complete ==# "OPTIONS-GHC"
    return readfile(g:phask_ops_ghc_parsed_ofile)
  elseif b:complete ==# "IMPORT"
    return readfile(g:phask_imp_modules_ofile)
  else
    return []
  endif
endfunc

" ==============================================================================
