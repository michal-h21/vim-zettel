" title and date to a new zettel note
function! zettel#vimwiki#template(title, date)
  call append(line("1"), "%date " . a:date)
  call append(line("1"), "%title ". a:title)
endfunction

" create new zettel note
" there is one optional argument, the zettel title
function! zettel#vimwiki#zettel_new(...)
  " name of the new note
  let format = strftime(g:zettel_format)
  let date_format = strftime("%Y-%m-%d %H:%M")
  echom("new zettel". format)
  let link_info = vimwiki#base#resolve_link(format)
  " detect if the wiki file exists
  let wiki_not_exists = empty(glob(link_info.filename)) 
  " let vimwiki to open the wiki file. this is necessary  
  " to support the vimwiki navigation commands.
  call vimwiki#base#open_link(':e ', format)
  " add basic template to the new file
  if wiki_not_exists
    call zettel#vimwiki#template(a:1, date_format)
  endif
endfunction

