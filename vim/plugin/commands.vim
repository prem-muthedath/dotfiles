" user-defined commands.
" author: Prem muthedath

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
" NOTE: @/ is the search register.
command! ToggleHlSearch set hls! | set hls?
command! ClearSearch let @/=""

" toggle comments -- current line | range, visual mode; plugin: ToggleComment
command! ToggleComment .call ToggleComments()
command! -range=% ToggleComments <line1>,<line2>call ToggleComments()

" ==============================================================================
" start a comment line in normal mode and then switch to insert mode.
"   -- if current line empty, make it a comment;
"   -- otherwise, start a new comment line right below current line
"   logical flow:
"     a) we treat 1-part and 3-part comment separately;
"     b) for both types of comment, however, the high-level logic is the same;
"     c) here is the high-level logic:
"         -- check if we've a blank line; if yes, make it a comment using `tc`;
"         -- if not, then check if the line is a comment; if yes, then start a 
"            comment line right below the current line, with same indent, using 
"            the `normal o` operation.
"         -- if the line is neither blank nor a comment, then start a comment 
"            right below the current line, with the same indent, using `tc`.
"     d) if we come across a file whose comment string, denoted by Cs(), is 
"        neither 1-part nor 3-part, then throw an error.
" ==============================================================================
function! s:startcomment() abort
  let l:emptyline = '^$'
  if len(Cs()) == 1       " 1-part comment (for example, vim comment)
    " ==========================================================================
    " what really happens, especially with cursor positions, in all these 
    " commands?  well, below is a step-by-step look for a vim file.
    " NOTE: `==` => indent current line.
    " 1. blank line:
    "     CURSOR at ^   -> originally
    "     CURSOR at ^   -> after 'normal 0'
    "     "CURSOR       -> after 'normal 0' . 'tc'
    "     "CURSOR       -> after 'normal 0' . 'tc' . '=='
    "     " CURSOR      -> after :startinsert!
    " 2. comment line:
    "     " blahh       -> originally, CURSOR somewhere on this line
    "     " CURSOR      -> after 'normal o' (new line right below `" blahh`)
    "     CUR"SOR       -> after 'normal o' . "\<Esc>"
    "     " CURSOR      -> after 'normal o' . "\<Esc>" . 'A' . ' '
    "     "CURSOR       -> after 'normal o' . "\<Esc>" . 'A' . ' ' .  "\<Esc>"
    "     " CURSOR      -> after :startinsert!
    " 3. non-comment line:
    "     blahh         -> originally, CURSOR somewhere on this line
    "     CURSOR @ ^    -> after 'normal o' (new line right below `blahh`)
    "     CURSOR @ ^    -> after 'normal o' . "\<Esc>"
    "     "CURSOR       -> after 'normal o' . "\<Esc>" . 'tc'
    "     "CURSOR       -> after 'normal o' . "\<Esc>" . 'tc' . '=='
    "     " CURSOR      -> after :startinsert!
    " ==========================================================================
    let l:samelinecmt   = 'normal 0' . 'tc' . '=='
    " pattern to test if line is comment; for vim file, this would be: ^\s*".*$
    let l:comment       = '^'. '\s*' . escape(Cs()[0], ' *\') . '.*$'
    let l:nextlineOcmt  = 'normal o' . "\<Esc>" . 'A' . ' ' . "\<Esc>"
    let l:nextlinecmt   = 'normal o' . "\<Esc>" . 'tc' . '=='
    let l:execstr       =
            \ getline('.') =~ l:emptyline ? l:samelinecmt :
            \ getline('.') =~ l:comment ? l:nextlineOcmt : l:nextlinecmt
    :execute l:execstr | :startinsert!
  elseif len(Cs()) == 3   " 3-part comment (for example, C block comment)
    " ==========================================================================
    " why do we need a cursor shift?
    "
    " well, when we do a 3-part comment using `tc`, the cursor is positioned 
    " right after the closing comment at the end of the line.  for a C comment, 
    " it would look like this (in normal mode):
    "
    "         /*  */CURSOR
    "
    " now, we want the cursor to be within the comment block, when we switch to 
    " insert mode from normal mode, like this:
    "
    "         /* CURSOR*/
    "
    " how to do that?  well, here are the steps:
    "   1. first move the cursor to 1st non-blank char on the line, using ^ in 
    "      normal mode:
    "
    "         CURSOR/*  */
    "
    "   2. then, remaining in normal mode, shift cursor by len(Cs()[0]) + 1 to 
    "      the right.  for C-comment, this shift would be 3l, 'l' implying right 
    "      motion. 3l means move 3 positions to the right of ^, so the cursor 
    "      will be on the 4th position from ^. also, 3 because '/*' has len 2, 
    "      so 2 + 1 = 3. so now we have the cursor like this (in normal mode):
    "
    "         /* CURSOR*/
    "
    "   3. now if we do `:startinsert`, we'll switch to insert mode, but the 
    "      cursor will remain at the same position:
    "
    "         /* CURSOR*/
    "
    "   4. if we want the cursor to move 1 more position to the right, as we do 
    "      when we do a `nextlineOcmt`, when we switch to insert mode, we can 
    "      use `:starinsert!`:
    "         /* abc    -> CURSOR originally positioned somewhere on this line
    "          * blah*/
    "
    "         /* abc
    "          * CURSOR -> after 'normal o'
    "          * blah*/
    "
    "         /* abc
    "          CUR*SOR  -> after 'normal o' .  "\<Esc>"
    "          * blah*/
    "
    "         /* abc
    "          * CURSOR -> after 'normal o' .  "\<Esc>" . 'A' . ' '
    "          * blah*/
    "
    "         /* abc
    "          *CURSOR  -> after 'normal o' .  "\<Esc>" . 'A' . ' ' .  "\<Esc>"
    "          * blah*/
    "
    "         /* abc
    "          * CURSOR -> after :startinsert!
    "          * blah*/
    " ==========================================================================
    let l:cursorshift   = len(Cs()[0]) + 1
    let l:samelinecmt   = 'normal 0' . 'tc' . '==' . '^' . l:cursorshift . 'l'
    " ==========================================================================
    " pattern to test if line is a "part" comment, what does this mean?
    "   1. "part" comment means that the line has a comment symbol at the start 
    "      (for C, /* or *) but no closing comment symbol (*/ for C) at the end.
    "   2. lines starting with end-of-line or closing comment symbol (*/ for C 
    "      files) are not "part" comments.
    "   3. "part" comment does not mean invalid comment. so you can not have a 
    "      line as part comment when it ends with the starting comment symbol 
    "      (for C, this would be /*), as this would be an invalid comment.
    "
    " for C-style comment, "part" comment pattern would be:
    "       ^\s*\(\*/\)\@!\(/\*\|\*\).*\(/\*\|\*/\)\@<!$
    "
    "       ^                   => match from line start
    "       \s*                 => match 0 or more spaces from line start
    "       \(\*/\)\@!          => not followed by */
    "       \(/\*\|\*\)         => match for either /* or *
    "       .*                  => match any following char 0 or more times
    "       \(/\*\|\*/\)\@<!$   => line end ($) not preceeded by /* or */
    "
    " how would this pattern match? some example lines:
    "       /* abcd     -> match
    "        * efg      -> match
    "        * ghf */   -> no match
    " more example lines:
    "       /* abcd */  -> no match
    "
    "       /* abcd /*  -> no match
    " and more example lines:
    "       /* abcd /   -> match
    "
    "       /* abcd **  -> match
    "
    "       /*          -> match
    "        * abc /*   -> no match
    "        * ghf **   -> match
    "        * xyz /    -> match
    "        * klm      -> match
    "        */         -> no match
    "
    "        */ klm     -> no match
    " NOTE:
    " 1. for grouping as an atom, using `\(\)`, see :help /magic and look for 
    "    the below line in the help file:
    "       \(\.$\|\. \)	    A period followed by <EOL> or a space.
    " 2. see :help escape()
    " 3. see :help /\@!
    "       foo\(bar\)\@!	    any "foo" not followed by "bar"
    " 4. for use of '\@<!$', see /u/ merlyn morgan-graham @ 
    "    https://tinyurl.com/ymx2sewu (so); also, see :help /\@<!
    "       \(foo\)\@<!bar	    any "bar" that's not in "foobar"
    " 5. we restricted ourselves to "part" comment, because using 'normal o' to 
    "    insert a comment line below only works for "part" comment lines.
    " ==========================================================================
    let l:partcomment   = '^'
                          \ . '\s*'
                          \ . '\('
                            \ . escape(Cs()[2], ' *\')
                          \ . '\)\@!'
                          \ . '\('
                            \ . escape(Cs()[0], ' *\')
                            \ . '\|'
                            \ . escape(Cs()[1], ' *\')
                          \ . '\)'
                          \ . '.*'
                          \ . '\('
                            \ . escape(Cs()[0], ' *\')
                            \ . '\|'
                            \ . escape(Cs()[2], ' *\')
                          \ . '\)\@<!$'
    let l:nextlineOcmt  = 'normal o' . "\<Esc>" . 'A' . ' ' . "\<Esc>"
    let l:nextlinecmt   = 'normal o' . "\<Esc>" . 'tc' . '==' . '^' . l:cursorshift . 'l'
    " see :help :starinsert
    if getline('.') =~ l:emptyline
      :execute l:samelinecmt | :startinsert
    elseif getline('.') =~ l:partcomment
      :execute l:nextlineOcmt | :startinsert!
    else
      :execute l:nextlinecmt | :startinsert
    endif
  else
    :throw "ERROR: comment string neither 1-part nor 3-part; start comment failed."
  endif
endfunction
command! StartComment call s:startcomment()

" reindent a block of lines -- preserves trailing spaces; plugin: Reindent
command! -range=% Reindent <line1>,<line2>call Reindent()

