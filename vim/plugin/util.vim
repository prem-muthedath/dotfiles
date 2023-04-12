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
  " NOTES: this function's structure is same as `FormatOptionsGhcFlagsFile()`, 
  " even though the format of input file here is different, so the overall flow 
  " of extensive comments given for `FormatOptionsGhcFlagsFile()` applies here.
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
function! FormatOptionsGhcFlagsFile()
  " Format OPTIONS-GHC-FLAGS-ORIGINAL.txt file in ~/dotfiles/vim/haskell/data/
  " sample output: ~/dotfiles/vim/haskell/data/OPTIONS-GHC-FLAGS-FORMATTED.txt
  " basically, this function formats line data into neatly separated columns.
  "
  " 19 MAR 2023; author: Prem Muthedath
  "
  " well, how do you use this function?
  "   (a) first make a copy of OPTIONS-GHC-FLAGS-ORIGINAL.txt;
  "   (b) then open that copy in vim;
  "   (c) then invoke :call FormatOptionsGhcFlagsFile() from vim commandline.
  "
  " NOTES:
  "   1. in our case we've data lines of the form shown below. as you can see, 
  "      the line data are staggered, instead of being separated into columns, 
  "      which makes reading difficult.
  "         -blah     dynamic        -no-blah
  "         -bazooze     dynamic\s\s
  "         -foo-dynamic         dynamic             -no-foo-dynamic
  "   2. to get stuff separated into columns, we use `g/pattern/cmds`, which 
  "      searches the entire file & selects every line that matches the pattern 
  "      and then runs `cmds` on each matched line. see :h :global
  "   3. we use g/pattern/cmds 3 times to format our data. in the first 
  "      g/pattern./cmds, we first remove the spaces between the 1st data column 
  "      (blah, bazooze, -foo-dynamic) and the 2nd column `dynaamic` using:
  "          execute 's/\s\+\(dynamic\)\(\s*$\|\s\+-\)/\U\1\E\2'
  "      we use /\s\+\(dynamic\)\(\s*$\|\s\+-\)/ because of lines like:
  "           ^-dynamic   dynamic
  "           ^-rdynamic    dynamic
  "           ^-fi-dynamic    dynamic     -no-fi-dynamic
  "      so to get the middle `dynamic` (the one we want), we search for a 
  "      `dynamic` always preceeded by \s+ & followed either by \s\+- or by 
  "      \s*$. plus, in substitution, we convert `dynamic` to `DYNAMIC`, to make 
  "      it easier to locate the 'dynamic` we want, always the uppercase one.
  "      after this command, we have:
  "         -blahDYNAMIC        -no-blah
  "         -bazoozeDYNAMIC\s\s
  "         -foo-dynamicDYNAMIC             -no-foo-dynamic
  "   4. then, continuing with the same g/pattern/, we standardize the spacing 
  "      between the 2nd column (`DYNAMIC`) and the 3rd column to 3 \s.
  "         execute 's/\(DYNAMIC\)\s\+\(-\)/\1   \2'
  "      after this command, we have:
  "         -blahDYNAMIC   -no-blah
  "         -bazoozeDYNAMIC\s\s
  "         -foo-dynamicDYNAMIC   -no-foo-dynamic
  "   5. still with the same g/pattern/, we chop any trailing \s after `DYNAMIC` 
  "      (the one merged at 1st column end) when no 3rd column follows it:
  "         execute 's/\(DYNAMIC\)\s\+$/\1'
  "      after this command, we have:
  "         -blahDYNAMIC   -no-blah
  "         -bazoozeDYNAMIC
  "         -foo-dynamicDYNAMIC   -no-foo-dynamic
  "   6. next, we run the 2nd g/pattern/cmds, first to do pattern search and 
  "      place the cursor just before `D` in `DYNAMIC` to extract the column #:
  "         execute 'normal! ' ..
  "             \ '/^-.*\zsDYNAMIC\ze\(\s\+-\|$\)/e-' ..  (l:offset) .. "\<CR>"
  "      \zs & \ze define match selection, which here is `DYNAMIC`.
  "      `l:offset` = len('DYNAMIC')`
  "      after this, we've cursor on the leftmost CAPS alphabet as shown below:
  "           -blaHDYNAMIC   -no-blah
  "           -bazoozEDYNAMIC
  "           -foo-dynamiCDYNAMIC   -no-foo-dynamic
  "   7. as step 6 is done on each g/pattern/ matched line, we also concurrently 
  "      update the max col #, the max width of data column 1, so that when we 
  "      get through all matched lines, we will have the final max col #:
  "         let l:maxcol = max([l:maxcol, virtcol('.')])
  "   8. finally, we run the 3rd g/pattern/cmds, first repeating step 
  "      6 to position the cursor just before `D` in `DYNAMIC`:
  "         execute 'normal! ' ..
  "             \ '/^-.*\zsDYNAMIC\ze\(\s\+-\|$\)/e-' ..  (l:offset) .. "\<CR>"
  "      after this, we've cursor on the leftmost CAPS alphabet as shown below:
  "           -blaHDYNAMIC   -no-blah
  "           -bazoozEDYNAMIC
  "           -foo-dynamiCDYNAMIC   -no-foo-dynamic
  "   9. as step 8 is done on each g/pattern/ matched line, we use the max col # 
  "      from step 7 to concurrently insert spaces between `DYNAMIC` & the  1eft 
  "      (1st) column to get the same 1st column width for each matched line.  
  "      concurrently, after space insertion, we also revert 'DYNAMIC' back to 
  "      'dynamic' for that line.
  "         let l:diff = l:maxcol - virtcol('.') + 3
  "         execute 'normal! a' .. repeat(" ", l:diff)
  "         execute 's/DYNAMIC/dynamic/'
  "      after this, we've the following result:
  "         -blah          dynamic   -no-blah
  "         -bazooze       dynamic
  "         -foo-dynamic   dynamic   -no-foo-dynamic
  "   10. so, in summary, following steps 3 - 9, we transformed
  "         -blah     dynamic        -no-blah
  "         -bazooze     dynamic\s\s
  "         -foo-dynamic         dynamic             -no-foo-dynamic
  "       to:
  "         -blah          dynamic   -no-blah
  "         -bazooze       dynamic
  "         -foo-dynamic   dynamic   -no-foo-dynamic
  "
  " TESTING: one way to test this function is to run it twice on the same file 
  " and compare the results, using an unix diff or a git diff. there should be 
  " no difference between the results of multiiple runs on the same file. this 
  " test is necessary but not sufficient, by the way.
  " ============================================================================
  " see below REFs for :execute and `normal` and `normal!` usage:
  "   1. https://learnvimscriptthehardway.stevelosh.com/chapters/28.html
  "   2. https://learnvimscriptthehardway.stevelosh.com/chapters/29.html
  "   3. https://learnvimscriptthehardway.stevelosh.com/chapters/30.html
  " good comments: /u/ martin tournoij @ https://tinyurl.com/xn6fbrmm (vi.SE)
  " on `..` use, see :h expr-..
  let l:maxcol=0
  let l:offset=len('DYNAMIC')
  let l:pat='normal! ' .. '/^-.*\zsDYNAMIC\ze\(\s\+-\|$\)/e-' .. (l:offset) .. "\<CR>"
  " for all g-matched lines,
  "   1) merge data columns 1 & 2 (has `dynamic`), switching case of `dynamic`;
  "   2) set 3 \s separation between data columns 2 (now merged) and 3;
  "   3) if no data column 3, trim any trailing \s+ of data column 2 (merged).
  " https://vim.fandom.com/wiki/Changing_case_with_regular_expressions
  g/^-.*dynamic/
        \ execute 's/\s\+\(dynamic\)\(\s*$\|\s\+-\)/\U\1\E\2'
        \ | execute 's/\(DYNAMIC\)\s\+\(-\)/\1   \2'
        \ | execute 's/\(DYNAMIC\)\s\+$/\1'
  " get max width of 1st data column
  g/^-.*DYNAMIC/
        \ execute l:pat
        \ | let l:maxcol = max([l:maxcol, virtcol('.')])
  " have all matched lines conform to same width for 1st data column.
  " in each matched line, revert 'DYNAMIC' back to 'dynamic' as well.
  g/^-.*DYNAMIC/
        \ execute l:pat
        \ | let l:diff = l:maxcol - virtcol('.') + 3
        \ | execute 'normal! a' .. repeat(" ", l:diff)
        \ | execute 's/DYNAMIC/dynamic/'
