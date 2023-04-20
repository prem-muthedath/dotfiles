" source: https://gist.github.com/dave-kennedy/2188b3dd839ac4f73fe298799bb15f3b
" -- orig source: https://stackoverflow.com/a/24046914/2571881
" -- dave-kennedy's code a refinement of so code. for an exact copy of dave 
"    kennedy's code, see  ~/dotfiles/vim/arch/ext/togglecomment.vim
" Prem:
"   --  entirely re-designed -> almost no resemblance to dave-kennedy's code
"   --  handles both 1-part & 3-part (c-style) comments
"   --  extracts comment symbols from &commestring and &comments
"   --  uses normal mode commands, almost entirely, for comment/uncomment
"
" history: created, edited 13 JUL -- 29 AUG 2018.
" author: Prem Muthedath.

function! s:emptyllendpat() abort
  " Return regex pattern for end of an empty last line (ll) in comment block
  " for 3-part comment:
  "   -- '^\s*$' -> end of an empty uncommented ll
  "   -- s:esc(Cs()[2]) -> end of an empty commented ll
  " for 1-part comment:
  "   -- '$a' -> matches nothing, as we don't need to match 'end' of line
  if len(Cs()) > 1
    return '^\s*$' .. '\|^\s*' .. s:esc(Cs()[2])
  endif
  return '$a'
endfunction

function! s:uncomment1(first) abort
  " Uncomment the line + remove 1 space, if any, that immediately follows
  "
  " 'uncomment' here means finding and removing the comment symbol that occurs 
  " at, or somewhere near, the line start, ignoring spaces. this works fine for 
  " a 1-part comment, such as " in vim, but for block comments, such as /* ...  
  " */ in C, this function will only remove the starting comment symbol; you 
  " will then need to call `uncommentend()` to find & remove the closing comment 
  " symbol in such cases.
  "
  " we assume comments, both 1-part & 3-part, are not nested and follow the 
  " standard in the C manual (chapter 3, "Lexical Conventions", columbia univ):
  "
  "     The /* characters introduce a comment; the */ characters terminate a 
  "     comment. They do not indicate a comment when occurring within a string 
  "     literal. Comments do not nest. Once the /* introducing a comment is 
  "     seen, all other characters are ignored until the ending */ is 
  "     encountered.
  "
  " so, over here, we find and remove just the 1st occurrence of the starting 
  " comment symbol in the line, even if the line has more of the same comment 
  " symbol further on. this works just fine, because if comments are not nested, 
  " as they should be, then removing just this first occurrence is the only way 
  " to wholly uncomment, or begin to uncomment, the line.
  call s:uncomment(a:first)
  " NOTE:
    " '\%' .. virtcol('.') .. 'v'        => ex: \%23v implies virtual col 23.
    " '\%' .. virtcol('.') .. 'v\s'      => matches \s in the virt col.
    " 's/\%' .. virtcol('.') .. 'v\s//'  => replaces \s with '' in the virt col.
    " see :help ordinary-atom
    "
    " why use `silent!` which ignores all errors?  well, the virtual col that 
    " immediately follows may not always contain \s. we only execute a deletion 
    " when \s is present; otherwise, we want to not do anything with the virtual 
    " col at all. using `silent!' allows us to do exactly that. when the virtual 
    " col contains \s, deletion succeeds and all is well, but when there is no 
    " \s, deletion throws up an error, which is then suppressed by `silent!`, 
    " allowing us to ignore the error (& the virtual col).
  silent! execute 's/\%' .. virtcol('.') .. 'v\s//'
endfunction

