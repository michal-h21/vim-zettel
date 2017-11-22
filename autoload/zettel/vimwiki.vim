function! zettel#vimwiki#zettel_new(...)
  let format = strftime(g:zettel_format)
  let date_format = strftime("%Y-%m-%d %H:%M")
  echom("new zettel". format)
  " write the basic template to the wiki file
  let link_info = vimwiki#base#resolve_link(format)
  " detect if the wiki file exists
  let wiki_not_exists = empty(glob(link_info.filename)) 
  " let vimwiki to open the wiki file
  call vimwiki#base#open_link(':e ', format)
  " add basic template to the new file
  if wiki_not_exists
    call append(line("1"), "%date " . date_format)
    call append(line("1"), "%title ". a:1)
  endif
endfunction

