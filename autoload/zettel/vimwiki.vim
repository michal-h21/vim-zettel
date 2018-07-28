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

" get user option for the current wiki
" it seems that it is not possible to set custom options in g:vimwiki_list
" so we need to use our own options
function! zettel#vimwiki#get_option(name)
  if !exists('g:zettel_options')
    return ""
  end
  " the options for particular wikis must be in the same order as wiki
  " definitions in g:vimwiki_list
  let idx = vimwiki#vars#get_bufferlocal('wiki_nr')
  let option_number = "g:zettel_options[" . idx . "]"
  if exists(option_number)
    if exists(option_number . "." . a:name)
      return g:zettel_options[idx][a:name]
    endif
  endif
  return ""
endfunction

" variables that depend on the wiki syntax
if vimwiki#vars#get_wikilocal('syntax') ==? 'markdown'
  let s:link_format = "[%title](%link)"
  let s:header_format = "%s: %s"
  let s:header_delimiter = "---"
else
  let s:link_format = "[[%link|%title]]"
  let s:header_format = "%%%s %s"
  let s:header_delimiter = ""
end

" user configurable fields that should be inserted to a front matter of a new
" Zettel
if !exists('g:zettel_front_matter')
  let g:zettel_front_matter = {}
endif

" helper function to insert a text line to a new zettel
function! s:add_line(text)
  " don't append anything if the argument is empty string
  if len(a:text) > 0
    call append(line("1"), a:text)
  endif
endfunction

" add a variable to the zettel header
function! s:add_to_header(key, value)
  call <sid>add_line(printf(s:header_format, a:key, a:value))
endfunction


" title and date to a new zettel note
function! zettel#vimwiki#template(title, date, fields)
  call <sid>add_line(s:header_delimiter)
  for key in keys(a:fields)
    call <sid>add_to_header(key, a:fields[key])
  endfor
  call <sid>add_to_header("date", a:date)
  call <sid>add_to_header("title", a:title)
  call <sid>add_line(s:header_delimiter)
endfunction

function! zettel#vimwiki#new_zettel_name()
  return strftime(g:zettel_format)
endfunction

" use different link style for wiki and markdown syntaxes
function! zettel#vimwiki#format_link(file, title)
  let link = substitute(s:link_format, "%title", a:title, "")
  let link = substitute(link, "%link", a:file, "")
  return link
endfunction

" create new zettel note
" there is one optional argument, the zettel title
function! zettel#vimwiki#zettel_new(...)
  " name of the new note
  let format = zettel#vimwiki#new_zettel_name()
  let date_format = strftime("%Y-%m-%d %H:%M")
  echom("new zettel: ". format)
  let link_info = vimwiki#base#resolve_link(format)
  " detect if the wiki file exists
  let wiki_not_exists = empty(glob(link_info.filename)) 
  " let vimwiki to open the wiki file. this is necessary  
  " to support the vimwiki navigation commands.
  call vimwiki#base#open_link(':e ', format)
  " add basic template to the new file
  if wiki_not_exists
    call zettel#vimwiki#template(a:1, date_format, g:zettel_front_matter)
  endif
  echom(vimwiki#vars#get_wikilocal("zettel_template"))
  " insert the template text from a template file if g:zettel_template_file
  " exists
  if exists('g:zettel_template_file')
    execute "read " . g:zettel_template_file
  endif
endfunction

" crate zettel link from a selected text
function! zettel#vimwiki#zettel_new_selected()
  let name = zettel#vimwiki#new_zettel_name()
  let title = <sid>get_visual_selection()
  " replace the visually selected text with a link to the new zettel
  " \\%V.*\\%V. should select the whole visual selection
  execute "normal! :'<,'>s/\\%V.*\\%V./" . zettel#vimwiki#format_link( name, "\\\\0") ."\<cr>\<C-o>"
  call zettel#vimwiki#zettel_new(title)
endfunction

" make new zettel from a file. the file contents will be copied to a new
" zettel, the original file contents will be replaced with the zettel filename
" use temporary file if you want to keep the original file
function! zettel#vimwiki#zettel_capture(wnum,...)
  let origfile = expand("%")
  execute ":set ft=vimwiki"
  " This probably doesn't work with current vimwiki code
  if a:wnum >= vimwiki#vars#number_of_wikis()
    echomsg 'Vimwiki Error: Wiki '.a:wnum.' is not registered in g:vimwiki_list!'
    return
  endif
  if a:wnum > 0
    let idx = a:wnum - 1
  else
    let idx = 0
  endif
  let format = zettel#vimwiki#new_zettel_name()
  " let link_info = vimwiki#base#resolve_link(format)
  let newfile = vimwiki#vars#get_wikilocal('path',idx ) . format . vimwiki#vars#get_wikilocal('ext',idx )
  " copy the captured file to a new zettel
  execute ":w " . newfile
  " delete contents of the captured file
  execute "normal! ggdG"
  " replace it with a address of the zettel file
  execute "normal! i" . newfile 
  execute ":w"
  " open the new zettel
  execute ":e " . newfile
endfunction

