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

" markdown test for front matter end
function! s:test_header_end_md(line, i)
  if a:i > 0 
    let pos = matchstrpos(a:line, "^\s*---")
    return pos[1]
  endif
  return -1
endfunction

" vimwiki test fot front matter end
function! s:test_header_end_wiki(line, i)
  " return false for all lines that start with % character
  let pos = matchstrpos(a:line,"^\s*%")
  if pos[1] > -1 
    return -1
  endif
  " first line which is not tag should be selected
  return 0
endfunction

let s:test_header_end = function(vimwiki#vars#get_wikilocal('syntax') ==? 'markdown' ? '<sid>test_header_end_md' : '<sid>test_header_end_wiki')


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

" find end of the front matter variables
function! zettel#vimwiki#find_header_end(filename)
  echom("otevírám " . a:filename)
  let lines = readfile(a:filename)
  let i = 0
  for line in lines
    let res = s:test_header_end(line, i)
    if res > -1 
      " call append(i, "This is the end")
      return i
    endif
    let i = i + 1
  endfor
  return 0
endfunction

" helper function to insert a text line to a new zettel
function! s:add_line(text)
  " don't append anything if the argument is empty string
  if len(a:text) > 0
    call append(line("1"), a:text)
  endif
endfunction

function! s:make_header_item(key, value)
  return printf(s:header_format, a:key, a:value)
endfunction

" add a variable to the zettel header
function! s:add_to_header(key, value)
  call <sid>add_line(s:make_header_item(a:key, a:value))
endfunction


" title and date to a new zettel note
function! zettel#vimwiki#template(title, date)
  call <sid>add_line(s:header_delimiter)
  call <sid>add_to_header("date", a:date)
  call <sid>add_to_header("title", a:title)
  call <sid>add_line(s:header_delimiter)
endfunction

function! zettel#vimwiki#new_zettel_name()
  return strftime(g:zettel_format)
endfunction

" the optional argument is the wiki number
function! zettel#vimwiki#save_wiki_page(format, ...)
  let defaultidx = vimwiki#vars#get_bufferlocal('wiki_nr')
  let idx = get(a:, 1, defaultidx)
  let newfile = vimwiki#vars#get_wikilocal('path',idx ) . a:format . vimwiki#vars#get_wikilocal('ext',idx )
  " copy the captured file to a new zettel
  execute ":w! " . newfile
  return newfile
endfunction

" find title in the zettel file and return correct link to it
function! zettel#vimwiki#get_link(filename)
  let title =zettel#vimwiki#get_title(a:filename)
  let wikiname = fnamemodify(a:filename, ":t:r")
  let link= zettel#vimwiki#format_link(wikiname, title)
  return link
endfunction

" use different link style for wiki and markdown syntaxes
function! zettel#vimwiki#format_link(file, title)
  let link = substitute(s:link_format, "%title", a:title, "")
  let link = substitute(link, "%link", a:file, "")
  return link
endfunction

function! zettel#vimwiki#get_title(filename)
  let filename = a:filename
  let title = ""
  let lsource = readfile(filename)
  " this code comes from vimwiki's html export plugin
  for line in lsource 
    if line =~# '^\s*%\=title'
      let title = matchstr(line, '^\s*%\=title:\=\s\zs.*')
      return title
    endif
  endfor 
  return ""
endfunction


" create new zettel note
" there is one optional argument, the zettel title
function! zettel#vimwiki#create(...)
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
    call zettel#vimwiki#template(a:1, date_format)
    return format
  endif
  return 0
endfunction

function! zettel#vimwiki#zettel_new(...)
  let filename = zettel#vimwiki#create(a:1)
  " the wiki file already exists
  if filename == 0
    return 0
  endif
  " save the new wiki file
  execute ":w"
  let front_matter = zettel#vimwiki#get_option("front_matter")
  if !empty(front_matter)
    let newfile = zettel#vimwiki#save_wiki_page(filename)
    let last_header_line = zettel#vimwiki#find_header_end(newfile)
    echom(last_header_line)
    for key in keys(front_matter)
       " <sid>add_to_header(key, front_matter[key])
       call append(last_header_line, <sid>make_header_item(key, front_matter[key]))
    endfor
  endif

  " insert the template text from a template file if it is configured in
  " g:zettel_options for the current wiki
  let template = zettel#vimwiki#get_option("template")
  if !empty(template)
    execute "read " . template
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
  let newfile = zettel#vimwiki#save_wiki_page(format, idx)
  " delete contents of the captured file
  execute "normal! ggdG"
  " replace it with a address of the zettel file
  execute "normal! i" . newfile 
  execute ":w"
  " open the new zettel
  execute ":e " . newfile
endfunction

