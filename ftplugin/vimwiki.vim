" get active VimWiki directory
let g:zettel_dir = VimwikiGet('path',g:vimwiki_current_idx)
" format of a new zettel filename
if !exists('g:zettel_format')
  let g:zettel_format = "%y%m%d-%H%M.wiki"
endif

" vimwiki files can have titles in the form of %title title content
function! s:get_zettel_title(filename)
  let filename = a:filename
  let title = ""
  let lsource = readfile(filename)
  " this code comes from vimwiki's html export plugin
  for line in lsource 
    if line =~# '^\s*%title'
      let title = matchstr(line, '^\s*%title\s\zs.*')
      return title
    endif
  endfor 
  return ""
endfunction

" fzf returns selected filename and matched line from the file, we need to
" strip that
function! s:get_fzf_filename(line)
  " the filename is separated by : from rest of the line
  let parts =  split(a:line,":")
  " we need to remove the extension
  let filename = parts[0]
  let title = <sid>get_zettel_title(filename)
  let fileparts = split(filename, '\V.')
  " insert the filename and title into the current buffer
  " ToDo: make the format of inserted link configurable
  execute 'normal a' join(fileparts[0:-2],".") . "|" . title
endfunction

" make fulltext search in all VimWiki files using FZF
command! -bang -nargs=* ZettelSearch call fzf#vim#ag(<q-args>, 
      \'--skip-vcs-ignores', {
      \'down': '~40%',
      \'sink':function('<sid>get_fzf_filename'),
      \'dir':g:zettel_dir,
      \'options':'--exact'})


command! ZettelNew call zettel#vimwiki#zettel_new()

" remap [[ to start fulltext search
inoremap [[ [[<esc>:ZettelSearch<CR>

