" autocommands for vimrc.
" author: Prem Muthedath
" REF: https://learnvimscriptthehardway.stevelosh.com/chapters/12.html
" ==============================================================================

" autocommands for look-and-feel highlighting.
augroup MyHighlights
  autocmd!
  " -- VertSplit, StatusLine/NC -> remove thick border!
  " -- EndOfBuffer -> remove ~; works only if vim >=8.0
  " -- cursorline highlighting:
  "    https://vim.fandom.com/wiki/Highlight_current_line
  "    print highlight defns on commandline: `:highlight VertSplit`
  "    see /u/ ralph @ https://tinyurl.com/5rncjhwc (vi.SE)
  autocmd ColorScheme solarized
        \  highlight VertSplit ctermfg=fg ctermbg=0
        \| highlight StatusLine cterm=NONE
        \| highlight StatusLineNC cterm=NONE
        \| highlight EndOfBuffer ctermfg=bg
  autocmd ColorScheme apprentice,sorcerer
        \  highlight VertSplit ctermfg=fg ctermbg=0
        \| highlight StatusLine ctermfg=NONE ctermbg=238
        \| highlight StatusLineNC ctermfg=12 ctermbg=238
        \| highlight ColorColumn ctermbg=236
        \| highlight EndOfBuffer ctermfg=bg
        \| highlight Function ctermfg=31
        \| highlight CursorLine ctermbg=234
        \| highlight CursorColumn ctermbg=236
augroup END

" autocommands for setting haskell syntax preferences.
augroup MySyntax
  autocmd!
  " -- set preferences for raichoo's haskell syntax
  " -- for details, see https://github.com/raichoo/haskell-vim
  autocmd Syntax haskell
        \  let g:haskell_classic_highlighting = 1
        \| let g:haskell_enable_quantification = 1
        \| let g:haskell_enable_recursivedo = 1
        \| let g:haskell_enable_pattern_synonyms = 1
augroup END

augroup MyCommentStrings
" autocommands to set commentstring.
" REF: commentstring: /u/ kiteloopdesign @ https://tinyurl.com/rzu86654 (so)
" To DO: put each line in `~/.vim/ftplugin/` in their respective file.
  autocmd!
  autocmd FileType git setlocal commentstring=#\ %s
  autocmd FileType cabal setlocal commentstring=--\ %s
  autocmd FileType cabalconfig setlocal commentstring=--\ %s
augroup END

" autocommands to customize filetype.
" use `:setfiletype <Ctrl+D>` to list all filetypes; see:
" REF: https://vi.stackexchange.com/questions/5780/list-known-filetypes
" NOTE: no longer setting `ft` for `bash_profile`, as its `ft` is already `sh`.
" TO DO: put each of these `autocmd`s in a separate file in `~/.vim/ftdetect/`
augroup MyFileTypes
  " customized file types -- see https://goo.gl/A8CCWo (ian langworth)
  autocmd!
  "set .gitignore ft  -> git -> more readable
  autocmd BufNewFile,BufRead
        \ .gitignore
        \ setfiletype git
  " set file type for *.lhs files (i.e., literal haskell)
  autocmd BufNewFile,BufRead
        \ *.lhs
        \ setfiletype haskell
  " set file type for haskell cabal config, ghci.conf files
  autocmd BufNewFile,BufRead
        \ cabal.config
        \,cabal.config.*
        \,ghci.conf
        \,ghci.config
        \ setfiletype cabalconfig
augroup END

" cursorline should appear only for the current window.
" https://vim.fandom.com/wiki/Highlight_current_line
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END
" ==============================================================================
