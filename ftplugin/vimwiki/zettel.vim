" format of a new zettel filename
if !exists('g:zettel_format')
  let g:zettel_format = "%y%m%d-%H%M"
endif


function! s:wiki_yank_name()
  let filename = expand("%")
  let link = zettel#vimwiki#get_link(filename)
  let clipboardtype=&clipboard
  if clipboardtype=="unnamed"  
    let @* = link
  elseif clipboardtype=="unnamedplus"
    let @+ = link
  else
    let @@ = link
  endif
  return link
endfunction

" replace file name under cursor which corresponds to a wiki file with a
" corresponding Wiki link
function! s:replace_file_with_link()
  let filename = expand("<cfile>")
  let link = zettel#vimwiki#get_link(filename)
  execute "normal BvExa" . link
endfunction





" make fulltext search in all VimWiki files using FZF and insert link to the
" found file
" command! -bang -nargs=* ZettelSearch call fzf#vim#ag(<q-args>, 
command! -bang -nargs=* ZettelSearch call zettel#fzf#sink_onefile(<q-args>, 'zettel#fzf#wiki_search')

command! -bang -nargs=* ZettelYankName call <sid>wiki_yank_name()

" crate new zettel using command
command! -bang -nargs=* ZettelNew call zettel#vimwiki#zettel_new(<q-args>)

command! -buffer ZettelGenerateLinks call zettel#vimwiki#generate_links()
command! -buffer -nargs=* -complete=custom,vimwiki#tags#complete_tags
      \ ZettelGenerateTags call zettel#vimwiki#generate_tags(<f-args>)

command! -buffer ZettelBackLinks call zettel#vimwiki#backlinks()
command! -buffer ZettelInbox call zettel#vimwiki#inbox()

if !exists('g:zettel_default_mappings')
  let g:zettel_default_mappings=1
endif


nnoremap <silent> <Plug>ZettelSearchMap :ZettelSearch<cr>
nnoremap <silent> <Plug>ZettelYankNameMap :ZettelYankName<cr> 
nnoremap <silent> <Plug>ZettelReplaceFileWithLink :call <sid>replace_file_with_link()<cr> 
xnoremap <silent> <Plug>ZettelNewSelectedMap :call zettel#vimwiki#zettel_new_selected()<CR>


if g:zettel_default_mappings==1
  " inoremap [[ [[<esc>:ZettelSearch<CR>
  imap <silent> [[ [[<esc><Plug>ZettelSearchMap
  nmap T <Plug>ZettelYankNameMap
  " xnoremap z :call zettel#vimwiki#zettel_new_selected()<CR>
  xmap z <Plug>ZettelNewSelectedMap
  nmap gZ <Plug>ZettelReplaceFileWithLink
endif