function! s:uncomment(first) abort
  " Uncomment the line but do not delete any spaces.
  "
  " 'uncomment' here means finding and removing the comment symbol that occurs 
  " at, or somewhere near, the line start, ignoring spaces. this works fine for 
  " a 1-part comment, such as " in vim, but for block comments, such as /* ...  
  " */ in C, this function will only remove the starting comment symbol; you 
  " will then need to call `uncommentend()` to find & remove the closing comment 
  " symbol in such cases.
  "
  " we assume comments, both 1-part & 3-part, are not nested and follow the 
  " standard in the C manual (chapter 3, "Lexical Conventions", columbia univ):
  "
  "     The /* characters introduce a comment; the */ characters terminate a 
  "     comment. They do not indicate a comment when occurring within a string 
  "     literal. Comments do not nest. Once the /* introducing a comment is 
  "     seen, all other characters are ignored until the ending */ is 
  "     encountered.
  "
  " so, over here, we find and remove just the 1st occurrence of the starting 
  " comment symbol in the line, even if the line has more of the same comment 
  " symbol further on. this works just fine, because if comments are not nested, 
  " as they should be, then removing just this first occurrence is the only way 
  " to wholly uncomment, or begin to uncomment, the line.
  "
  " this function uses a 2-step strategy to uncomment:
  "   a) first, it locates, using a search pattern, the comment string and 
  "      positions the cursor at the start of the comment string.
  "   b) it then walks through the entire comment string, left to right, 
  "      character by character, deleting each character.
  "
  " STEP (a) DETAILS:
  "   the entire step (a) is executed in normal mode. details below.
  "   1. `normal 0` -> get to the first character in the line;
  "   2. search for the comment symbol pattern in the current line.
  "
  "       search syntax: /{pattern}/{offset}<CR>; see :help search-commands.
  "
  "   3. the `pattern` in (2) is of the form:
  "       /"\\%" .. line('.') .. 'l' .. '^' .. '\s*' .. comment-string/
  "
  "       / .. /                     => part of search syntax
  "       "\\%" .. line('.') .. 'l'` => search curr line in file; `l` => line
  "       '^'                        => search from start-of-line
  "       '\s*'                      => match for 0+ \s that immediately follow
  "       comment-string (cs)        => match for cs that immediately follow
  "
  "   4. next, pattern match offset with `e-`; see :help search-offset.
  "
  "      by default, if a match is found, vim positions the cursor on the first 
  "      (leftmost) character of the match. but that default position may not 
  "      always be suitable here, because the leftmost match position may 
  "      sometimes be a space character, as our pattern allows the possibility 
  "      that 0 or more space characters may immediately precede the comment 
  "      string. what we want instead is to always position the cursor on the 
  "      first (leftmost) character of the comment string. this is done using:
  "
  "         'e-' .. (width(comment-string) - 1)
  "
  "   5. finally we've a "\<CR>" to complete the search syntax.  so the entire 
  "      thing looks like (NOTE: '/' => search syntax; `cs`: comment string):
  "
  "       `normal 0' .. '/' .. "\\%" .. line('.') .. 'l' .. '^\s*' .. cs .. '/'
  "                  \ .. 'e-' .. ((width(cs) - 1) .. "\<CR>"
  "
  " STEP (b) DETAILS:
  "   after step (a), we've the cursor on the 1st (leftmost) character of the 
  "   comment string.
  "
  "   in step (b), executed fully in normal mode, we begin deleting the comment 
  "   string, left to right, character by character, starting from the leftmost.
  "
  "   we use the blackhole register `"_`, so the deleted characters are not
  "   stored in any register.
  "
  "   the pseudocode is below (NOTE: `cs`: comment string; the # of characters 
  "   in `cs`, given by `width(cs)`, gives the count of deletions):
  "
  "         'normal ' .. width(cs) .. '"_x'
  "=============================================================================
  " NOTE: previous code version (same except for silent & cosmetic formatting):
  " execute 'normal 0/' .. "\\%" .. line('.') .. 'l^\s*' .. s:esc(a:first) ..
  "          \ '/e-' .. (strdisplaywidth(a:first)-1) .. "\<CR>"
  "=============================================================================
  " NOTE:
  "   1. "\\%" = '\%'; /u/ luc hermitte @ https://tinyurl.com/4wn5wphn (vi.SE)
  "   2. on use of `\` for line continuation, see :help line-continuation
  "   3. we added `silent` to silence the search message in the command line.
  silent execute 'normal 0'
              \ .. '/'
                    \ .. '\%' .. line('.') .. 'l'
                    \ .. '^'
                    \ .. '\s*' .. s:esc(a:first)
              \ .. '/'
              \ .. 'e-' .. (strdisplaywidth(a:first)-1)
              \ .. "\<CR>"
  execute 'normal ' .. (strdisplaywidth(a:first)) .. '"_x'
endfunction

function! s:uncommentend(second) abort
  " Remove closing comment, if needed, & 1 immediate preceeding \s, if any
  "
  " this function follows the same logic as `s:uncomment()` -- find and delete 
  " the comment symbol. however, over here, we are removing the closing comment 
  " symbol, which usually (but not always) occurs at line end, rather than at 
  " the start. still, most of the detailed comments for `s:uncomment()` apply 
  " here.  differences, wherevever they exist, are explained below.
  if len(a:second)
    " search pattern: /{pattern}[/]<CR>; see :help search-commands
    "===========================================================================
    " NOTE: previous code version (same except for silent & cosmetic format):
    "    execute 'normal 0/' ..  "\\%" ..  line('.') .. 'l' ..
    "       \ s:esc(a:second) .. '\s*$' .. "\<CR>"
    "===========================================================================
    " NOTE:
    "   1. we assume block comments are not nested and follow the standard in 
    "      the C manual (chapter 3, "Lexical Conventions", columbia univ):
    "
    "         The /* characters introduce a comment; the */ characters terminate 
    "         a comment. They do not indicate a comment when occurring within a 
    "         string literal. Comments do not nest. Once the /* introducing a 
    "         comment is seen, all other characters are ignored until the ending 
    "         */ is encountered.
    "
    "   2. Based on (1), we only search for the first occurrence of the closing 
    "      comment symbol (for C, this is `*/`) in the line, even if the line 
    "      may have more than 1 closing comment symbol. this works because if 
    "      comments are not nested, as they should be, then finding and deleting 
    "      this 1st occurrence is the only way to uncomment the line.
    "   3. unlike in `s:uncomment()`, we do not use search offset here, because 
    "      over here our pattern begins with the comment string (cs), instead of 
    "      spaces, so the 1st thing vim matches on is cs, making vim's cursor 
    "      position on a match the 1st (leftmost) character of cs.
    "   4. we added `silent` to silence the search message in the command line.
    silent execute 'normal 0'
              \ .. '/'
                    \ .. "\\%" .. line('.') .. 'l'
                    \ .. s:esc(a:second)
              \ .. '/'
              \ .. "\<CR>"
    execute 'normal ' .. (strdisplaywidth(a:second)) .. '"_x'
    " NOTE:
      " '\%' .. virtcol('.') .. 'v'        => ex: \%23v implies virtual col 23.
      " '\%' .. virtcol('.') .. 'v\s'      => matches \s in the virt col.
      " 's/\%' .. virtcol('.') .. 'v\s//'  => replaces \s with '' in virt col.
      " see :help ordinary-atom
      "
      " why use `silent!` which ignores all errors?  well, the virtual col that 
      " immediately precedes may not always contain \s. we only execute a 
      " deletion when \s is present; otherwise, we want to not do anything with 
      " the virtual col at all. using `silent!' allows us to do exactly that.  
      " when the virtual col contains \s, deletion succeeds and all is well, but 
      " when there is no \s, deletion throws up an error, which is then 
      " suppressed by `silent!`, allowing us to ignore the error (& virt col).
      "
      " examples:
      "   1. /* some code */  -> match for \s before last `*/`
      "   2. /* some code
      "       * some code
      "       * some code*/   -> no match for \s before last `*/'
      "
      " without `silent!`, example 1 will pass, but example 2 will throw an 
      " error. but with `silent!`, both (1) & (2) will be fine.
    silent! execute 's/\%' .. virtcol('.') .. 'v\s//'
  endif
