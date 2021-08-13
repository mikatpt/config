set clipboard=unnamedplus
:nnoremap <Space> :noh<CR>

nnoremap m <Cmd>call VSCodeNotify('editor.action.showHover')<CR>
xmap gc <Plug>VSCodeCommentary
nmap gc <Plug>VSCodeCommentary
omap gc <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentary

" Use J and K to move lines up and down.
nnoremap <S-J> :m .+1<CR>==
nnoremap <S-K> :m .-2<CR>==
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Fix vim Y behavior
nnoremap Y y$

" Fix ctrl backspace behavior
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>