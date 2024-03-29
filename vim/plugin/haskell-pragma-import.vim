" code for generating:
"   a) complete list of haskell OPTIONS_GHC flags (used in haskell pragma);
"   b) all installed GHC Language Extensions (used in haskell pragma);
"   c) names of all modules installed on Prem's system (used in module import).
"
" generated data stored in files (see 'usage' below).
"
" why do we need this data?
" generated data used for haskell pragma and module import completion in haskell 
" files using vim omnicompletion. see vim/autoload/haskellcomplete.vim
"
" basically, this code generates all data needed for haskell pragma and module 
" name (in import) completion in haskell files in vim.
"
" usage (to generate all data in 1 shot):
" open vim and run `:call GenerateHaskellPragmaImportData()` on vim commandline.  
" locations of generated data echoed in vim commandline.
"
" history:
"   created APR 2023.
"   old parts of this code were in util file before.
" author: Prem Muthedath
"
" ==============================================================================
" define directory and file paths as immutable values.
" for glob()` use, see /u/ martin tournoij @ https://tinyurl.com/2t7e3asj (so)
" on `..` use, see :h expr-..
const g:pdotfiles_dir = glob('~/dotfiles/')
const g:phask_data_dir = g:pdotfiles_dir .. 'vim/haskell/data/'
const g:phask_shell_dir = g:pdotfiles_dir .. 'vim/haskell/shell/'

const g:phask_ops_ghc_orig_ifile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-ORIGINAL.txt'
const g:phask_ops_ghc_formatted_header_ifile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-FORMATTED--HEADER.txt'
const g:phask_ops_ghc_formatted_iofile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-FORMATTED.txt'
const g:phask_ops_ghc_parsed_ofile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-PARSED-LIST.txt'

const g:phask_lang_extns_ofile = g:phask_data_dir .. 'GHC-LANGUAGE-EXTENSIONS-SORTED-LIST.txt'
const g:phask_imp_modules_ofile = g:phask_data_dir .. 'ghcup-cabal-installed-modules.txt'

" ==============================================================================
" top-level function that generates all OPTIONS_GHC flags, all GHC Language 
" Extensions, & all installed haskell module names. all generated data stored in 
" files; file locations echoed in vim commandline when you run this function. 
" this function serves as a 1-stop place to generate all the above haskell data.
"
" this function aborts if any of the functions it invokes throws an exception.
"
" usage:
" open vim and run `:call GenerateHaskellPragmaImportData()` on vim commandline.
function! GenerateHaskellPragmaImportData() abort
  " NOTE: we call `GenerateOptionsGhcFlags()` first to avoid a redraw of vim 
  " commandline that wipes out previous messages. if we instead had a different 
  " call sequence, the redraw in `GenerateOptionsGhcFlags()` would wipe out the 
  " vim commandline messages from previous function calls, so users will not be 
  " able to see all the messages in the vim commandline that this function call 
  " would generate.  this call sequence is strictly for visual purposes only; 
  " the data generated will be the same no matter what the call sequence is.
  :call GenerateOptionsGhcFlags()
  :call GenerateGHCLanguageExtns()
  :call GenerateInstalledHaskellModuleNames()
endfunction

" ==============================================================================
" generates ghcup- and cabal-installed module names, sorted & stored in a file.
" this function invokes a helper function (introduced to avoid code duplication) 
" that in turn invokes a specified shell script that actually does the job.
"
" the invoked shell script, by the way, first generates (and stores in files) 
" ghcup- and cabal-installed package names, which are then used to generate the 
" module names. over here, we only care about the final product, the generated 
" module names, and not the generated package names, the intermediate stuff. 
" this is the reason we only specify the output file for the generated module 
" names.  since we do not specify the names of package data files, the script 
" uses default files specified in its code to store the generated package names.
"
" this function propagates any script error thrown as an exception.
"
" usage:
" in vim, run `:call GenerateInstalledHaskellModuleNames()` on vim commandline.
"
" even though a shell script does the actual job, i decided to have this 
" function in vim, so that we've 1 place to initiate the job.
" for use of '\', see :h line-continuation
function! GenerateInstalledHaskellModuleNames() abort
  :call s:generateScriptData(
      "\ bash script name
      \'output-haskell-package-and-module-names',
      "\ output file where the script will dump module names
      \ g:phask_imp_modules_ofile,
      "\ error message in case of script failure
      \ "Installed Module Names Generation Failure")