endfunction

function! s:comment(col, first) abort
  " Comment the line + insert 1 space immediately after the comment symbol
  execute 'normal ' .. a:col .. '|i' .. a:first .. " \<Esc>"
endfunction

function! s:commentend(second) abort
  " Comment line end, if needed, & insert 1 space before the comment symbol
  if len(a:second)
    execute 'normal A' .. ' ' .. a:second .. "\<Esc>"
  endif
endfunction

function! s:updateline(block_data, first, second) abort
  " Execute 'block action' -- comment/uncomment -- on current line
  if a:block_data["action"] == "uncomment-1"
    call s:uncomment1(a:first)
    call s:uncommentend(a:second)
  elseif a:block_data["action"] == "uncomment"
    call s:uncomment(a:first)
    call s:uncommentend(a:second)
  elseif a:block_data["action"] == "comment"
    call s:comment(a:block_data["insert_col"], a:first)
    call s:commentend(a:second)
  else
    throw "s:updateline() -> no valid block action found"
  endif
endfunction

function! s:updatestr(first, second) abort
  " Return call-string for s:updateline()
  return 'call s:updateline(l:block_data' ..
        \ ',' ..
        \ a:first ..
        \ ', ' ..
        \ a:second ..
        \ ')'
endfunction

function! s:blockupdate(flag) abort
  " Using s:updatestr(), generate call-string for block comment/uncomment
  "   -- for 1-part comment, Cs()=1, treat block as series of line comments
  "   -- for 3-part comment, if middle empty, again, treat block as series of 
  "      line comments; otherwise, generate call-string based on flag:
  "       1) f  ->  first line in comment block
  "       2) m  ->  middle part of block: firstline < line < lastline
  "       3) el ->  empty last line
  "       4) l  ->  last line
  " NOTE:
  " -- this function is just a call-string generator
  " -- execute calls this function only when it first evaluates expression to 
  "    generate the string, later used in line-by-line execution
  " -- expression evaluation occurs not for each line, but once per flag
  if len(Cs()) == 1 || Cs()[1] =~ '^\s*$'
    return s:lineupdate()
  elseif a:flag == 'f'
    return s:updatestr('Cs()[0]', '""')
  elseif a:flag == 'm'
    return s:updatestr('" " .. Cs()[1]', '""')
  elseif a:flag == 'el'
    return s:updatestr('" " .. Cs()[2]', '""')
  elseif a:flag == 'l'
    return s:updatestr('" " .. Cs()[1]', 'Cs()[2]')
  else
    throw "s:blockupdate() -> no valid flag found"
  endif
