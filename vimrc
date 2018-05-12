set number

syntax enable
set background=dark
colorscheme solarized

filetype plugin on

" customized file type settings
" see https://goo.gl/A8CCWo (ian langworth)
" .gitignore ft   -> git -> more readable  
" bash_profile ft -> sh  -> ~ .bash_profile  
au BufNewFile,BufRead .gitignore set ft=git  
au BufNewFile,BufRead bash_profile set ft=sh  
