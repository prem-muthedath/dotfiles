set number

syntax enable
set background=dark
colorscheme solarized

filetype plugin on

" .gitignore ft set as git -> more readable  
"  see https://goo.gl/A8CCWo (ian langworth)
au BufNewFile,BufRead .gitignore set ft=git  
