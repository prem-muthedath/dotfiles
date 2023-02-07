" customizing cabal file syntax.
" created: 7 FEB 2023.
" author: Prem Muthedath
" ==============================================================================

" add app as cabalCategory keyword
" REF: for code location: /u/ ralph @ https://tinyurl.com/bdec7scb (vi.SE)
" REF: code source: /u/ tommy a @ https://tinyurl.com/2p8pvvsk (vi.SE)
" REF: also see :help containedin
syn keyword cabalCategory app containedin=Type

" use another highlighting (not RED!) for `true` and `false` values.
highlight link cabalTruth Type
" ==============================================================================

