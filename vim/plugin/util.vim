" This has just a collection of utility functions written as and when needed.
"
" history: created 7 - 28 AUG 2018.
" author: Prem Muthedath

" ==============================================================================
function! FormatCsFile()
  " Format file -- such as ~/dotfiles/vim/arch/notes/cs.vim -- containing list
  " of filenames and &comments into neatly separated columns.
  " sample output: ~/dotfiles/vim/arch/notes/cs-col.vim
  " author: Prem Muthedath, 2018.
  "
  " NOTe: `Cs` stands for comment symbol.
  "
  " usage:
  "   1) cpoy ~/dotfiles/vim/arch/notes/cs.vim;
  "   2) then open the copy in vim;
  "   3) and invoke :call FormatCsFile() from vim commandline.
  "
  " NOTES: this function's structure is same as `FormatOptionsGhcFlagsFile()` in 
  " vim/plugin/haskell-pragma-and-import-completion.vim, even though the format 
  " of input file here is different, so the overall flow of extensive comments 
  " given for `FormatOptionsGhcFlagsFile()` applies here.
  " see below REFs for :execute and `normal` and `normal!` usage:
  "   1. https://learnvimscriptthehardway.stevelosh.com/chapters/28.html
  "   2. https://learnvimscriptthehardway.stevelosh.com/chapters/29.html
  "   3. https://learnvimscriptthehardway.stevelosh.com/chapters/30.html
  " on `..` use, see :h expr-..
  let l:maxcol=0
  g/vim:/
        \ execute 'normal! ' .. '/^.*vim:/e' .. "\<CR>"
        \ | let l:maxcol = max([l:maxcol, virtcol('.')])
  g/vim:/
        \ execute 's/\(^\S\+\.vim:\)[^=]*\(comment\|com\)/\1\2'
        \ | execute 'normal! ' .. '/^.*vim:/e' .. "\<CR>"
        \ | let l:diff = l:maxcol - virtcol('.') + 3
        \ | execute 'normal! a' .. repeat(" ", l:diff)
endfunction

" ==============================================================================
