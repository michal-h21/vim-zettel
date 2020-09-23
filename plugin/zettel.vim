if exists("g:loaded_zettel") || &cp
  finish
endif

let g:loaded_zettel = 1


" gloabal commands
command! -nargs=? -bang ZettelCapture
      \ call zettel#vimwiki#zettel_capture(<q-args>)

" make fulltext search in all VimWiki files using FZF
" command! -bang -nargs=* ZettelSearch call fzf#vim#ag(<q-args>, 
command! -bang -nargs=* ZettelInsertNote call zettel#fzf#execute_fzf(<q-args>, 
      \'--skip-vcs-ignores', fzf#vim#with_preview({
      \'down': '~40%',
      \'sink*':function('zettel#fzf#insert_note'),
      \'dir': vimwiki#vars#get_wikilocal('path'),
      \'options':['--exact']}))

" set number of the active wiki
command! -nargs=1 -bang ZettelSetActiveWiki call zettel#vimwiki#set_active_wiki(<q-args>)

" make fulltext search in all VimWiki files using FZF and open the found file
command! -bang -nargs=* ZettelOpen call zettel#fzf#sink_onefile(<q-args>, 'zettel#fzf#search_open')


