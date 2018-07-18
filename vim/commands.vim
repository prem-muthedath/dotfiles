" open url under cursor; plugin: OpenUrl
command! OpenUrl call OpenUrlUnderCursor()

" for item below cursor, show highlight info; plugin: SyntaxAttr
command! SyntaxAttr call SyntaxAttr()

" toggle comment highlighting
function! s:ToggleCommentHl(comment_hl) abort
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
command! ToggleCommentHl call s:ToggleCommentHl('ctermfg=245')

" hl search -- toggle, clear (pattern)
command! ToggleHlSearch set hls! | set hls?
command! ClearSearch let @/=""

" toggle comments -- current line | range, visual mode; plugin: ToggleComment
command! ToggleComment call ToggleComment()
command! -range=% ToggleComments <line1>,<line2>call ToggleComment()


