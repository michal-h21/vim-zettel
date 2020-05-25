 " get active VimWiki directory
let g:zettel_dir = vimwiki#vars#get_wikilocal('path') "VimwikiGet('path',g:vimwiki_current_idx)

" FZF command used in the ZettelSearch command
if !exists('g:zettel_fzf_command')
  let g:zettel_fzf_command = "ag"
endif

" vimwiki files can have titles in the form of %title title content
function! s:get_zettel_title(filename)
  return zettel#vimwiki#get_title(a:filename)
endfunction

" fzf returns selected filename and matched line from the file, we need to
" strip that
function! s:get_fzf_filename(line)
  " the filename is separated by : from rest of the line
  let parts =  split(a:line,":")
  " we need to remove the extension
  let filename = parts[0]
  return filename
endfunction

" get clean wiki name from a filename
function! s:get_wiki_file(filename)
   let fileparts = split(a:filename, '\V.')
   return join(fileparts[0:-2],".")
endfunction


" execute fzf function
function! zettel#fzf#execute_fzf(a, b, options)
  " I cannot get `ag` running with fzf#vim#grep, so we use
  " two different methods
  if g:zettel_fzf_command == "ag"
    let Fzf_cmd = function("fzf#vim#" . g:zettel_fzf_command)
    return Fzf_cmd(a:a, a:b, a:options)
  else
    " use grep method for other commands
    return fzf#vim#grep(g:zettel_fzf_command . " " . shellescape(a:a), 1, a:options)
  endif
endfunction


" insert link for the searched zettel in the current note
function! zettel#fzf#wiki_search(line,...)
  let deleted_chars = get(a:, 1, 2)
  echom("Deleted chars: " . deleted_chars)
  let filename = s:get_fzf_filename(a:line)
  let title = s:get_zettel_title(filename)
  " insert the filename and title into the current buffer
  let wikiname = s:get_wiki_file(filename)
  " if the title is empty, the link will be hidden by vimwiki, use the filename
  " instead
  if empty(title)
    let title = wikiname
  end
  let link = zettel#vimwiki#format_search_link(wikiname, title)
  let line = getline('.')
  " replace the [[ with selected link and title
  let caret = col('.')
  call setline('.', strpart(line, 0, caret - 2) . link .  strpart(line, caret))
  call cursor(line('.'), caret + len(link) - 2)
  call feedkeys("a", "n")
endfunction


" function!  zettel#fzf#execute_fzf(<q-args>, 
"       \'--skip-vcs-ignores', fzf#vim#with_preview({
"       \'down': '~40%',
"       \'sink':function('zettel#fzf#wiki_search'),
"       \'dir':g:zettel_dir,
"       \'options':['--exact']}))
function! zettel#fzf#insert_note(lines)
  for line in a:lines
    echom("we got line: " . line)
  endfor
endfunction