endfunction

" ==============================================================================
function! ParseOptionsGhcFlags() abort
  " reads vim/haskell/data/OPTIONS-GHC-FLAGS-FORMATTED.txt, extracts OPTIONS_GHC 
  " flags, & prints them to vim/haskell/data/OPTIONS-GHC-FLAGS-PARSED-LIST.txt.
  "
  " author: Prem Muthedath, 27 MAR 2023.
  "
  " usage: open vimrc and run :call ParseOptionsGhcFlags() on the commandline.
  "
  " see below REFs for :execute and `normal` and `normal!` usage:
  "   1. https://learnvimscriptthehardway.stevelosh.com/chapters/28.html
  "   2. https://learnvimscriptthehardway.stevelosh.com/chapters/29.html
  "   3. https://learnvimscriptthehardway.stevelosh.com/chapters/30.html
  " line =~# '^=\+\s*+\+[[:upper:]-_. [:digit:]]\++\+\s*$' selects the header:
  "   ^== ++++++++++++ OPTIONS_GHC FLAGS FOR GHC 8.10.4 ++++++++++++
  " line =~# '^=\+[[:upper:]- ]\+$' selects lines such as:
  "   ^============== VERBOSITY OPTIONS
  " line =~# ^-.*$' selects lines such as:
  "   ^-fshow-type-of-hole-fits               dynamic   -fno-type-of-hole-fits
  "   ^-funclutter-valid-hole-fits            dynamic
  "   ^-keep-llvm-file, -keep-llvm-files      dynamic
  "   ^-O, -O1                                dynamic   -O0
  " l:pat1 => is used in splitting lines of the form:
  "   ^-fshow-type-of-hole-fits               dynamic   -fno-type-of-hole-fits
  "   ^-funclutter-valid-hole-fits            dynamic
  " l:pat2 => is used in splitting lines of the form:
  "   ^-keep-llvm-file, -keep-llvm-files      dynamic
  "   ^-O, -O1                                dynamic   -O0
  " l:pat => is used in splitting lines by l:pat1 or l:pat2 or both.
  " NOTES:
  "   1. split() > 1 delimeter: /u/ amadan @ https://tinyurl.com/mt4pr9hp (so)
  "   2. see :h substitute()
  " ============================================================================
  " good comments: /u/ martin tournoij @ https://tinyurl.com/xn6fbrmm (vi.SE)
  " on `==#` -> https://learnvimscriptthehardway.stevelosh.com/chapters/22.html
  " on `..` use, see :h expr-..
  " define & initialize some local variables.
  :let l:ifile=g:phask_ops_ghc_formatted_iofile
  :let l:ofile=g:phask_ops_ghc_parsed_ofile
  :let l:pat1='\s\+dynamic\($\|\s\+\)'
  :let l:pat2=',\s'
  :let l:pat='\(' .. l:pat1 .. '\)' .. '\|' .. '\(' .. l:pat2 .. '\)'
  " delete existing output file, if any, because we're going to overwrite it.
  :call delete(l:ofile)
  " read the input file, parse each line, and print results to output file.
  :for line in readfile(l:ifile)
    " header: ^== ++++++++++++ OPTIONS_GHC FLAGS FOR GHC 8.10.4 ++++++++++++
    :if line =~# '^=\+\s*+\+[[:upper:]-_. [:digit:]]\++\+\s*$'
      " change to: ^++++++++++++ OPTIONS_GHC FLAGS FOR GHC 8.10.4 ++++++++++++
      :let line = substitute(line, '^=\+\s*', '', '')
      :call writefile([l:line], l:ofile, 'sa')
    " lines such as: ^============== VERBOSITY OPTIONS
    :elseif line =~# '^=\+[[:upper:]- ]\+$'
      :call writefile([l:line], l:ofile, 'sa')
    " data lines (w/t or w/o comma) such as: ^-O, -O1     dynamic   -O0
    :elseif line =~# '^-.*$'
      :let l:lines=split(line, l:pat)
      :call writefile(l:lines, l:ofile, 'sa')
    :endif
  :endfor
