" ==============================================================================
" code to start a comment.
"
" history:
"   originally written (in commands.vim) in JUL 2018.
"   substantially revised in FEB 2023.
"   file created on 28 FEB 2023.
"
" author: Prem Muthedath
" ==============================================================================
" start a comment line in normal mode and then switch to insert mode.
"   -- if current line empty, make it a comment;
"   -- otherwise, start a new comment line right below current line
"   logical flow:
"     a) we treat 1-part and 3-part comment separately;
"     b) for both types of comment, however, the high-level logic is the same;
"     c) here is the high-level logic:
"         -- check if we've a blank line; if yes, make it a comment using `_tc`;
"         -- if not, then check if the line is a comment; if yes, then start a 
"            comment line right below the current line, with same indent, using 
"            the `normal o` operation.
"         -- if the line is neither blank nor a comment, then start a comment 
"            right below the current line, with the same indent, using `_tc`.
"     d) if we come across a file whose comment string, denoted by Cs(), is 
"        neither 1-part nor 3-part, then throw an error.
" ==============================================================================
  " on `..` use, see :h expr-..
  " `normal!`: https://learnvimscriptthehardway.stevelosh.com/chapters/29.html
" ==============================================================================
function! StartComment() abort
  let l:emptyline = '^$'
  if len(Cs()) == 1       " 1-part comment (for example, vim comment)
    " ==========================================================================
    " what really happens, especially with cursor positions, in all these 
    " commands?  well, below is a step-by-step look for a vim file.
    " NOTE: `==` => indent current line.
    " 1. blank line:
    "     CURSOR at ^   -> originally
    "     CURSOR at ^   -> after 'normal 0'
    "     "CURSOR       -> after 'normal 0' .. '_tc'
    "     "CURSOR       -> after 'normal 0' .. '_tc' .. '=='
    "     " CURSOR      -> after :startinsert!
    " 2. comment line:
    "     " blahh       -> originally, CURSOR somewhere on this line
    "     " CURSOR      -> after 'normal! o' (new line right below `" blahh`)
    "     CUR"SOR       -> after 'normal! o' .. "\<Esc>"
    "     " CURSOR      -> after 'normal! o' .. "\<Esc>" .. 'A' .. ' '
    "     "CURSOR       -> after 'normal! o' .. "\<Esc>" .. 'A' .. ' ' ..  "\<Esc>"
    "     " CURSOR      -> after :startinsert!
    " 3. non-comment line:
    "     blahh         -> originally, CURSOR somewhere on this line
    "     CURSOR @ ^    -> after 'normal o' (new line right below `blahh`)
    "     CURSOR @ ^    -> after 'normal o' .. "\<Esc>"
    "     "CURSOR       -> after 'normal o' .. "\<Esc>" .. '_tc'
    "     "CURSOR       -> after 'normal o' .. "\<Esc>" .. '_tc' .. '=='
    "     " CURSOR      -> after :startinsert!
    " ==========================================================================
    let l:samelinecmt   = 'normal 0' .. '_tc' .. '=='
    " pattern to test if line is comment; for vim file, this would be: ^\s*".*$
    let l:comment       = '^' .. '\s*' .. escape(Cs()[0], ' *\') .. '.*$'
    let l:nextlineOcmt  = 'normal! o' .. "\<Esc>" .. 'A' .. ' ' .. "\<Esc>"
    let l:nextlinecmt   = 'normal o' .. "\<Esc>" .. '_tc' .. '=='
    let l:execstr       =
            \ getline('.') =~ l:emptyline ? l:samelinecmt :
            \ getline('.') =~ l:comment ? l:nextlineOcmt : l:nextlinecmt
    :execute l:execstr | :startinsert!
  elseif len(Cs()) == 3   " 3-part comment (for example, C block comment)
    " ==========================================================================
    " why do we need a cursor shift?
    "
    " well, when we do a 3-part comment using `_tc`, the cursor is positioned 
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
    "         CUR/SOR*  */
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
    "          * CURSOR -> after 'normal! o'
    "          * blah*/
    "
    "         /* abc
    "          CUR*SOR  -> after 'normal! o' ..  "\<Esc>"
    "          * blah*/
    "
    "         /* abc
    "          * CURSOR -> after 'normal! o' ..  "\<Esc>" .. 'A' .. ' '
    "          * blah*/
    "
    "         /* abc
    "          *CURSOR  -> after 'normal! o' ..  "\<Esc>" .. 'A' .. ' ' ..  "\<Esc>"
    "          * blah*/
    "
    "         /* abc
    "          * CURSOR -> after :startinsert!
    "          * blah*/
    " ==========================================================================
    let l:cursorshift   = len(Cs()[0]) + 1
    let l:samelinecmt   = 'normal 0' .. '_tc' .. '==' .. '^' .. l:cursorshift .. 'l'
    " ==========================================================================
    " pattern to test if line is a "part" comment, what does this mean?
    "   1. "part" comment means that the line has a comment symbol (for C, /* or 
    "      *) at start, ignoring spaces, but no closing comment symbol (*/ for 
    "      C) anywhere on the line.
    "   2. lines with end-of-line or closing comment symbol (*/ for C files) at 
    "      the start, ignoring spaces, are not "part" comments, even though they 
    "      may be the end of a comment block.
    "   3. also, "part" comment is part of a valid comment. it therefore follows 
    "      the rules set out for what is considered to be a comment. for 
    "      example, in C (see C language reference manual, columbia univ, 
    "      chapter 3, "Lexical Conventions"), a valid comment is defined as:
    "
    "         The /* characters introduce a comment; the */ characters terminate 
    "         a comment. They do not indicate a comment when occurring within a 
    "         string literal. Comments do not nest. Once the /* introducing a 
    "         comment is seen, all other characters are ignored until the ending 
    "         */ is encountered.
    "
    "   4. so, for example, in C,
    "         ^/* abcd /* my /* ** hello   -> valid part comment (rules 1, 3)
    "         ^/* abcd */ hello there      -> not a part comment (rule 1)
    "         ^\s */ abcd                  -> not a part comment (rule 2)
    "         ^\s/* abacd                  -> valid part comment (rule 1)
    "             * ghj                    -> valid part comment (rule 1)
    "             * xyz */                 -> not a part comment (rule 1)
    "         ^ function foo() { /*blah*/  -> not a part comment (rule 1)
    "             doSomething
    "           }
    "         ^ function foo() { /* blah   -> not a part comment (rule 1)
    "                             * blah
    "                             */
    "             doSomething
    "           }
    "   5. we assume here that block comments, wherever they are, obey the same 
    "      rules stated in the C manual -- that comments are not nested, etc.
    "
    " for C-style comment, "part" comment pattern would be:
    "       ^\%(.*\*/\)\@!\s*\(/\*\|\*\)
    "
    "       NOTE: "\%(" just like `\(' but defines the group without counting it 
    "       as a sub-expression. so you can not refer to the text matched by 
    "       this group using \1. see /u/ luc hermitte @ 
    "       https://tinyurl.com/mr6uvsj6 (vi.SE), :help \(
    "
    "       ^                   => match from line start
    "       \%(.*\*/\)\@!       => line has no `*/` anywhere
    "       \s*                 => match 0 or more spaces from line start
    "       \(/\*\|\*\)         => match for either /* or *
    "
    " how would this pattern match? some example lines:
    "       ^/* abcd             -> match
    "       ^ * efg              -> match
    "       ^ * ghf */           -> no match
    " more example lines:
    "       ^/* abcd */          -> no match
    "
    "       ^/* abcd */  pqrs    -> no match
    "
    "       ^/* abcd */\s\s\s    -> no match
    "
    "       ^/* abcd /*          -> match
    "
    "       ^ /* abcd /*         -> match
    "
    "       ^/* abcd /* jkl      -> match
    " and more example lines:
    "       ^/* abcd /           -> match
    "
    "       ^/* abcd **          -> match
    "
    "       ^\s\s/* abcd /       -> match
    "
    "       ^\sblah/* abcd       -> no match
    "
    "       ^/*                  -> match
    "       ^ * abc /*           -> match
    "       ^ * ghf **           -> match
    "       ^ * xyz /            -> match
    "       ^ * klm              -> match
    "       ^ \s\s * xyz         -> match
    "       ^*/                  -> no match
    "
    "       ^\s\s*/              -> no match
    "
    "       ^*/ klm              -> no match
    " NOTE:
    " 1. for grouping as an atom, using `\(\)`, see :help /magic and look for 
    "    the below line in the help file:
    "       \(\.$\|\. \)	    A period followed by <EOL> or a space.
    " 2. see :help escape()
    " 3. see :help /\@!
    "       foo\(bar\)\@!	    any "foo" not followed by "bar"
    "       if \(\(then\)\@!.\)*$   "if " not followed by "then"
    "       Useful example: to find "foo" in a line that does not contain "bar":
    "             /^\%(.*bar\)\@!.*\zsfoo
    "       This pattern first checks that there is not a single position in the
    "       line where "bar" matches.  If ".*bar" matches somewhere the \@! will
    "       reject the pattern.  When there is no match any "foo" will be found.
    "       The "\zs" is to have the match start just before "foo".
    "
    "       "\%(" just like `\(' but defines the group without counting it as a 
    "       sub-expression. so you can not refer to the text matched by this 
    "       group using \1. see /u/ luc hermitte @ https://tinyurl.com/mr6uvsj6 
    "       (vi.SE), :help \(
    " 4. we restricted ourselves to "part" comment, because using 'normal! o' to 
    "    insert a comment line below only works for "part" comment lines.
    " ==========================================================================
    let l:partcomment   = '^'
                          \ .. '\%('
                            \ .. '.*'
                            \ .. escape(Cs()[2], ' *\')
                          \ .. '\)\@!'
                          \ .. '\s*'
                          \ .. '\('
                            \ .. escape(Cs()[0], ' *\')
                            \ .. '\|'
                            \ .. escape(Cs()[1], ' *\')
                          \ .. '\)'
    let l:nextlineOcmt  = 'normal! o' .. "\<Esc>" .. 'A' .. ' ' .. "\<Esc>"
    let l:nextlinecmt   = 'normal o' .. "\<Esc>" .. '_tc' .. '==' .. '^' .. l:cursorshift .. 'l'
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
" ==============================================================================
