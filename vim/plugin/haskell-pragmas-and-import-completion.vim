" All code in one place for haskell pragma generation and completion.
"
" history: created APR 2023.
" author: Prem Muthedath

" ==============================================================================
" define directory and file paths as immutable values.
" for glob()`use, see /u/ martin tournoij @ https://tinyurl.com/2t7e3asj (so)
" on `..` use, see :h expr-..
const g:pdotfiles_dir = glob('~/dotfiles/')
const g:phask_data_dir = g:pdotfiles_dir .. 'vim/haskell/data/'

const g:phask_ops_ghc_orig_ifile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-ORIGINAL.txt'
const g:phask_ops_ghc_formatted_header_ifile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-FORMATTED--HEADER.txt'
const g:phask_ops_ghc_formatted_iofile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-FORMATTED.txt'

const g:phask_ops_ghc_parsed_ofile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-PARSED-LIST.txt'
const g:phask_lang_extns_ofile = g:phask_data_dir .. 'GHC-LANGUAGE-EXTENSIONS-SORTED-LIST.txt'
const g:phask_imp_modules_ofile = g:phask_data_dir .. 'ghcup-cabal-installed-modules.txt'

const g:phask_cabal_inst_pkgs_ofile = g:phask_data_dir .. 'cabal-installed-pkgs.txt'
const g:phask_ghcup_inst_pkgs_ofile = g:phask_data_dir .. 'ghcup-installed-pkgs.txt'

" ==============================================================================
" haskell pragma completion (in normal mode).
"  1. if current line is blank, inserts haskell pragma block at line start, 
"     positions the cursor inside the pragma block, and switches to insert mode.
"  2. else, adds a blank line right below, and does step 1 on the blank line.
"  3. this function takes 1 arg, the pragma string "LANGUAGE" or "OPTIONS_GHC".
" this code at this time is still experimental.
" author: Prem Muthedath
function! StartHaskellPragma(arg)
  " on `..` use, see :h expr-..
  " `normal!`: https://learnvimscriptthehardway.stevelosh.com/chapters/29.html
  let l:pragma = '{-# ' .. a:arg .. ' #-}'
  let l:cmdstr = 'normal! gI' .. l:pragma .. "\<Esc>" .. 'gE' .. 'a ' .. "\<Esc>" .. 'l'
  if getline('.') !~ '^$'
    :execute 'normal! o' .. "\<Esc>"
  endif
  :execute l:cmdstr | :startinsert
endfunction

" ==============================================================================
" these functions work together to format and generate OPTIONS_GHC flags.
function! GenerateOpsGhcFlags() abort
  :if g:pdotfiles_dir ==# ""
    :throw 'the required root directory `~/dotfiles/` DOES NOT EXIST.'
  :endif
  :call CreateFormattedOpsGhcFile()
  :call ParseOptionsGhcFlags()
  :let l:res = TestOpsGhcFlagsCount()
  :redraw!
  :return l:res
endfunction

function! CreateFormattedOpsGhcFile() abort
  :execute ":vsp" g:phask_ops_ghc_formatted_iofile
  :1,$d
  :execute ":1r" g:phask_ops_ghc_orig_ifile
  :1;/^=\+\s*+\+ OPTIONS_GHC FLAGS/-1d
  :execute ":0r" g:phask_ops_ghc_formatted_header_ifile
  :call FormatOptionsGhcFlagsFile()
  :execute 'normal! gg'
  :write
  :quit
endfunction

function! TestOpsGhcFlagsCount() abort
  :execute ":vsp" g:phask_ops_ghc_formatted_iofile
  :let ecnt = CountOptionsGhcFlags()
  :quit
  :execute ":vsp" g:phask_ops_ghc_parsed_ofile
  :let acnt = line('$')
  :quit
  :return {'actual' : acnt, 'expected' : ecnt, 'flag' : acnt == ecnt ? 'PASS' : 'FAIL' }
endfunction

function! DisplayFormattedAndGeneratedOpsGhcFlags() abort
  :execute ':vsp' g:phask_ops_ghc_formatted_iofile
  :execute ":sp" g:phask_ops_ghc_parsed_ofile
endfunction

" ==============================================================================