endfunction

" ==============================================================================
function! CountOptionsGhcFlags() abort
  " count the number of OPTIONS_GHC flags.
  "
  " this count acts as a rule-of-thumb test for the generated 
  " vim/haskell/data/OPTIONS-GHC-FLAGS-PARSED-LIST.txt. the total number of lines in 
  " that file should match the count reported by this function.
  "
  " code idea from /u/ mMontu @ https://tinyurl.com/y6s8mxpz (so).
  " replaced `v` with `g` here; of course, the patterns apply only for use here.
  "
  " usage: open vim/haskell/data/OPTIONS-GHC-FLAGS-FORMATTED.txt and then invoke 
  " :echo CountOptionsGhcFlags() on the vim commandline.
  "
  " NOTE (vim doc):
  " \@! matches with zero width if the preceding atom does NOT match at the 
  " current position. :h \@!
  "     foo\(bar\)\@!           any "foo" not followed by "bar"
  "     /^\%(.*bar\)\@!.*\zsfoo
  " this pattern first checks that there is not a single position in the
  " line where "bar" matches.  if ".*bar" matches somewhere the \@! will reject 
  " the pattern.  when there is no match any "foo" will be found.  The "\zs" is 
  " to have the match start just before "foo".
  " ============================================================================
  " good comments: /u/ martin tournoij @ https://tinyurl.com/xn6fbrmm (vi.SE)
  " on `==#` -> https://learnvimscriptthehardway.stevelosh.com/chapters/22.html
  let l:count=0
  " count 'comma' lines such as:
  "   ^-keep-hscpp-file, -keep-hscpp-files  dynamic
  "   ^-O, -O1                              dynamic   -O0
  g/\v^-.*,\s/
    \ if getline('.') =~# '\s\+dynamic\s\+-'
    \ | let l:count+=3
    \ | else
    \ | let l:count+=2
    \ | endif
  " count lines such as:           ^-ddump-hi                     dynamic
  " but don't count lines such as: ^-ddump-ds, -ddump-ds-preopt   dynamic
  " we don't count 'comma' lines bcoz they've been already counted.
  g/\v%(^-.*,\s)@!^-.*dynamic$/let l:count+=1
  " count lines such as:    ^-fforce-recomp      dynamic   -fno-force-recomp
  " but don't count these:  ^-O, -O1             dynamic   -O0
  " we don't count 'comma' lines bcoz they've been already counted.
  g/\v%(^-.*,\s)@!^-.*dynamic\s+-/let l:count+=2
  " count headers of the form: ^========= VERBOSITY OPTIONS
  " NOTE: bcoz '=' has special meaning in very magic, we used \= to denote '='
  g/\v^\=+[[:upper:]- ]+$/let l:count+=1
  "count headers of the form:
  "   ^== ++++++++++++ OPTIONS_GHC FLAGS FOR GHC 8.10.4 ++++++++++++
  " NOTE: bcoz '=' has special meaning in very magic, we used \= to denote '='
  g/\v^\=+\s*\++[[:upper:]-_. [:digit:]]+\++\s*$/let l:count+=1
  return l:count
endfunction

" ==============================================================================

