" functions used in the construction of the statusline.
" author: Prem Muthedath.

" get the value of the syntax set.
" NOTE:
"   1. used in displaying the syntax value on the status line.
"   2. you could get the value from `echo &syntax`;
"   3. but we need a function for statusline display;
"   4. if you don't use a function, you could end up with this error:
"   5. "E540: Unclosed expression sequence" error.
"   6. REF: https://tinyurl.com/mra9x6f7 (vi.SE)
"   7. REF: https://tinyurl.com/mvy94a4u (so)
function! GetSyntax() abort
  return &syntax
endfunction