endfunction

" ==============================================================================
" generates GHC language extensions, alphabetically sorted and stored in a file.
" this function invokes a helper function (introduced to avoid code duplication) 
" that in turn invokes a specified shell script that actually does the job.
"
" this function propagates any script error thrown as an exception.
"
" usage:
" in vim, run `:call GenerateGHCLanguageExtns()` on vim commandline.
"
" even though a shell script does the actual job, i decided to have this 
" function in vim, so that we've 1 place to initiate the job.
" for use of '\', see :h line-continuation
function! GenerateGHCLanguageExtns() abort
  :call s:generateScriptData(
      "\ bash script name
      \'output-ghc-language-extensions',
      "\ output file where the script will dump GHC Language Extensions
      \ g:phask_lang_extns_ofile,
      "\ error message in case of script failure
      \ "GHC Language Extensions Generation Failure")
endfunction

" ==============================================================================
" helper function that invokes the specified shell script, passing it the 
" specified ouput file, to generate whatever data the script generates. if the 
" script errors, this function captures the stderr and throws it.
"
" usage: this function not directly invoked by the end user; instead, top-level 
" functions in this file invoke it as part of their work. this function collects 
" common code in 1 place, avoiding code duplication.
function! s:generateScriptData(script, ofile, err_msg) abort
  " define the bash script.
  " on shellescape(), see /u/ tommcdo @ https://tinyurl.com/394b562j (vi.se)
  :let l:bscr = shellescape(g:phask_shell_dir .. a:script)
  " invoke the bash script, passing it the name of the output file.  capture the 
  " `system()` output, which in this case would be stderr, as stdout is none.
  "   1. system() => https://www.baeldung.com/linux/vim-shell-commands-silence
  "   2. system() returns both stdout and stderr; here, we don't care about 
  "      stdout, but if there is a failure, we would like to capture the stderr.
  :let l:res = system(l:bscr .. ' ' .. shellescape(a:ofile))
  " if the bash script errors, capture and throw the error.
  :if v:shell_error
  : throw a:err_msg .. ": " .. l:res
  :endif
  :echo l:res
endfunction

" ==============================================================================
" these functions below work together to format and generate OPTIONS_GHC flags.
" ==============================================================================
" ==============================================================================
" a controller- or director-type function that generates OPTIONS_GHC flags.
" it works with helper functions in a step-wise manner to get the job done:
"   1. first generates a freshly formatted OPTIONS-GHC-FLAGS file;
"   2. then parses the formatted file for OPTIONS_GHC flags, relevant headers;
"   3. dumps parsed data, which also contain headers for easy reading, to 
"      OPTIONS-GHC-FLAGS-PARSED-LIST.txt;
"   4. finally, runs a quick-and-dirty test on the generated (parsed) file, and 
"      if the test fails, propagates the thrown exception.
"   5. this function propagates all exceptions thrown from functions it invokes; 
"      also, this function throws any error it detects.
"
" usage: open vimrc & invoke :call GenerateOptionsGhcFlags() on vim commandline.
function! GenerateOptionsGhcFlags() abort
  " do we have a valid root directory?
  :if g:pdotfiles_dir ==# ""
  : throw 'the required root directory `~/dotfile/` DOES NOT EXIST.'
  :endif
  " generate a newly formatted OPTIONS-GHC file for parsing OPTIONS_GHC flags.
  " `:silent` suppresses messages from `s:format()` in vim coomandline.
  :silent :call s:format()
  " delete old parsed OPTIONS-GHC flags file, if any, b'coz we'll overwrite it.
  :call delete(g:phask_ops_ghc_parsed_ofile)
  " get the parsed list of all OPTIONS_GHC flags and relevant headers.
  :let l:flags = s:parseFlags()
  " dump the parsed data to file.
  :call writefile(l:flags, g:phask_ops_ghc_parsed_ofile, 's')
  " run a quick test on the parsed data, making sure we've got all the info.
  " Note: the testing function throws an error if the test fails.
  " `:silent` suppresses messages from `s:testFlagCount()` in vim coomandline.
  :silent :call s:testFlagCount()
  " if you see an error, throw an exception.
  :if v:errmsg != ""
  : throw "error in GenerateOptionsGhcFlags(): " .. v:errmsg
  :endif
  " we force a redraw; else, `:echo` command message disappears! see :help :echo
  :redraw
  :echo "OPTIONS_GHC Flags successfully written to " .. g:phask_ops_ghc_parsed_ofile
