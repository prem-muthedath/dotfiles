" vimrc -- author: Prem Muthedath, JUN 2018

" load modules -- keep the order!
source ~/dotfiles/vim/autocmd.vim
source ~/dotfiles/vim/commands.vim

" load ftplugin & indent files; highlight syntax
filetype plugin on
filetype indent on
syntax on

" set up colorscheme
set background=dark
colorscheme sorcerer

" use space for all indentation
set expandtab
set shiftwidth=2
set softtabstop=2

" `CTRL-K F B` to get space symbol in listchars;
" REF: see /u/ randy morris @ https://tinyurl.com/y97g3akv
set autoindent                                " auto indent for all ft
set number                                    " show line number
set wrap                                      " wrap lines (for display)
set textwidth=80                              " std textwidth; wrap lines beyond
set colorcolumn=+1                            " mark textwidth
set wildmenu                                  " <Tab> cl-completion
set wildcharm=<C-Z>                           " allow <Tab> in map completion
set listchars=space:█,trail:█,eol:¬,tab:▸\    " show these on :set list
set hlsearch                                  " highlight search ON, as default
set history=1000                              " keep large history

" format options: format comments but not code
set fo=
set fo+=c      " autowrap comments using textwidth
set fo+=o      " insert comment leader on press o
set fo+=r      " insert comment leader on return
set fo+=j      " smartly join two comments
set fo+=w      " spot as same paragraph if trailing whitespace
set fo+=l      " don't break existing long lines
set fo+=a      " autoformat paragraphs
set fo+=n      " spot numbered lists
set fo+=q      " allow gq to format
set fo-=t      " no text autowrap

" add these 'bullet' format list patterns to default
set flp+=\\\|^\\s*[-+*]\\+\\s\\+          " - , -- , + , ++ ,  * , ** , ...
set flp+=\\\|^\\s*\\w[.)]\\s\\+           " a. , a) , b. , b) , ...
set flp+=\\\|^\\s*[ivxIVX]\\+[.)]\\s\\+   " i. , i) , ii. , ii) , ...

" make your own statusline
set laststatus=2                          " statusline ON, always
set statusline=%t                         " filename
set statusline+=\ %y                      " file type
set statusline+=\ [%{&ff}]                " file format
set statusline+=\ fo:[%{&fo}]             " format options
set statusline+=\ cs:[%{g:colors_name}]   " colorscheme
set statusline+=%=                        " seperate left & right
set statusline+=\ [%l,%c]                 " line, column #
set statusline+=\ %r                      " readonly?
set statusline+=\ %m                      " file modified?

set fillchars=vert:\│                     " use this to show vsplit

" ignore these file extensions
set wildignore+=*.hi,*.o,*.class

" window settings
set splitright    " vertical right split
set splitbelow    " horizontal bottom split
set mouse=a       " no terminal scrollbar!

" dirs for backup and swap files
set backupdir=~/.vim/backup
set directory=~/.vim/swap

" mappings
" NOTE:  :w !pbcopy copies line selections to OSX system clipboard
"        see /u/ Brian @ https://tinyurl.com/y4n9njg7  (so)
"        for set list, see /u/ derrick zhang @ https://tinyurl.com/y7gk2ncg
"        ic: (in vsual mode), inserts vim-style comment (") @ line start.
"        rc: (in visual mode), removes symbol (typcally a comment) @ start.
"        ws: highlights blank lines & trailing white spaces.
nmap      sa    :SyntaxAttr<CR>
nmap      ch    :ToggleCommentHl<CR>
nmap      co    :colorscheme <C-Z><S-Tab>
nmap      ou    :OpenUrl<CR>
noremap   ts    :ToggleHlSearch<CR>
noremap   cs    :ClearSearch<CR>
nnoremap  tc    :ToggleComment<CR>
vnoremap  tc    :ToggleComments<CR>
nnoremap  sc    :StartComment<CR>
vnoremap  ic    :norm ^i" <CR>
vnoremap  rc    :norm ^x<CR>
vnoremap  ri    :Reindent<CR>
vmap      cp    :w !pbcopy<CR><CR>
map       sl    :set list! list? <CR>
nmap      ws    :/^\s\+$\\|\s\+$/ <CR>
" https://google.com