endfunction

function! s:lineupdate() abort
  " Generate, using updatestr(), call-string for linewise comment/uncomment
  " call-string based on Cs(), i.e., 1-part or 3-part comment
  " NOTE: for 3-part comment, line comment will just use 'start' & 'end' 
  " symbols, since single line has no "middle" line, & 1st line = last line
  if len(Cs()) == 1
    return s:updatestr('Cs()[0]', '""')
  endif
  return s:updatestr('Cs()[0]', 'Cs()[2]')
endfunction

function! s:scanline(block_data, commentpat) abort
  " Scan current line and, if relevant, update block data with line info
  " line info has 2 pieces:
  "   -- comment column (i.e., first non-blank virtual column)
  "   -- action, which describes what should be done to the line on toggle:
  "         1. uncomment-1: uncomment + remove 1 space that follows immediately
  "         2. uncomment: just uncomment; do not remove any spaces
  "         3. comment: comment the line
  " we update block data if either/both of these conditions occur:
  "   -- if line's comment column < insert_column in block data
  "   -- if line's action is "comment", but block data's action is not
  " NOTE: a:commentpat -> regex pattern to detect comment symbol(s)
  normal! ^
  if getline('.') =~ '^\s*$'
    let a:block_data["action"] = "comment"
  elseif getline('.') =~ '^\s*' .. a:commentpat .. ' '
    let l:line_action = "uncomment-1"
  elseif getline('.') =~ '^\s*' .. a:commentpat .. '\($\|\S\)'
    let l:line_action = "uncomment"
  elseif a:block_data["action"] != "comment"
    let a:block_data["action"] = "comment"
  endif
  if virtcol('.') < a:block_data["insert_col"]
    let a:block_data["insert_col"] = virtcol('.')
    if a:block_data["action"] != "comment"
      let a:block_data["action"] = l:line_action
    endif
  endif
endfunction

function! s:esc(str) abort
  " Wrapper function that returns escaped value -- needed in regex patterns
  return escape(a:str, "\/*|")
endfunction