endfunction

" ==============================================================================
" helper function. generates a freshly formatted OPTIONS-GHC file.
"
" usage: this is a helper function not directly invoked by the user.  instead, 
" another top-level function in this file invokes this function as part of its 
" work of generating a parsed OPTIONS_GHC flags file.
function! s:format() abort
  " open the OPTIONS-GHC formatted file.  if none exists, vim opens a new file.
  :execute ":vsp" g:phask_ops_ghc_formatted_iofile
  " delete all file content.
  " see /u/ martin tournoij @ https://tinyurl.com/4m5a3d5f (vi.SE)
  " see also :h range
  :1,$:delete
  " import all contents of the original (unformatted) OPTIONS-GHC file.
  " for file insertion, see https://vim.fandom.com/wiki/Insert_a_file
  :execute ":1r" g:phask_ops_ghc_orig_ifile
  " delete all imported header lines appearing at the top.
  " see :help range
  :1;/^=\+\s*+\+ OPTIONS_GHC FLAGS/-1d
  " replace the deleted headers with imported headers from a template file.
  " `:0r`, see /u/ stefan van den akker @ https://tinyurl.com/mr238hmd (so)
  :execute ":0r" g:phask_ops_ghc_formatted_header_ifile
  " format the file into neatly separated columns.
  :call s:formatFile()
  " move the cursor to the top of the file.
  :execute 'normal! gg'
  " save the file.
  :write
  " close the file.
  :quit
endfunction

" ==============================================================================
" runs a quick-and-dirty test on the generated parsed OPTIONS-GHC flags file, 
" checking if the number of lines in that file match an expected count. if the 
" test fails, meaning there is a mismatch in line count, throws an exception.
"
" usage: this is a helper function not directly invoked by the end user.  
" instead, a top-lelevl function in this file invokes this function as part of 
" its work of verifying the generated (parsed) OPTIONS_GHC flags file.
function! s:testFlagCount() abort
  " open OPTIONS-GHC-FLAGS-FORMATTED file
  :execute ":vsp" g:phask_ops_ghc_formatted_iofile
  " count lines that a parse of OPTIONS_GHC flags in this file would generate.
  " this count will be the "expected" count.
  :let l:ecnt = s:countFlags()
  " close the file.
  :quit
  " now open the generated parsed OPTIONS-GHC flags file.
  :execute ":vsp" g:phask_ops_ghc_parsed_ofile
  " count the lines in the parsed output file. this will be the "actual" count.
  " on `line('$')`, see /u/ kev @ https://tinyurl.com/5axjp3dm (so)
  :let l:acnt = line('$')
  " close the file.
  :quit
  " stuff the counts as well as the test status in a dictionary.
  " on dictionary use, see https://developer.ibm.com/tutorials/l-vim-script-4/
  :let l:res = {'actual' : l:acnt, 'expected' : l:ecnt, 'flag' : l:acnt == l:ecnt ? 'PASS' : 'FAIL'}
  " if there is a test failure, throw an exception to alert the caller.
  :if (l:res).flag ==# 'FAIL'
  : throw "test failed -- incorrect OPTIONS_GHC flags parsed: " .. string(l:res)
  :endif
endfunction

" ==============================================================================
" display formatted and parsed OPTIONS-GHC-FLAGS files.
" useful for users who want to preview the files visually.
"
" usage: open vim and run `:call DisplayOptionsGhcFiles()` on vim commandline.
function! DisplayOptionsGhcFiles() abort
  :execute ':vsp' g:phask_ops_ghc_formatted_iofile
  :execute ":sp" g:phask_ops_ghc_parsed_ofile
