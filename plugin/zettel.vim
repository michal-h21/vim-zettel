if exists("g:loaded_zettel") || &cp
  finish
endif

let g:loaded_zettel = 1


" gloabal commands
command! -count=1 ZettelCapture
      \ call zettel#vimwiki#zettel_capture(v:count1)

" make fulltext search in all VimWiki files using FZF
" command! -bang -nargs=* ZettelSearch call fzf#vim#ag(<q-args>, 
command! -bang -nargs=* ZettelInsertNote call zettel#fzf#execute_fzf(<q-args>, 
      \'--skip-vcs-ignores', fzf#vim#with_preview({
      \'down': '~40%',
      \'sink*':function('zettel#fzf#insert_note'),
      \'dir': vimwiki#vars#get_wikilocal('path',0),
      \'options':['--exact']}))
