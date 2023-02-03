" some examples of `execute` usage
:execute 'normal 0/' . "\\%" . line('.') . 'lthis' . "\<cr>"
:execute 'normal 0/' . "\\%" . line('.') . 'l^s* \*' . "\<cr>"
:execute 'normal 0/' . "\\%" . line('.') . "l\\*\\/\s*$" . "\<cr>"
:execute 'normal 0/' . "\\%" . line('.') . 'l^\s*' . escape(' *', '\/*') . "\<cr>"
:execute 'normal 0/' . "\\%" . line('.') . 'l^\s*' . s:esc(a:first) . "\<CR>"
:execute 'normal 0/' . "\\%" . line('.') . 'l^\s*' . ' polp ' . '/e-' . (len(' polp ')-1) . "\<CR>"

/\%34l^\s* \*/e-0
:execute 'normal /' . "\\%" . "34l^\s*  \*" . "\<CR>"

:execute 'normal o' . "\<Esc>" . 'tc' . '=='
:execute 'normal o' . "\<Esc>" . 'tc' . '==' . 'l' . 'a'
:execute 'normal o' . "\<Esc>" . 'tc' . '==' . '2la ' | :startinsert
:execute 'echo len(' . '" " . Cs()[1])'
:execute 'call len(" " . Cs()[1])'


