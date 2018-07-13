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

set autoindent                " auto indent for all ft
set number                    " show line number
set wrap                      " wrap lines (for display)
set textwidth=80              " std textwidth; wrap lines beyond
set colorcolumn=+1            " mark textwidth
set wildmenu                  " <Tab> cl-completion
set wildcharm=<C-Z>           " allow <Tab> in map completion
set listchars=eol:¬,tab:▸\    " show these on :set list
set hlsearch                  " highlight search ON, as default

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
set flp+=\\\\|^\\s*[\\-\\+\\*]\\+\\s\\+     " - , -- , + , ++ ,  * , ** , ...
set flp+=\\\\|^\\s*\\w[.\)]\\s\\+           " a. , a) , b. , b) , ...
set flp+=\\\\|^\\s*[ivxIVX]\\+[.\)]\\s\\+   " i. , i) , ii. , ii) , ...

" make your own statusline
set laststatus=2                          " statusline ON, always
set statusline=%t                         " tail of file name
set statusline+=\ %y                      " file type
set statusline+=\ [%{&ff}]                " file format
set statusline+=\ fo:[%{&fo}]             " format options
set statusline+=\ cs:[%{g:colors_name}]   " colorscheme
set statusline+=%=                        " seperate left & right
set statusline+=\ [%l,%c]                 " line, column #
set statusline+=\ %r                      " readonly?
set statusline+=\ %m                      " file modified?

set fillchars=vert:\│                     " use this to show vsplit

" window settings
set splitright    " vertical right split
set splitbelow    " horizontal bottom split
set mouse=a       " no terminal scrollbar!


" mappings
nmap      sa    :SyntaxAttr<CR>
nmap      ch    :ToggleCommentHl<CR>
nmap      co    :colorscheme <C-Z><S-Tab>
nmap      ou    :OpenUrl<CR>
noremap   ts    :ToggleHlSearch<CR>
noremap   cs    :ClearSearch<CR>
noremap   tc    :ToggleComment<CR>
vnoremap  tc    :ToggleComments<CR>
vnoremap  ic    :norm ^i" <CR>
vnoremap  rc    :norm ^x<CR>

" https://google.com

