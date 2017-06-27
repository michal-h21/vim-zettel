function! zettel#vimwiki#zettel_new()
  let format = strftime(g:zettel_format)
  " echom("new zettel". format)
  " this doesn't work
  " execute 'normal :e' format
  execute "edit +" . "1" . format
endfunction

echom("Nahrávám autoload")
