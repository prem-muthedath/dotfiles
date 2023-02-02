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

" cursorline: https://vim.fandom.com/wiki/Highlight_current_line
set fillchars=vert:\│                     " use this to show vsplit
set cursorline                            " cursorline ON

" ignore these file extensions
set wildignore+=*.hi,*.o,*.class

" window settings
set splitright    " vertical right split
set splitbelow    " horizontal bottom split
set mouse=a       " no terminal scrollbar!

" dirs for backup and swap files
set backupdir=~/.vim/backup
set directory=~/.vim/swap

" set print font (used by `hardcopy` when generating `*.ps` file)
" syntax from /u/ doru @ https://tinyurl.com/y6t7rhck (linuxquestions.org)
" see also https://vimhelp.org/print.txt.html
set printfont=courier:h9

" mappings
" NOTE:  :w !pbcopy copies line selections to OSX system clipboard
"        see /u/ Brian @ https://tinyurl.com/y4n9njg7  (so)
"        for set list, see /u/ derrick zhang @ https://tinyurl.com/y7gk2ncg
"        ch: toggle comment highlighting in normal mode.
"        tc: toggle comments, both in visual and normal modes.
"        sc: in visual mode, start a comment, switching to insert mode.
"        ic: (in visual mode), inserts vim-style comment (") @ line start.
"        rc: (in visual mode), removes symbol (typcally a comment) @ start.
"        ws: highlights blank lines & trailing white spaces.
"        cl: toggle cursor line and cursor column,
"        https://vim.fandom.com/wiki/Highlight_current_line
nnoremap  sa    :SyntaxAttr<CR>
nnoremap  ch    :ToggleCommentHl<CR>
nnoremap  co    :colorscheme <C-Z><S-Tab>
nnoremap  ou    :OpenUrl<CR>
nnoremap  ts    :ToggleHlSearch<CR>
nnoremap  cs    :ClearSearch<CR>
nnoremap  tc    :ToggleComment<CR>
vnoremap  tc    :ToggleComments<CR>
nnoremap  sc    :StartComment<CR>
vnoremap  ic    :norm ^i" <CR>
vnoremap  rc    :norm ^x<CR>
vnoremap  ri    :Reindent<CR>
vnoremap  cp    :w !pbcopy<CR><CR>
map       sl    :set list! list? <CR>
nnoremap  ws    :/^\s\+$\\|\s\+$/ <CR>
nnoremap  cl    :set cursorline! cursorcolumn!<CR>

" these mappings below are for haskell completions in coc-vim
" REF: https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" this function simply re-organizes the code from the neoclide github page.
" this code, executed by `inoremap <expr>`, triggers haskell code completion.
" NOTE:
"   1. orig code returned "\<Tab>" if `CheckBackspace()` = true.
"   2. i removed "\<Tab>" because when preceeded by \s, it was inserting a \t.
"   3. the orig code used <Tab> as the map key.
"   4. so to free up <Tab> for normal use, the code had to return "\<Tab>".
"   5. i replaced <Tab> as the map key here.
"   6. so now the code returns the map key used if `CheckBackspace` = true.
"   7. also, the code completion now is triggered only for haskell files.
"   8. for non-haskell files, the code simply returns the map key.
"   9. `==#` is case sensitive string comparison, by the way.
" for <SID>, see https://vimdoc.sourceforge.net/htmldoc/map.html#script-local
" https://stackoverflow.com/questions/2779379/find-what-filetype-is-loaded-in-vim
function! <SID>haskellCompletion(map_key) abort
  if &filetype ==# 'haskell'
    return
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? a:map_key : coc#refresh()
  endif
  return a:map_key
endfunction

" `hc` mapping (i.e., by typing 'hc') brings up the haskell completion popup in 
" insert mode. you can then navigate the pop up, while remaining in insert mode, 
" using the built-in vim navigation with arrow keys.
" REF: https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources
" REF: https://vim.fandom.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
" for <SID>, see https://vimdoc.sourceforge.net/htmldoc/map.html#script-local
inoremap <silent><expr> hc <SID>haskellCompletion("hc")

" this insert-mode mapping confirms (by hitting `ENTER`) the haskell name 
" selection from the haskell completion pop up.
" REF: https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources
" REF: https://vim.fandom.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
" NOTE:
"   1. the code here uses <CR> as the map key.
"   2. it therefore needs to free up <CR> for normal use outside of the mapping.
"   3. that's why the code returns "\<CR>" when the coc pop up is not visible.
"   4. so if you do `<CR>` outside of the coc pop up, you'll get the usual <CR>.
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" https://google.com
