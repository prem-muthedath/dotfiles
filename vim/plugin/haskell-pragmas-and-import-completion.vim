" for glob()`use, see /u/ martin tournoij @ https://tinyurl.com/2t7e3asj (so)
" on `..` use, see :h expr-..
const g:phask_data_dir = glob('~/dotfiles/vim/haskell/data/')

const g:phask_ops_ghc_orig_ifile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-ORIGINAL.txt'
const g:phask_ops_ghc_formatted_iofile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-FORMATTED.txt'

const g:phask_ops_ghc_parsed_ofile = g:phask_data_dir .. 'OPTIONS-GHC-FLAGS-PARSED-LIST.txt'
const g:phask_lang_extns_ofile = g:phask_data_dir .. 'GHC-LANGUAGE-EXTENSIONS-SORTED-LIST.txt'
const g:phask_imp_modules_ofile = g:phask_data_dir .. 'ghcup-cabal-installed-modules.txt'

const g:phask_cabal_inst_pkgs_ofile = g:phask_data_dir .. 'cabal-installed-pkgs.txt'
const g:phask_ghcup_inst_pkgs_ofile = g:phask_data_dir .. 'ghcup-installed-pkgs.txt'


