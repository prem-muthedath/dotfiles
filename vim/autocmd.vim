augroup MyFileTypes
  autocmd!
  
  " customized file types -- see https://goo.gl/A8CCWo (ian langworth)
  "  -- bash_profile ft -> sh  -> ~ .bash_profile
  "  -- .gitignore ft  -> git -> more readable
  autocmd BufNewFile,BufRead bash_profile set ft=sh
  autocmd BufNewFile,BufRead .gitignore set ft=git
augroup end

augroup MyHighlights
  autocmd!
  " -- VertSplit, StatusLine/NC -> remove thick border!
  " -- EndOfBuffer -> remove ~; works only if vim >=8.0
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
augroup END

augroup MySyntax
  autocmd!
  " -- set preferences for raichoo's haskell syntax
  " -- for details, see https://github.com/neovimhaskell/haskell-vim
  autocmd Syntax haskell
        \ let g:haskell_classic_highlighting = 1
        \| let g:haskell_enable_quantification = 1
        \| let g:haskell_enable_recursivedo = 1
        \| let g:haskell_enable_pattern_synonyms = 1
augroup END




