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

function! zettel#vimwiki#get_visual_selection()
  return <sid>get_visual_selection()
endfunction

" this function is useful for comands in plugin/zettel.vim
" set number of the active wiki
function! zettel#vimwiki#set_active_wiki(number)
  " this buffer value is used by vimwiki#vars#get_wikilocal to retrieve
  " the current wiki number
  call setbufvar("%","vimwiki_wiki_nr", a:number)
endfunction

" get the first non emtpy wiki idx from the options
function! zettel#vimwiki#get_wiki_nr_from_options()
  let i = 0
  let sel_index = 0
  while i < len(g:zettel_options)
    if len(keys(g:zettel_options[i])) > 0
      let sel_index = i
      break
    endif
    let i += 1
  endwhile
  return sel_index
endfunction

" set default wiki number. it is set to -1 when no wiki is initialized
" we will set it to first wiki in wiki list, with number 0
function! zettel#vimwiki#initialize_wiki_number()
  if getbufvar("%", "vimwiki_wiki_nr") == -1
    if !exists('g:zettel_options') && !exists('g:zettel_default_wiki_nr')
      call zettel#vimwiki#set_active_wiki(0)
    elseif exists('g:zettel_default_wiki_nr')
      call zettel#vimwiki#set_active_wiki(g:zettel_default_wiki_nr)
    else
      let idx = zettel#vimwiki#get_wiki_nr_from_options()
      echom("setting  wiki number: " . idx)
      if idx > -1
        call zettel#vimwiki#set_active_wiki(idx)
      else
        call zettel#vimwiki#set_active_wiki(0)
      endif
    endif
  endif
endfunction
call zettel#vimwiki#initialize_wiki_number()

" get user option for the current wiki
" it seems that it is not possible to set custom options in g:vimwiki_list
" so we need to use our own options
function! zettel#vimwiki#get_option(name, ...)
  if !exists('g:zettel_options')
    return ""
  endif
  " the options for particular wikis must be in the same order as wiki
  " definitions in g:vimwiki_list
  let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
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

