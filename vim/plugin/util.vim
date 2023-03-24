" This has just a collection of utility functions written as and when needed.
"
" history: created 7 - 28 AUG 2018.
" author: Prem Muthedath

" ==============================================================================
function! Csformat()
  " Format file -- such as ~/dotfiles/vim/arch/notes/cs.vim -- containing list
  " of filenames and &comments into neatly seperated columns;
  " sample output: ~/dotfiles/vim/arch/notes/cs-col.vim
  let l:m=0
  g/vim:/
        \ execute 'normal ' . "/^.*vim:/e" . "\<CR>"
        \ | let l:m = max([l:m, virtcol('.')])
  g/vim:/
        \ execute 's/\(^\S\+\.vim:\)[^=]*\(comment\|com\)/\1\2'
        \ | execute 'normal 0' . "/^.*vim:/e" . "\<CR>"
        \ | let l:diff = l:m - virtcol('.') + 3
        \ | execute 'normal a' . repeat(" ", l:diff)
endfunction

" ==============================================================================
function! OptionsGhcFlagsFormat()
  " Format OPTIONS-GHC-FLAGS-ORIGINAL.txt file in ~/dotfiles/vim/haskell/
  " sample output: ~/dotfiles/vim/haskell/OPTIONS-GHC-FLAGS-FORMATTED.txt
  " basically, this function formats data into columns of equal width.
  "
  " 19 MAR 2023; author: Prem Muthedath
  "
  " well, how do you use this function? (a) first make a copy of 
  " OPTIONS-GHC-FLAGS-ORIGINAL.txt; (b) then open that copy in vim; and (c) then 
  " invoke :call OptionsGhcFlagsFormat() from vim commandline.
  "
  " NOTES:
  "   1. `g/pattern/cmds` searches entire file & selects every line that matches 
  "      the pattern and then runs `cmds` on each matched line. see :h :global
  "   2. in our case we've data lines of the form:
  "         -blah     dynamic        -no-blah
  "         -bazooze     dynamic\s\s
  "         -foo-dynamic         dynamic             -no-foo-dynamic
  "   3. we use g/pattern/cmds 3 times to format this data. in the first 
  "      g/pattern./cmds, we first remove the spaces between the 1st column 
  "      (blah, bazooze, -foo-dynamic) and the 2nd column `dynaamic` using:
  "         execute 's/\s\+\(dynamic\)\(\s*$\|\s\+-\)/\1\2'
  "
  "      NOTE: we use the pattern \s+\(dynamic\)\(\s*$\|\s\+-\) because we've or 
  "      could have lines like:
  "           ^-dynamic   dynamic
  "           ^-rdynamic    dynamic
  "           ^-fi-dynamic    dynamic     -no-fi-dynamic
  "         so the way to distinguish the middle `dynamic` (the one we want) is 
  "         to ensure that we're looking for a dynamic always preceeded by \s+ 
  "         and always followed either by \s\+- or by \s*$
  "
  "      after this command, we have
  "         -blahdynamic        -no-blah
  "         -bazoozedynamic\s\s
  "         -foo-dynamicdynamic             -no-foo-dynamic
  "   4. then, continuing with the same g/pattern/, we stndardize the seperation 
  "      between `dynamic` and -no-blah to 3 \s; that is, we standardize the 
  "      space between the middle `dynamic` and the 3rd column to 3 \s.
  "         execute 's/\(dynamic\)\s\+\(-\)/\1   \2'
  "
  "      after this command, we have
  "         -blahdynamic   -no-blah
  "         -bazoozedynamic\s\s
  "         -foo-dynamicdynamic   -no-foo-dynamic
  "   5. still with the same g/pattern, we then remove trailing spaces after 
  "      `dynamic` when nothing follows it:
  "         execute 's/\(dynamic\)\s\+$/\1'
  "
  "      after this command, we have
  "         -blahdynamic   -no-blah
  "         -bazoozedynamic
  "         -foo-dynamicdynamic   -no-foo-dynamic
  "   6. next, we run the 2nd g/pattern/cmds, first to do pattern search and 
  "      place the cursor just before `d` in `dynamic` to extract the column #:
  "         execute 'normal' .
  "                 \ '/^.*\zsdynamic\ze\(\s\+-\|$\)/e-' .  (l:offset) .
  "                 \ ""\<CR>"
  "
  "      NOTE: we've lines like the ones below in the file:
  "           ^-dynamic   dynamic
  "           ^-rdynamic    dynamic
  "         so we use the greedy pattern /^.*\zsdynamic\ze/\(\s\+-\|$\) which 
  "         will match the `dynamic` (the one we want) that is either followed 
  "         by \s+- or followed by nothing (which is EOL). \zs and \ze define 
  "         part of the match for selection, which in our case is `dynamic`.
  "
  "       after this, we've cursor on the CAPS alphabet shown below
  "         -blaHdynamic   -no-blah
  "         -bazoozEdynamic
  "         -foo-dynamiCdynamic   -no-foo-dynamic
  "   7. as step 6 is done on each g/pattern/ matched line, we also concurrently 
  "      update the max col #, so that when we have got through all matched 
  "      lines, we will have the final and correct max col #:
  "         let l:maxcol = max([l:maxcol, virtcol('.')])
  "   8. finally, we run the 3rd g/pattern/cmds, first repeating step 
  "      6 to position the cursor just before `d` in `dynamic`:
  "         execute 'normal' .
  "                 \ '/^.*\zsdynamic\ze\(\s\+-\|$\)/e-' .  (l:offset) .
  "                 \ ""\<CR>"
  "         execute 'normal ' . '/^.*dynamic/e-' . (l:offset) . "\<CR>"
  "
  "      NOTE: we've lines like the ones below in the file:
  "           ^-dynamic   dynamic
  "           ^-rdynamic    dynamic
  "         so we use the greedy pattern /^.*dynamic/(\s\+-\|$\) which will 
  "         match the `dynamic` (the one we want) that is either followed by 
  "         \s+- or followed by nothing (which is EOL). \zs and \ze define part 
  "         of the match for selection, which in our case is `dynamic`.
  "
  "      after this, we've cursor on the CAPS alphabet shown below
  "         -blaHdynamic   -no-blah
  "         -bazoozEdynamic
  "         -foo-dynamiCdynamic   -no-foo-dynamic
  "   9. then, as step 8 is done on each g/pattern/ matched line, using the 
  "      final max col # from step 7, we also concurrently insert spaces between 
  "      `dynamic` & the 1eft column to get uniform separation for that line, so 
  "      that when we've got through all g/pattern/ matched lines, we'll have 
  "      this uniform separation for all matched lines:
  "         let l:diff = l:maxcol - virtcol('.') + 3
  "         execute 'normal a' . repeat(" ", l:diff)
  "
  "      after this, we've the following result:
  "         -blah          dynamic   -no-blah
  "         -bazooze       dynamic
  "         -foo-dynamic   dynamic   -no-foo-dynamic
  "   10. so, in summary, following steps 3 - 9, we transformed
  "         -blah     dynamic        -no-blah
  "         -bazooze     dynamic\s\s
  "         -foo-dynamic         dynamic             -no-foo-dynamic
  "
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
  let l:maxcol=0
  let l:offset=len('dynamic')
  let l:pat='normal' . '/^.*\zsdynamic\ze\(\s\+-\|$\)/e-' . (l:offset) . "\<CR>"
  g/^-.*dynamic/
        \ execute 's/\s\+\(dynamic\)\(\s*$\|\s\+-\)/\1\2'
        \ | execute 's/\(dynamic\)\s\+\(-\)/\1   \2'
        \ | execute 's/\(dynamic\)\s\+$/\1'
  g/^-.*dynamic/
        \ execute l:pat
        \ | let l:maxcol = max([l:maxcol, virtcol('.')])
  g/^-.*dynamic/
        \ execute l:pat
        \ | let l:diff = l:maxcol - virtcol('.') + 3
        \ | execute 'normal a' . repeat(" ", l:diff)
endfunction
" ==============================================================================

