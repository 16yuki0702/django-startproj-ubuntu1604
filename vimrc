set hlsearch
set number
set encoding=utf-8
syntax on
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0
map <C-g> :Gtags
map <C-h> :Gtags -f %<CR>
map <C-j> :GtagsCursor<CR>
map <C-k> :Gtags -r <C-r><C-w><CR>
map <C-n> :cn<CR>
map <C-p> :cp<CR>