let s:test_header_end = function(vimwiki#vars#get_wikilocal('syntax', vimwiki#vars#get_bufferlocal('wiki_nr')) ==? 'markdown' ? '<sid>test_header_end_md' : '<sid>test_header_end_wiki')

" variables that depend on the wiki syntax
if vimwiki#vars#get_wikilocal('syntax',  vimwiki#vars#get_bufferlocal('wiki_nr')) ==? 'markdown'
  " add file extension when g:vimwiki_markdown_link_ext is set
  if exists("g:vimwiki_markdown_link_ext") && g:vimwiki_markdown_link_ext == 1
    let s:link_format = "[%title](%link.md)"
    " TODO: s:link_stub used to be different than s:link_format, but it is no longer
    " the case. maybe we can get rid of it?
    let s:link_stub =  "[%title](%link.md)"
  else
    let s:link_format = "[%title](%link)"
    let s:link_stub =  "[%title](%link)"
  endif
  let s:header_format = "%s: %s"
  let s:header_delimiter = "---"
  let s:insert_mode_title_format = "``l"
  let s:grep_link_pattern = '/\(.*%s\.\{-}m\{-}d\{-}\)/' " match filename in  parens. including optional .md extension
  let s:section_pattern = "# %s"
else
  let s:link_format = "[[%link|%title]]"
  let s:link_stub = "[[%link|%title]]"
  let s:header_format = "%%%s %s"
  let s:header_delimiter = ""
  let s:insert_mode_title_format = "h"
  let s:grep_link_pattern = '/\[.*%s[|#\]]/'

  let s:section_pattern = "= %s ="
endif

" enable overriding of
if exists("g:zettel_link_format")
  let s:link_format = g:zettel_link_format
  let s:link_stub =  g:zettel_link_format
endif

let s:tag_pattern = '^!_TAG'
function! zettel#vimwiki#update_listing(lines, title, links_rx, level)
  let generator = { 'data': a:lines }
  function generator.f() dict
    return self.data
  endfunction
  call vimwiki#base#update_listing_in_buffer(generator, a:title, a:links_rx, line('$')+1, a:level, 1)
endfunction

" user configurable fields that should be inserted to a front matter of a new
" Zettel
if !exists('g:zettel_front_matter')
  let g:zettel_front_matter = {}
endif

" front matter can be disabled using disable_front_matter local wiki option
let g:zettel_disable_front_matter = zettel#vimwiki#get_option("disable_front_matter")
if empty(g:zettel_disable_front_matter)
  let g:zettel_disable_front_matter=0
endif

if !exists('g:zettel_generated_index_title')
  let g:zettel_generated_index_title = "Generated Index"
endif
if !exists('g:zettel_generated_index_title_level')
  let g:zettel_generated_index_title_level = 1
endif

if !exists('g:zettel_backlinks_title')
  let g:zettel_backlinks_title = "Backlinks"
endif
if !exists('g:zettel_backlinks_title_level')
  let g:zettel_backlinks_title_level = 1
endif

if !exists('g:zettel_unlinked_notes_title')
  let g:zettel_unlinked_notes_title = "Unlinked Notes"
endif
if !exists('g:zettel_unlinked_notes_title_level')
  let g:zettel_unlinked_notes_title_level = 1
endif

if !exists('g:zettel_generated_tags_title')
  let g:zettel_generated_tags_title = "Generated Tags"
endif
if !exists('g:zettel_generated_tags_title_level')
  let g:zettel_generated_tags_title_level = 1
endif

" format of a new zettel filename
if !exists('g:zettel_format')
  let g:zettel_format = "%y%m%d-%H%M"
endif


" default title used for %title placeholder in g:zettel_format if the title is
" empty
if !exists('g:zettel_default_title')
  let g:zettel_default_title="untitled"
endif

" Fixes for Neovim
if has('nvim')

  " make string filled with random characters
  function! zettel#vimwiki#make_random_chars()
    call luaeval("math.randomseed( os.time() )")
    let char_no = range(g:zettel_random_chars)
    let str_list = []
    for x in char_no
      call add(str_list, nr2char(luaeval("math.random(97,122)")))
    endfor
    return join(str_list, "")
  endfunction

elseif v:version < 802
  function! zettel#vimwiki#make_random_chars()
    let char_no = range(g:zettel_random_chars)
    let str_list = []
    for x in char_no
      call add(str_list, nr2char(matchstr(reltimestr(reltime()), '\v\.@<=\d+')%26+97))
    endfor
    return join(str_list, "")
  endfunction

else

  " make string filled with random characters
  function! zettel#vimwiki#make_random_chars()
    let seed = srand()
    return range(g:zettel_random_chars)->map({-> (97+rand(seed) % 26)->nr2char()})->join('')
  endfunction
endif

" number of random characters used in %random placehoder in new zettel name
if !exists('g:zettel_random_chars')
  let g:zettel_random_chars=8
endif
let s:randomchars = zettel#vimwiki#make_random_chars()

" default date format used in front matter for new zettel
if !exists('g:zettel_date_format')
  let g:zettel_date_format = "%Y-%m-%d %H:%M"
endif

" initialize new zettel date. it should be overwritten in zettel#vimwiki#create()
let s:zettel_date = strftime(g:zettel_date_format)


" find end of the front matter variables
function! zettel#vimwiki#find_header_end(filename)
  let lines = readfile(a:filename)
  " Markdown and Vimwiki use different formats for metadata header, select the
  " right one according to the file type
  let ext = fnamemodify(a:filename, ":e")
  let Header_test = function(ext ==? 'md' ? '<sid>test_header_end_md' : '<sid>test_header_end_wiki')
  let i = 0
  for line in lines
    " let res = s:test_header_end(line, i)
    let res = Header_test(line, i)
    if res > -1
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

" enable functions to be passed as front_matter values
" this can be useful to dynamic value setting
function! s:expand_front_matter_value(value)
  " enable execution of functions that expands to the correct value
  if type(a:value) == v:t_func
    return a:value()
  else
    return a:value
  endif
endfunction

function! s:make_header_item(key, value)
  let val = <sid>expand_front_matter_value(a:value)
  return printf(s:header_format, a:key, val)
endfunction

" add a variable to the zettel header
function! s:add_to_header(key, value)
  call <sid>add_line(s:make_header_item(a:key, a:value))
endfunction

let s:letters = "abcdefghijklmnopqrstuvwxyz"

" convert number to str (1 -> a, 27 -> aa)
function! s:numtoletter(num)
  let numletter = strlen(s:letters)
  let charindex = a:num % numletter
  let quotient = a:num / numletter
  if (charindex-1 == -1)
    let charindex = numletter
    let quotient = quotient - 1
  endif

  let result =  strpart(s:letters, charindex - 1, 1)
  if (quotient>=1)
    return <sid>numtoletter(float2nr(quotient)) . result
  endif
  return result
endfunction

" title and date to a new zettel note
function! zettel#vimwiki#template(title, date)
  if g:zettel_disable_front_matter == 0
    call <sid>add_line(s:header_delimiter)
    call <sid>add_to_header("date", a:date)
    call <sid>add_to_header("title", a:title)
    call <sid>add_line(s:header_delimiter)
  endif
endfunction


" sanitize title for filename
function! zettel#vimwiki#escape_filename(name)
  let name = substitute(a:name, "[%.%,%?%!%:]", "", "g") " remove unwanted characters
  let schar = vimwiki#vars#get_wikilocal('links_space_char') " ' ' by default
  let name = substitute(name, " ", schar, "g") " change spaces to link_space_char

  let name = tolower(name)
  return fnameescape(name)
endfunction

" count files that match pattern in the current wiki or if additional indenx
" provided in the wiki indentified by the index
function! zettel#vimwiki#count_files(pattern, ...)
  let cwd = a:0 ? zettel#vimwiki#path(a:1) : zettel#vimwiki#path()
  let filelist = split(globpath(cwd, a:pattern), '\n')
  return len(filelist)
endfunction

function! zettel#vimwiki#next_counted_file(...)
  " count notes in the current / reference wiki directory and return
  let ext = a:0 ? vimwiki#vars#get_wikilocal('ext', a:1) : vimwiki#vars#get_wikilocal('ext')
  let next_file = a:0 ? zettel#vimwiki#count_files("*" . ext, a:1) + 1 : vimwiki#vars#get_wikilocal('ext')
  return next_file
endfunction

function! zettel#vimwiki#new_zettel_name(...)
  let newformat = g:zettel_format
  let l:idx = vimwiki#vars#get_bufferlocal('wiki_nr')
  if a:0 > 0 && a:1 != ""
    " title contains safe version of the original title
    " raw_title is exact title
    let title = zettel#vimwiki#escape_filename(a:1)
    let raw_title = a:1
  else
    let title = zettel#vimwiki#escape_filename(g:zettel_default_title)
    let raw_title = g:zettel_default_title
  endif
  " expand title in the zettel_format
  let newformat = substitute(g:zettel_format, "%title", title, "")
  let newformat = substitute(newformat, "%raw_title", raw_title, "")
  if matchstr(newformat, "%file_no") != ""
    let next_file = zettel#vimwiki#next_counted_file(l:idx)
    let newformat = substitute(newformat,"%file_no", next_file, "")
  endif
  if matchstr(newformat, "%file_alpha") != ""
    " same as file_no, but convert numbers to letters
    let next_file = s:numtoletter(zettel#vimwiki#next_counted_file(l:idx))
    let newformat = substitute(newformat,"%file_alpha", next_file, "")
  endif
  if matchstr(newformat, "%random") != ""
    " generate random characters, their number is set by g:zettel_random_chars
    " random characters are set using zettel#vimwiki#make_random_chars()
    " this function is set at the startup and then each time
    " zettel#vimwiki#create() is called. we don't call it here because we
    " would get wrong links in zettel_new_selected(). It calls new_zettel_name
    " twice.
    let newformat = substitute(newformat, "%random", s:randomchars, "")
  endif
  let final_format =  strftime(newformat)
  if !s:wiki_file_not_exists(final_format)
    " if the current file name is used, increase counter and add it as a
    " letter to the file name. this ensures that we don't reuse the filename
    let file_count = zettel#vimwiki#count_files(final_format . "*", l:idx)
    let final_format = final_format . s:numtoletter(file_count)
  endif
  let g:zettel_current_id = final_format
  return final_format
endfunction

" the optional argument is the wiki number
function! zettel#vimwiki#save_wiki_page(format, ...)
  let l:zettel_path = a:0 ? zettel#vimwiki#path(a:1) : zettel#vimwiki#path()
  let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
  let newfile = l:zettel_path . a:format . vimwiki#vars#get_wikilocal('ext',idx )
  " copy the captured file to a new zettel
  execute "w! " . newfile
  return newfile
endfunction

" find title in the zettel file and return correct link to it
function! zettel#vimwiki#get_link(filename)
  let title =zettel#vimwiki#get_title(a:filename)
  let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
  let wiki_path =  zettel#vimwiki#path(idx)
  " we will use absolute path from the wiki root for backlinks. This should
  " fix issues with relative paths from subdirectories or diary
  let wikiname = "/" . vimwiki#base#subdir(wiki_path, fnamemodify(a:filename, ":p")).
    \ substitute(fnamemodify(a:filename, ':t'), vimwiki#vars#get_wikilocal('ext', vimwiki#vars#get_bufferlocal('wiki_nr')) . '$' , '', '')
  if title == ""
    " use the Zettel filename as title if it is empty
    let title = wikiname
  endif
  let link= zettel#vimwiki#format_link(wikiname, title)
  return link
endfunction

" copy of function from Vimwiki
" Params: full path to a wiki file and its wiki number
" Returns: a list of all links inside the wiki file
" Every list item has the form
" [target file, anchor, line number of the link in source file, column number]
function! s:get_links(wikifile, idx)
  if !filereadable(a:wikifile)
    return []
  endif

  let syntax = vimwiki#vars#get_wikilocal('syntax', a:idx)
  let rx_link = vimwiki#vars#get_syntaxlocal('wikilink', syntax)
  let links = []
  let lnum = 0

  for line in readfile(a:wikifile)
    let lnum += 1

    let link_count = 1
    while 1
      let col = match(line, rx_link, 0, link_count)+1
      let link_text = matchstr(line, rx_link, 0, link_count)
      echomsg("link text " . line . " - " . link_text)
      if link_text == ''
        break
      endif
      let link_count += 1
      let target = vimwiki#base#resolve_link(link_text, a:wikifile)
      if target.filename != '' && target.scheme =~# '\mwiki\d\+\|diary\|file\|local'
        call add(links, [target.filename, target.anchor, lnum, col])
      endif
    endwhile
  endfor

  return links
endfunction

" return list of files that match a pattern
function! zettel#vimwiki#wikigrep(pattern)
  let paths = []
  let idx = vimwiki#vars#get_bufferlocal('wiki_nr')
  let path = fnameescape(zettel#vimwiki#path(idx))
  let ext = vimwiki#vars#get_wikilocal('ext', idx)
  try
    let command = 'vimgrep ' . a:pattern . 'j ' . path . "**/*" . ext
    noautocmd  execute  command
  catch /^Vim\%((\a\+)\)\=:E480/   " No Match
    "Ignore it, and move on to the next file
  endtry
  for d in getqflist()
    let filename = fnamemodify(bufname(d.bufnr), ":p")
    call add(paths, filename)
  endfor
  call uniq(paths)
  return paths
endfunction

function! zettel#vimwiki#format_file_title(format, file, title)
  let link = substitute(a:format, "%title", a:title, "")
  let link = substitute(link, "%link", a:file, "")
  return link
endfunction

" use different link style for wiki and markdown syntaxes
function! zettel#vimwiki#format_link(file, title)
  return zettel#vimwiki#format_file_title(s:link_format, a:file, a:title)
endfunction

function zettel#vimwiki#make_path_relative_to_curfile(targetfile, curfile)
  " the following line should support Windows paths with backslashes, but I
  " don't think Windows require backslashes in paths anymore:
  " let s:path_sep = execute('version') =~# 'Windows' ? '\' : '/'
  let s:path_sep = '/'
  let path_target = split(a:targetfile, s:path_sep)
  let path_current = split(a:curfile, s:path_sep)

  " drop common prefix
  while(path_target[0] == path_current[0])
  let path_target = path_target[1:]
  let path_current = path_current[1:]
    endwhile

    " add as many '..' elements to the target path as we have elements in our current path
    while(len(path_current) > 1)
    let path_current = path_current[1:]
    let path_target = extend(path_target, ['..'], 0)
    endwhile

    return join(path_target, s:path_sep)
endfunction

function! zettel#vimwiki#format_search_link(file, title)
  " in case the target we're linking to is not where we are, we need to figure out the
  " relativ path to where it is, so that the links will work
  let new_rel_file_path = zettel#vimwiki#make_path_relative_to_curfile(fnamemodify(a:file, ':p'), fnamemodify(@%, ':p'))

  return zettel#vimwiki#format_file_title(s:link_stub, l:new_rel_file_path, a:title)
endfunction

" This function is executed when the page referenced by the inserted link
" doesn't contain  title. The cursor is placed at the position where title
" should start, and insert mode is started
function! zettel#vimwiki#insert_mode_in_title()
  execute "normal! " .s:insert_mode_title_format | :startinsert
endfunction

function! zettel#vimwiki#get_title(filename)
  let filename = a:filename
  let title = ""
  let lsource = readfile(filename)
  let is_markdown = <sid>is_markdown()
  " this code comes from vimwiki's html export plugin
  " Try to load the title from the front matter entry which is present
  " at the head of a file. If the front matter is not present use the first
  " headline as title either in vimwiki or markup style.
  for line in lsource
    " Check if front matter title is present
    if line =~# '^\s*%\=title'
      let title = matchstr(line, '^\s*%\=title:\=\s\zs.*')
      return title
    endif
    if is_markdown
      " Check if first headline is present in markdown style
      " \zs marks the start of the match part
      " \ze marks the end of the match part
      if line =~# '^\s*#\s*.*'
        let title = matchstr(line, '^\s*#\s*\zs.*\ze')
        return title
      endif
    else
      " Check if first headline is present in vimwiki style
      " \zs marks the start of the match part
      " \ze marks the end of the match part
      if line =~# '^\s*=\s\+.*\S\s\+=\s*'
        let title = matchstr(line, '^\s*=\s\+\zs.*\S\ze\s\+=\s*')
        return title
      endif
    endif
  endfor
  return ""
endfunction


" check if the file with the current filename exits in wiki
function! s:wiki_file_not_exists(filename, ...)
  let l:zettel_path = a:0 ?  zettel#vimwiki#path(a:1) : zettel#vimwiki#path()
  let link_info = vimwiki#base#resolve_link(a:filename, zettel_path)
  return empty(glob(link_info.filename))
endfunction

function! zettel#vimwiki#path(...) abort
  " Return: diary directory path <String>
  " calling with wnum = 0 means we let vimwiki figure it out
  let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
  return vimwiki#vars#get_wikilocal('path', idx).zettel#vimwiki#get_option('rel_path', idx)
endfunction

" create new zettel note
" there is one optional argument, the zettel title
function! zettel#vimwiki#create(wiki_nr,...)
  " name of the new note
  let format = zettel#vimwiki#new_zettel_name(a:1)
  let date_format = g:zettel_date_format
  let date = strftime(date_format)
  echomsg("new zettel: ". format)
  " update random chars used in %random name format
  let s:randomchars = zettel#vimwiki#make_random_chars()
  let s:zettel_date = date " save zettel date
  " detect if the wiki file exists
  let wiki_not_exists = s:wiki_file_not_exists(format, a:wiki_nr)

  if match(vimwiki#path#current_wiki_file(), vimwiki#vars#get_wikilocal('path',a:wiki_nr)) == 0
    " let vimwiki to open the wiki file. this is necessary
    " to support the vimwiki navigation commands.
    let vimwikiabspath = "/". zettel#vimwiki#get_option('rel_path', a:wiki_nr) . format
    call vimwiki#base#open_link(':e ', vimwikiabspath)
  else
    " this happens when we run :ZettelNew outside of wiki. we need to pass
    " the full path, so the file will be saved in the correct directory.
    " Vimwiki navigation commands will not work in the new note.
    let zettelpath = zettel#vimwiki#path(a:wiki_nr)
    let ext = vimwiki#vars#get_wikilocal('ext', a:wiki_nr)
    execute(':e ' . zettelpath . format . ext)
  endif
  " add basic template to the new file
  if wiki_not_exists
    call zettel#vimwiki#template(a:1, date)
    return format
  endif
  return -1
endfunction

" front_matter can be either list or dict. if it is a dict, then convert it to
" list
function! s:front_matter_list(front_matter)
  if type(a:front_matter) ==? v:t_list
    return a:front_matter
  endif
  " it is prefered to use a list for front_matter, as it keeps the order of
  " keys. but it is possible to use dict, to keep the backwards compatibility
  let newlist = []
  for key in keys(a:front_matter)
    call add(newlist, [key, a:front_matter[key]])
  endfor
  return newlist
endfunction

function! zettel#vimwiki#zettel_new(...)
  " TODO: the user should be able to pass a wiki number (1 indexed)
  let wiki_nr = vimwiki#vars#get_bufferlocal('wiki_nr')
  if wiki_nr < 0  " this happens when e.g. VimwikiMakeDiaryNote was called outside a wiki buffer
    let wiki_nr = 0
  endif


  if wiki_nr >= vimwiki#vars#number_of_wikis()
    call vimwiki#u#error('Wiki '.wiki_nr.' is not registered in g:vimwiki_list!')
    return
  endif
  call vimwiki#path#mkdir(vimwiki#vars#get_wikilocal('path', wiki_nr).
        \ zettel#vimwiki#get_option('rel_path', wiki_nr))

  let filename = zettel#vimwiki#create(wiki_nr, a:1)
  " the wiki file already exists
  if filename ==? -1
    return 0
  endif
  let front_matter = zettel#vimwiki#get_option("front_matter")
  if g:zettel_disable_front_matter == 0
    if !empty(front_matter)
      let newfile = zettel#vimwiki#save_wiki_page(filename)
      let last_header_line = zettel#vimwiki#find_header_end(newfile)
      " ensure that front_matter is a list
      let front_list = s:front_matter_list(front_matter)
      " we must reverse the list, because each line is inserted before the
      " ones inserted earlier
      for values in reverse(copy(front_list))
        call append(last_header_line, <sid>make_header_item(values[0], values[1]))
      endfor
    endif
  endif

  " insert the template text from a template file if it is configured in
  " g:zettel_options for the current wiki
  let template = zettel#vimwiki#get_option("template")
  if !empty(template)
    let variables = get(a:, 2, 0)
    if empty(variables)
      " save file, in order to prevent errors in variable reading
      execute "w"
      let variables = zettel#vimwiki#prepare_template_variables(expand("%"), a:1)
      " backlink contains link to the new note itself, so we will just disable
      " it. backlinks are available only when the new note is created using
      " ZettelNewSelectedMap (`z` letter in visual mode by default).
      let variables.backlink = ""
    endif
    " we may reuse varaibles from the parent zettel. date would be wrong in this case,
    " so we will overwrite it with the current zettel date
    let variables.date = s:zettel_date
    " enable also Zettel ID
    let variables.id   = filename
    call zettel#vimwiki#expand_template(template, variables)
  endif
  " save the new wiki file
  execute "w"

endfunction

" crate zettel link from a selected text
function! zettel#vimwiki#zettel_new_selected()
  let title = <sid>get_visual_selection()
  let name = zettel#vimwiki#new_zettel_name(title)
  " prepare_template_variables needs the file saved on disk
  execute "w"
  " make variables that will be available in the new page template
  let variables = zettel#vimwiki#prepare_template_variables(expand("%"), title)
  let linktitle = "\\\\0"
  if match(vimwiki#path#current_wiki_file(), zettel#vimwiki#path()) != 0
    " if we are NOT in the zettelkasten, we should use absolute (vimwiki
    " root-relative absolute) paths for the name
    let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
    let prefix =  zettel#vimwiki#get_option('rel_path', idx)
    let name = "/" . prefix . name
    execute "normal! :'<,'>s:\\%V.*\\%V.:" . zettel#vimwiki#format_link( name, linktitle) ."\<cr>\<C-o>"
  else
    " if we are in zettelkasten, we should get absolute path anyway, but we
    " use format_search_link to get a relative path to the current file
    " https://github.com/michal-h21/vim-zettel/issues/155
    let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
    let prefix =  zettel#vimwiki#get_option('rel_path', idx)
    let name = zettel#vimwiki#path(idx) . prefix . name
    execute "normal! :'<,'>s:\\%V.*\\%V.:" . zettel#vimwiki#format_search_link( name, linktitle) ."\<cr>\<C-o>"
  endif
  " replace the visually selected text with a link to the new zettel
  " \\%V.*\\%V. should select the whole visual selection
  call zettel#vimwiki#zettel_new(title, variables)
endfunction

function! zettel#vimwiki#zettel_capture_selected(title)
  let selection = zettel#vimwiki#get_visual_selection()
  let title = a:title
  let name = zettel#vimwiki#new_zettel_name(title)
  " prepare_template_variables needs the file saved on disk
  execute "write"
  " make variables that will be available in the new page template
  let variables = zettel#vimwiki#prepare_template_variables(expand("%"), title)
  let linktitle = "\\\\0"
  if match(vimwiki#path#current_wiki_file(), zettel#vimwiki#path()) != 0
    " if we are NOT in the zettelkasten, we should use absolute (vimwiki
    " root-relative absolute) paths for the name
    let idx = a:0 ? a:1 : vimwiki#vars#get_bufferlocal('wiki_nr')
    let prefix =  zettel#vimwiki#get_option('rel_path', idx)
    let name = "/" . prefix . name
    let linktitle = prefix . linktitle
  endif
  " replace the visually selected text with a link to the new zettel
  " \\%V.*\\%V. should select the whole visual selection
  execute "normal! :'<,'>s:\\%V.*\\%V.:" . zettel#vimwiki#format_link( name, linktitle) ."\<cr>\<C-o>"
  call zettel#vimwiki#zettel_new(title, variables)
  " paste selection at end of file
  execute "normal! Go" . selection
endfunction

" prepare variables that will be available to expand in the new note template
function! zettel#vimwiki#prepare_template_variables(filename, title)
  let variables = {}
  let variables.title = a:title
  let variables.date = s:zettel_date
  " add variables from front_matter, to make them available in the template
  let front_matter = zettel#vimwiki#get_option("front_matter")
  if !empty(front_matter)
    let front_list = s:front_matter_list(front_matter)
    for entry in copy(front_list)
      let variables[entry[0]] = <sid>expand_front_matter_value(entry[1])
    endfor
  endif
  let variables.backlink = zettel#vimwiki#get_link(a:filename)
  " we want to save footer of the parent note. It can contain stuff that can
  " be useful in the child note, like citations,  etc. Footer is everything
  " below last horizontal rule (----)
  let variables.footer = s:read_footer(a:filename)
  return variables
endfunction

" find and return footer in the file
" footer is content below last horizontal rule (----)
function! s:read_footer(filename)
  let lines = readfile(a:filename)
  let footer_lines = []
  let found_footer = -1
  " return empty footer if we couldn't find the footer
  let footer = ""
  " process lines from the last one and try to find the rule
  for line in reverse(lines)
    if match(line, "^ \*----") == 0
      let found_footer = 0
      break
    endif
    call add(footer_lines, line)
  endfor
  if found_footer == 0
    let footer = join(reverse(footer_lines), "\n")
  endif
  return footer
endfunction

" populate new note using template
function! zettel#vimwiki#expand_template(template, variables)
  " readfile returns list, we need to convert it to string
  " in order to do global replace
  let template_file = expand(a:template)
  if !filereadable(template_file)
    return
  endif
  let content = readfile(template_file)
  let text = join(content, "\n")
  for key in keys(a:variables)
    let text = substitute(text, "%" . key, a:variables[key], "g")
  endfor
  " when front_matter is disabled, there is an empty line before
  " start of the inserted template. we need to ignore it.
  let correction = 0
  if line('$') == 1
    let correction = 1
  endif
  " add template at the end
  " we must split it,
  for xline in split(text, "\n")
    call append(line('$') - correction, xline)
  endfor
endfunction

" make new zettel from a file. the file contents will be copied to a new
" zettel, the original file contents will be replaced with the zettel filename
" use temporary file if you want to keep the original file
function! zettel#vimwiki#zettel_capture(wnum,...)
  let origfile = expand("%")
  execute "set ft=vimwiki"
  " This probably doesn't work with current vimwiki code
  if a:wnum > vimwiki#vars#number_of_wikis()
    echomsg 'Vimwiki Error: Wiki '.a:wnum.' is not registered in g:vimwiki_list!'
    return
  endif
  if a:wnum > 0
    let idx = a:wnum
  else
    let idx = 0
  endif
  let title = zettel#vimwiki#get_title(origfile)
  let format = zettel#vimwiki#new_zettel_name(title)
  " let link_info = vimwiki#base#resolve_link(format)
  let newfile = zettel#vimwiki#save_wiki_page(format, idx)
  " delete contents of the captured file
  execute "normal! ggdG"
  " replace it with a address of the zettel file
  execute "normal! i" . newfile
  execute "w"
  " open the new zettel
  execute "e " . newfile
endfunction


function! zettel#vimwiki#find_files(wiki_nr, directories_only, ...) abort
  " adapted from vimwiki
  " Returns: a list containing all files of the given wiki as absolute file path.
  " If the given wiki number is negative, the current wiki is used
  " If the second argument is not zero, only directories are found
  " If third argument: pattern to search for
  let wiki_nr = a:wiki_nr
  if wiki_nr >= 0
    let root_directory = zettel#vimwiki#path(wiki_nr)
  else
    let root_directory = zettel#vimwiki#path()
    let wiki_nr = vimwiki#vars#get_bufferlocal('wiki_nr')
  endif
  if a:directories_only
    let ext = '/'
  else
    let ext = vimwiki#vars#get_wikilocal('ext', wiki_nr)
  endif
  " If pattern is given, use it
  " if current wiki is temporary -- was added by an arbitrary wiki file then do
  " not search wiki files in subdirectories. Or it would hang the system if
  " wiki file was created in $HOME or C:/ dirs.
  if a:0 && a:1 !=# ''
    let pattern = a:1
  elseif vimwiki#vars#get_wikilocal('is_temporary_wiki', wiki_nr)
    let pattern = '*'.ext
  else
    let pattern = '**/*'.ext
  endif
  let files = split(globpath(root_directory, pattern), '\n')

  " filter excluded files before returning
  for pattern in vimwiki#vars#get_wikilocal('exclude_files')
    let efiles = split(globpath(root_directory, pattern), '\n')
    let files = filter(files, 'index(efiles, v:val) == -1')
  endfor

  return files
endfunction

" based on vimwikis "get wiki links", not stripping file extension
function! zettel#vimwiki#get_wikilinks(wiki_nr, also_absolute_links)
  let files = zettel#vimwiki#find_files(a:wiki_nr, 0)
  if a:wiki_nr == vimwiki#vars#get_bufferlocal('wiki_nr')
    let cwd = vimwiki#path#wikify_path(expand('%:p:h'))
  elseif a:wiki_nr < 0
    let cwd = zettel#vimwiki#path()
  else
    let cwd = vimwiki#vars#get_wikilocal('path', a:wiki_nr)
  endif

  let result = []
  for wikifile in files
    let wikifile = vimwiki#path#relpath(cwd,  wikifile)
    call add(result, wikifile)
  endfor
  if a:also_absolute_links
    for wikifile in files
      let wikifile = '/'.vimwiki#path#relpath(cwd, wikifile)
      call add(result, wikifile)
    endfor
  endif
  return result
endfunction

" add link with title of the file referenced in the second argument to the
" array in the first argument
function! s:add_bulleted_link(lines, abs_filepath)
  let bullet = repeat(' ', vimwiki#lst#get_list_margin()) . vimwiki#lst#default_symbol().' '
  call add(a:lines, bullet.
        \ zettel#vimwiki#get_link(a:abs_filepath))
  return a:lines
endfunction



" insert list of links to the current page
function! s:insert_link_array(title, lines, level)
  let links_rx = '\m^\s*'.vimwiki#u#escape(vimwiki#lst#default_symbol()).' '
  call zettel#vimwiki#update_listing(a:lines, a:title, links_rx, a:level)
endfunction


" based on vimwikis "generate links", adding the %title to the link
function! zettel#vimwiki#generate_links()
  let lines = []

  let links = zettel#vimwiki#get_wikilinks(vimwiki#vars#get_bufferlocal('wiki_nr'), 0)
  call reverse(sort(links))

  let bullet = repeat(' ', vimwiki#lst#get_list_margin()) . vimwiki#lst#default_symbol().' '
  for link in links
    let abs_filepath = vimwiki#path#abs_path_of_link(link)
    "let abs_filepath = link
    "if !s:is_diary_file(abs_filepath)
    call add(lines, bullet.
          \ zettel#vimwiki#get_link(abs_filepath))
    "endif
  endfor
  call s:insert_link_array(g:zettel_generated_index_title, lines, g:zettel_generated_index_title_level)
endfunction

function! s:is_markdown()
  return vimwiki#vars#get_wikilocal('syntax', vimwiki#vars#get_bufferlocal('wiki_nr')) ==? 'markdown'
endfunction

" detect if we are running in the development version of Vimwiki
function! s:is_vimwiki_devel()
  return exists("*vimwiki#base#complete_file")
endfunction

" test if link in the Backlinks section
function! s:is_in_backlinks(file, filenamepattern)
  let f = readfile(a:file)
  let content = join(f, "\n")
  " search for backlinks section
  let backlinks_pattern = printf(s:section_pattern, g:zettel_backlinks_title)
  let backlinks_pos = matchstrpos(content, backlinks_pattern)
  " if we cannot find backlinks in the page return false
  if backlinks_pos[1] == -1
    return -1
  endif
  let file_pos = matchstrpos(content, a:filenamepattern)
  " link is in backlinks when it is placed after the Backlinks section title
  return backlinks_pos[1] < file_pos[1]
endfunction


" based on vimwikis "backlinks"
" insert backlinks of the current page in a section
function! zettel#vimwiki#backlinks()
  let current_filename = expand("%:t:r")
  " find [filename| or [filename] to support both wiki and md syntax
  let filenamepattern = printf(s:grep_link_pattern, current_filename)
  let locations = []
  let backfiles = zettel#vimwiki#wikigrep(filenamepattern)
  for file in backfiles
    " only add backlink if it is not already backlink
    let is_backlink = s:is_in_backlinks(file, current_filename)
    if is_backlink < 1
      " Make sure we don't add ourselves
      if !(file ==# expand("%:p"))
        call s:add_bulleted_link(locations, file)
      endif
    endif
  endfor

  if empty(locations)
    echomsg 'Vimzettel: No other file links to this file'
  else
    call uniq(locations)
    " Insert back links section
    call s:insert_link_array(g:zettel_backlinks_title, locations, g:zettel_backlinks_title_level)
  endif
endfunction

function! zettel#vimwiki#inbox()
  " detect development version of Vimwiki, where check_links can take arguments
  if <sid>is_vimwiki_devel()
    " 0 means that it will search only the current wiki
    call vimwiki#base#check_links(0,0,0)
  else
    call vimwiki#base#check_links()
  endif
  let linklist = getqflist()
  cclose
  let paths = []
  " normalize the current wiki path
  let cwd = fnamemodify(zettel#vimwiki#path(), ":p:h")
  let bullet = repeat(' ', vimwiki#lst#get_list_margin()) . vimwiki#lst#default_symbol().' '
  for d in linklist
    " detect files that are not reachable from the wiki index
    let filenamematch = matchstr(d.text,'\zs.*\ze is not reachable')
    if filenamematch != "" && filereadable(filenamematch)
      " use only files from the current wiki, we get files from all registered
      " wikis here
      let filepath = fnamemodify(filenamematch, ":p:h")
      if filepath ==# cwd
        " TODO: make the links a valid path from the current file
        call add(paths, bullet.
              \ zettel#vimwiki#get_link(filenamematch))
      endif
    endif
  endfor
  if empty(paths)
  else
    " remove duplicates and insert inbox section
    call uniq(paths)
    call s:insert_link_array(g:zettel_unlinked_notes_title, paths, g:zettel_unlinked_notes_title_level)
  endif

endfunction

" copy from vimtiki#tags.vim
function! s:load_tags_metadata() abort
  " Load tags metadata from file, returns a dictionary
  let metadata_path = vimwiki#tags#metadata_file_path()
  if !filereadable(metadata_path)
    return {}
  endif
  let metadata = {}
  for line in readfile(metadata_path)
    if line =~# '^!_TAG_.*$'
      continue
    endif
    let parts = matchlist(line, '^\(.\{-}\);"\(.*\)$')
    if parts[0] ==? '' || parts[1] ==? '' || parts[2] ==? ''
      throw 'VimwikiTags1: Metadata file corrupted'
    endif
    let std_fields = split(parts[1], '\t')
    if len(std_fields) != 3
      throw 'VimwikiTags2: Metadata file corrupted'
    endif
    let vw_part = parts[2]
    if vw_part[0] !=? "\t"
      throw 'VimwikiTags3: Metadata file corrupted'
    endif
    let vw_fields = split(vw_part[1:], "\t")
    if len(vw_fields) != 1 || vw_fields[0] !~# '^vimwiki:'
      throw 'VimwikiTags4: Metadata file corrupted'
    endif
    let vw_data = substitute(vw_fields[0], '^vimwiki:', '', '')
    let vw_data = substitute(vw_data, '\\n', "\n", 'g')
    let vw_data = substitute(vw_data, '\\r', "\r", 'g')
    let vw_data = substitute(vw_data, '\\t', "\t", 'g')
    let vw_data = substitute(vw_data, '\\\\', "\\", 'g')
    let vw_fields = split(vw_data, "\t")
    if len(vw_fields) != 3
      throw 'VimwikiTags5: Metadata file corrupted'
    endif
    let pagename = vw_fields[0]
    let entry = {}
    let entry.tagname  = std_fields[0]
    let entry.lineno   = std_fields[2]
    let entry.filename  = std_fields[1]
    let entry.link     = vw_fields[1]
    let entry.description = vw_fields[2]
    if has_key(metadata, pagename)
      call add(metadata[pagename], entry)
    else
      let metadata[pagename] = [entry]
    endif
  endfor
  return metadata
endfunction


" based on vimwiki
function! zettel#vimwiki#generate_tags(...) abort
  let need_all_tags = (a:0 == 0)
  let specific_tags = a:000

  let metadata = s:load_tags_metadata()

  " make a dictionary { tag_name: [tag_links, ...] }
  let tags_entries = {}
  for entries in values(metadata)
    for entry in entries
      if has_key(tags_entries, entry.tagname)
        call add(tags_entries[entry.tagname], entry.filename)
      else
        let tags_entries[entry.tagname] = [entry.filename]
      endif
    endfor
  endfor

  let rxH_TemplateName = 'rxH'.(g:zettel_generated_index_title_level + 1).'_Template'
  let lines = []
  let bullet = repeat(' ', vimwiki#lst#get_list_margin()).vimwiki#lst#default_symbol().' '
  for tagname in sort(keys(tags_entries))
    if need_all_tags || index(specific_tags, tagname) != -1
      call extend(lines, [
            \ '',
            \ substitute(vimwiki#vars#get_syntaxlocal(rxH_TemplateName), '__Header__', tagname, ''),
            \ '' ])
      for taglink in reverse(sort(tags_entries[tagname]))
        let filepath = vimwiki#path#abs_path_of_link(taglink)
        if filereadable(filepath)
          call add(lines, bullet . zettel#vimwiki#get_link(filepath))
        endif
      endfor
    endif
  endfor

  let links_rx = '\m\%(^\s*$\)\|\%('.vimwiki#vars#get_syntaxlocal('rxH2').'\)\|\%(^\s*'
        \ .vimwiki#u#escape(vimwiki#lst#default_symbol()).' '
        \ .vimwiki#vars#get_syntaxlocal('rxWikiLink').'$\)'

  call zettel#vimwiki#update_listing(lines, g:zettel_generated_tags_title, links_rx, g:zettel_generated_tags_title_level)
endfunction
