" open url under cursor; plugin: OpenUrl
command! OpenUrl call OpenUrlUnderCursor()

" for item below cursor, show highlight info; plugin: SyntaxAttr
command! SyntaxAttr call SyntaxAttr()

" toggle comment highlighting
function! s:toggleCommentHl(comment_hl) abort
  " Redirect output of :highlight to l:current
  redir => l:current
  silent highlight Comment
  redir END

  if l:current =~# a:comment_hl
    execute "colorscheme " . g:colors_name
  else
    execute "highlight Comment " . a:comment_hl
  endif
endfunction
command! ToggleCommentHl call s:toggleCommentHl('ctermfg=245')

" hl search -- toggle, clear (pattern)
command! ToggleHlSearch set hls! | set hls?
command! ClearSearch let @/=""

" toggle comments -- current line | range, visual mode; plugin: ToggleComment
command! ToggleComment .call ToggleComments()
command! -range=% ToggleComments <line1>,<line2>call ToggleComments()

" start a comment line in insert mode:
"   -- if current line empty, make it a comment;
"   -- otherwise, start a new comment line right below current line
function! s:startcomment()
  let l:execstr = getline('.') =~ '^$' ?
        \ 'normal 0' . 'tc' . '==' :
        \ 'normal o' . "\<Esc>" . 'tc' . '=='
  if len(Cs()) == 1
    :execute l:execstr | :startinsert!
  else
    let l:cursorshift = len(Cs()[0]) + 1
    :execute l:execstr . '^' . l:cursorshift . 'l' | :startinsert
  endif
endfunction
command! StartComment call s:startcomment()

" reindent a block of lines -- preserves trailing spaces; plugin: Reindent
command! -range=% Reindent <line1>,<line2>call Reindent()

