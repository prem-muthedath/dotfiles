augroup MyFileTypes
  autocmd!
  
  " customized file types -- see https://goo.gl/A8CCWo (ian langworth)
  "  -- bash_profile ft -> sh  -> ~ .bash_profile
  "  -- .gitignore ft  -> git -> more readable
  autocmd BufNewFile,BufRead bash_profile set ft=sh
  autocmd BufNewFile,BufRead .gitignore set ft=git
augroup end

augroup MyHighlights
    "  -- VertSplit, StatusLine/NC -> remove thick border!
    "  -- EndOfBuffer -> remove ~; works only if vim >=8.0
    autocmd!
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




