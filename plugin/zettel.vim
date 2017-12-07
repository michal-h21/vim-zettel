if exists("g:loaded_zettel") || &cp
  finish
endif

let g:loaded_zettel = 1

" gloabal commands
command! -count=1 ZettelCapture
      \ call zettel#vimwiki#zettel_capture(v:count1)
