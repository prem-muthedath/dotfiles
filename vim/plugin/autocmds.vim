" author: Prem Muthedath
" REF: https://learnvimscriptthehardway.stevelosh.com/chapters/12.html
augroup MyHighlights
  autocmd!
  " -- VertSplit, StatusLine/NC -> remove thick border!
  " -- EndOfBuffer -> remove ~; works only if vim >=8.0
  " -- cursorline highlighting:
  "    https://vim.fandom.com/wiki/Highlight_current_line
  autocmd ColorScheme solarized
        \ highlight VertSplit ctermfg=fg ctermbg=0
        \| highlight StatusLine cterm=NONE
        \| highlight StatusLineNC cterm=NONE
        \| highlight EndOfBuffer ctermfg=bg
  autocmd ColorScheme apprentice,sorcerer
        \ highlight VertSplit ctermfg=fg ctermbg=0
        \| highlight StatusLine ctermfg=NONE ctermbg=238
        \| highlight StatusLineNC ctermfg=12 ctermbg=238
        \| highlight ColorColumn ctermbg=236
        \| highlight EndOfBuffer ctermfg=bg
        \| highlight Function ctermfg=31
        \| highlight CursorLine ctermbg=234
        \| highlight CursorColumn ctermbg=236
augroup END

augroup MySyntax
  autocmd!
  " -- set preferences for raichoo's haskell syntax
  " -- for details, see https://github.com/raichoo/haskell-vim
  autocmd Syntax haskell
        \ let g:haskell_classic_highlighting = 1
        \| let g:haskell_enable_quantification = 1
        \| let g:haskell_enable_recursivedo = 1
        \| let g:haskell_enable_pattern_synonyms = 1
augroup END

augroup MyFileTypes
  " customized file types -- see https://goo.gl/A8CCWo (ian langworth)
  autocmd!
  "  bash_profile ft -> sh  -> ~ .bash_profile
  autocmd BufNewFile,BufRead bash_profile set ft=sh
  autocmd BufNewFile,BufRead bash_profile set syntax=sh
  " .gitignore ft  -> git -> more readable
  autocmd BufNewFile,BufRead .gitignore set ft=git
  autocmd BufNewFile,BufRead .gitignore set syntax=git
  " set file type & syntax for *.cabal files.
  autocmd BufNewFile,BufRead *.cabal set ft=haskell
  autocmd BufNewFile,BufRead *.cabal set syntax=haskell
  " set file type & syntax for *.lhs files (i.e., literal haskell)
  autocmd BufNewFile,BufRead *.lhs set ft=haskell
  autocmd BufNewFile,BufRead *.lhs set syntax=haskell
augroup END

" cursorline should appear only for the current window.
" https://vim.fandom.com/wiki/Highlight_current_line
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END
