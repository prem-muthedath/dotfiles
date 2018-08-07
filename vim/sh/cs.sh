# file contains bash commands to output &comments and &commentstring info got 
# from files under /usr/share/vim/vim80/ftplugin

# 'raw' output - full paths + corresponding &comments + &commentstring data  
find "/usr/share/vim/vim80/ftplugin" -type f -print0 | xargs -0 grep 'commentstring=\|comments=\|com=' | sort > vim/notes/cs-raw.vim > vim/notes/cs-raw.vim

 
# 'cleansed' output - filenames + corresponding &comments + &commentstring data
find "/usr/share/vim/vim80/ftplugin" -type f -print0 | xargs -0 grep 'commentstring=\|comments=\|com=' | sort | sed -E -e 's/setlocal//' -e 's/formatoptions.*$//' -e 's/include.*$//' -e 's/^.*\/(.*\.vim)/\1/' > vim/notes/cs.vim


