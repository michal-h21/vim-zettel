" source: https://stackoverflow.com/a/6271254/2467963
" get text of the visual selection
function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

" title and date to a new zettel note
function! zettel#vimwiki#template(title, date)
  call append(line("1"), "%date " . a:date)
  call append(line("1"), "%title ". a:title)
endfunction

function! zettel#vimwiki#new_zettel_name()
  return strftime(g:zettel_format)
endfunction

" create new zettel note
" there is one optional argument, the zettel title
function! zettel#vimwiki#zettel_new(...)
  " name of the new note
  let format = zettel#vimwiki#new_zettel_name()
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

" crate zettel link from a selected text
function! zettel#vimwiki#zettel_new_selected()
  let name = zettel#vimwiki#new_zettel_name()
  let title = <sid>get_visual_selection()
  execute "normal! :'<,'>s/\\%V.*/[[". name. "|\\0]]\<cr>\<C-o>"
  call zettel#vimwiki#zettel_new(title)
endfunction