function! s:commentpat(linewise) abort
  " For current buffer, return comment symbol(s) as a regex pattern
  "   -- for 1-part comment, same regex for both linewise & block comment
  "   -- but for 3-part comment, regex based on linewise vs block
  "   -- regex pattern used in s:scanline() to detect a comment
  if a:linewise
    return s:esc(Cs()[0])
  endif
  return '\(' .. s:esc(join(Cs(), '|')) .. '\)'
endfunction

function! s:scanstr(linewise) abort
  " Return s:scanline() call-string for current buffer
  return 'call s:scanline(l:block_data, s:commentpat(' .. a:linewise .. '))'
endfunction

function! ToggleComments() range abort
  " Uniformly toggle comments for a block (i.e., a range of lines)
  " Rules:
  "   1. comment/uncomment operations should never change the relative 
  "      indentation within the selected block.
  "   2. uniform block toggle -- i.e., on toggle, we either comment all lines or 
  "      uncomment all lines.  `l:block_data["action"]` models this in code.
  "   3. we uncomment all lines only if all lines are comments; else, we always 
  "      comment all lines, even if some lines are comments.
  "   4. when we uncomment, we only remove the leading comment symbol. and if 
  "      applicable, the trailing comment symbol.  so if some lines that were 
  "      already comments had been commented again (see rule 3), when we 
  "      uncomment, those lines will still be comments, although now they will 
  "      only have 1 leading comment symbol.
  "   5. when we comment, we insert the leading comment symbol at the same 
  "      column for all lines.  this column is the least non-blank virtual 
  "      column in the block; `l:block_data["insert_col"]` models it in code.
  "   6. when we uncomment, we will choose one of the options below for the 
  "      leading comment, and apply that same option to every line in the block:
  "         a) just uncomment and do nothing else; or,
  "         b) uncomment & remove 1 space, if any, that immediately follows.
  "      how do we decide?
  "         -- find the first line in selection with the least comment column
  "         -- is that line's leading comment symbol followed by 0 spaces?
  "         -- yes? => apply option (a) to every line in the block
  "         -- no?  => apply option (b) to every line in the block
  "      `l:block_data["action"]` models this in code.
  "   7. trailing comment/uncomment:
  "       -- done only when &commentstring ~ 'leading-symbol%strailing-symbol'
  "       -- comment: add 1 \s followed by trailing comment symbol @ END
  "       -- uncomment: chop 1 \s, if any, + trailing comment symbol @ END
  "       -- for linewise, END = 'EOL'; for block, END = EOL of last line
  " Rules 1-6 match those used in manual comment/uncomment using Ctrl-v
  " Method:
  " we distinguish 2 main categories:
  "   -- 1-part comment vs 3-part comment
  "   -- linewise comment vs block comment
  " 1-part:
  "   -- &commentstring ~ 'leadingsymbol%s'
  "   -- linewise ~ block -> both have just a leading comment symbol
  " 3-part:
  "   -- &commentstring ~ 'leadingsymbol%strailingsymbol'
  "   -- middle symbol comes from 'mb' part of &comments
  "   -- linewise -> leading symbol ... trailing symbol (example, /* ... */)
  "   -- block    -> has middle symbol as well (example, /* * */); to do this, 
  "      block split into 3, based on line position:
  "       - firstline (f): leading symbol ...
  "       - middle (m) -> for firstline < line < lastline: middle symbol ...
  "       - empty lastline (el): ... trailing symbol OR
  "       - non-empty lastline (l): middle symbol ... trailing symbol
  try
    set formatoptions-=a          " turn off autoindent
    let l:block_data = { "action" : "", "insert_col" : 1000 }
    if a:firstline == a:lastline
      execute a:firstline .. s:scanstr(1)
      execute a:firstline .. s:lineupdate()
    else
      execute a:firstline .. ',' .. a:lastline .. s:scanstr(0)
      execute a:firstline .. s:blockupdate('f')
      if a:lastline > a:firstline + 1
        execute (a:firstline+1) .. ',' .. (a:lastline-1) .. s:blockupdate('m')
      endif
      if getline(a:lastline) =~ s:emptyllendpat()
        execute a:lastline .. s:blockupdate('el')
      else
        execute a:lastline .. s:blockupdate('l')
      endif
    endif
  finally
    set formatoptions+=a
  endtry
endfunction

