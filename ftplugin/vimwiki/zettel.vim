" format of a new zettel filename
if !exists('g:zettel_format')
  let g:zettel_format = "%y%m%d-%H%M"
endif


function! s:wiki_yank_name()
  let filename = expand("%")
  let link = zettel#vimwiki#get_link(filename)
  call setreg(v:register, link)
  return link
endfunction

" replace file name under cursor which corresponds to a wiki file with a
" corresponding Wiki link
function! s:replace_file_with_link()
  let filename = expand("<cfile>")
  let link = zettel#vimwiki#get_link(filename)
  execute "normal BvExa" . link
endfunction





" use visually selected text as a text for a link to note returned by FZF

command! -bang -nargs=* ZettelSearch call zettel#fzf#sink_onefile(<q-args>, 'zettel#fzf#wiki_search')

command! -bang -nargs=* ZettelTitleSelected call zettel#fzf#sink_onefile(<q-args>, 'zettel#fzf#title_selected')

command! -bang -nargs=* ZettelYankName call <sid>wiki_yank_name()

command! -buffer ZettelGenerateLinks call zettel#vimwiki#generate_links()
command! -buffer -nargs=* -complete=custom,vimwiki#tags#complete_tags
      \ ZettelGenerateTags call zettel#vimwiki#generate_tags(<f-args>)

command! -buffer ZettelBackLinks call zettel#vimwiki#backlinks()
command! -buffer ZettelInbox call zettel#vimwiki#inbox()

command! -bang -nargs=* ZettelSelectBuffer call fzf#run({
      \   'source':  reverse(zettel#fzf#buflist()),
      \   'sink':    function('zettel#fzf#bufopen'),
      \   'options': '+m',
      \   'down':    len(zettel#fzf#buflist()) + 2
      \ })

if !exists('g:zettel_default_mappings')
  let g:zettel_default_mappings=1
endif


nnoremap <silent> <Plug>ZettelSearchMap :ZettelSearch<cr>
nnoremap <silent> <Plug>ZettelYankNameMap :ZettelYankName<cr> 
nnoremap <silent> <Plug>ZettelReplaceFileWithLink :call <sid>replace_file_with_link()<cr> 
xnoremap <silent> <Plug>ZettelNewSelectedMap :call zettel#vimwiki#zettel_new_selected()<CR>
" make fulltext search in all VimWiki files using FZF and insert link to the
" found file
" <C-U> is needed to prevent the "E481: No range alllowed" error
xnoremap <silent> <Plug>ZettelTitleSelectedMap :<C-U>ZettelTitleSelected<CR>


if g:zettel_default_mappings==1
  " inoremap [[ [[<esc>:ZettelSearch<CR>
  imap <buffer> <silent> [[ [[<esc><Plug>ZettelSearchMap
  nmap <buffer> T <Plug>ZettelYankNameMap
  " xnoremap z :call zettel#vimwiki#zettel_new_selected()<CR>
  xmap <buffer> z <Plug>ZettelNewSelectedMap
  xmap <buffer> g[ <Plug>ZettelTitleSelectedMap
  nmap <buffer> gZ <Plug>ZettelReplaceFileWithLink
endif