endfunction

" ==============================================================================
function! s:formatFile() abort
  " Formats a OPTIONS-GHC-FLAGS file.
  " sample output: ~/dotfiles/vim/haskell/data/OPTIONS-GHC-FLAGS-FORMATTED.txt
  " basically, this function formats line data into neatly separated columns.
  "
  " 19 MAR 2023; author: Prem Muthedath
  "
  " usage: well, how do you use this function?
  "   well, this helper function is not directly invoked by the end user.  
  "   instead, it is invoked by a top-level function that does the following:
  "   (a) first makes a copy of OPTIONS-GHC-FLAGS-ORIGINAL.txt;
  "   (c) then opens that copy in vim;
  "   (d) then does some editing, replacing some existing comments and headers;
  "   (e) then invokes this function on the edited copy;
  "   (f) this function then formats the file into neatly separated columns;
  "   (g) the invoking function then saves the changes and closes the file.
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
  "      (blah, bazooze, -foo-dynamic) and the 2nd column `dynamic` using:
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
function! s:parseFlags() abort
  " reads OPTIONS-GHC-FLAGS-FORMATTED.txt, extracts OPTIONS_GHC flags, and 
  " returns the extracted flags as a list.
  "
  " author: Prem Muthedath, 27 MAR 2023.
  "
  " usage: this helper function is not directly invoked by the end user.  
  " instead, a top-level function, or another function, involved in generating 
  " OPTIONS_GHC flags invokes this routine.  that top-level function, which is 
  " in this file, calls this function, & dumps results of the call to a file.
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
  " on `list`, see https://developer.ibm.com/tutorials/l-vim-script-3/ define & 
  " initialize some local variables.
  :let l:flags=[]
  :let l:pat1='\s\+dynamic\($\|\s\+\)'
  :let l:pat2=',\s'
  :let l:pat='\(' .. l:pat1 .. '\)' .. '\|' .. '\(' .. l:pat2 .. '\)'
  " read formatted OPTIONS-GHC-FLAGS file, parse each line, & return results.
  :for line in readfile(g:phask_ops_ghc_formatted_iofile)
    " header: ^== ++++++++++++ OPTIONS_GHC FLAGS FOR GHC 8.10.4 ++++++++++++
  : if line =~# '^=\+\s*+\+[[:upper:]-_. [:digit:]]\++\+\s*$'
      " change to: ^++++++++++++ OPTIONS_GHC FLAGS FOR GHC 8.10.4 ++++++++++++
  :   let line = substitute(line, '^=\+\s*', '', '')
  :   call add(l:flags, line)
    " lines such as: ^============== VERBOSITY OPTIONS
  : elseif line =~# '^=\+[[:upper:]- ]\+$'
  :   call add(l:flags, line)
    " data lines (w/t or w/o comma) such as: ^-O, -O1     dynamic   -O0
  : elseif line =~# '^-.*$'
  :   let l:lines=split(line, l:pat)
  :   call extend(l:flags, l:lines)
  : endif
  :endfor
  :return l:flags
endfunction

" ==============================================================================
function! s:countFlags() abort
  " counts lines an expected correct parse of OPTIONS-GHC flags would generate.  
  " this count involves:
  "   1. count of OPTIONS_GHC flags;
  "   2. count of headers that a correct parse would include.
  " the total count reported is the sum of (1) & (2).
  "
  " NOTE: see `usage` for more details.
  "
  " this count acts as a rule-of-thumb test for the generated 
  " vim/haskell/data/OPTIONS-GHC-FLAGS-PARSED-LIST.txt. the total number of 
  " lines in that file should match the count reported by this function.
  "
  " code idea from /u/ mMontu @ https://tinyurl.com/y6s8mxpz (so).
  " replaced `v` with `g` here; of course, the patterns apply only for use here.
  "
  " usage: this is a helper function not directly called by end user.  instead, 
  " another function opens vim/haskell/data/OPTIONS-GHC-FLAGS-FORMATTED.txt and 
  " runs this function on that file. that invoking function is in this file.
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

