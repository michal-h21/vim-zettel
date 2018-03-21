 " get active VimWiki directory
let g:zettel_dir = VimwikiGet('path',g:vimwiki_current_idx)
" format of a new zettel filename
if !exists('g:zettel_format')
  let g:zettel_format = "%y%m%d-%H%M"
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
  return filename
endfunction

" get clean wiki name from a filename
function! s:get_wiki_file(filename)
  return expand("%:t:r")
endfunction

function! s:wiki_search(line)
  let filename = <sid>get_fzf_filename(a:line)
  let title = <sid>get_zettel_title(filename)
  " insert the filename and title into the current buffer
  " ToDo: make the format of inserted link configurable
  let wikiname = <sid>get_wiki_file(filename)
  execute 'normal a'. wikiname  . "|" . title
endfunction

function! s:wiki_yank_name()
  let filename = expand("%")
  let title = <sid>get_zettel_title(filename)
  let wikiname = <sid>get_wiki_file(filename)
  " let link= "[[" . wikiname . "|" . title . "]]"
  let link= zettel#vimwiki#format_link(wikiname, title)
  let @" = link
  return link
endfunction


" make fulltext search in all VimWiki files using FZF
command! -bang -nargs=* ZettelSearch call fzf#vim#ag(<q-args>, 
      \'--skip-vcs-ignores', {
      \'down': '~40%',
      \'sink':function('<sid>wiki_search'),
      \'dir':g:zettel_dir,
      \'options':'--exact'})


command! -bang -nargs=* ZettelNew call zettel#vimwiki#zettel_new(<q-args>)

command! -bang -nargs=* ZettelYankName call <sid>wiki_yank_name()

if !exists('g:zettel_default_mappings')
  let g:zettel_default_mappings=1
endif

nnoremap <silent> <Plug>ZettelSearchMap :ZettelSearch<cr>
nnoremap <silent> <Plug>ZettelYankNameMap :ZettelYankName<cr> 
xnoremap <silent> <Plug>ZettelNewSelectedMap :call zettel#vimwiki#zettel_new_selected()<CR>

if g:zettel_default_mappings==1
  " inoremap [[ [[<esc>:ZettelSearch<CR>
  imap <silent> [[ [[<esc><Plug>ZettelSearchMap
  nmap T <Plug>ZettelYankNameMap
  " xnoremap z :call zettel#vimwiki#zettel_new_selected()<CR>
  xmap z <Plug>ZettelNewSelectedMap
endif
