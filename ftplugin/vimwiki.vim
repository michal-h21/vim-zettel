 " get active VimWiki directory
let g:zettel_dir = vimwiki#vars#get_wikilocal('path') "VimwikiGet('path',g:vimwiki_current_idx)

" FZF command used in the ZettelSearch command
if !exists('g:zettel_fzf_command')
  let g:zettel_fzf_command = "ag"
endif

" format of a new zettel filename
if !exists('g:zettel_format')
  let g:zettel_format = "%y%m%d-%H%M"
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

function! s:wiki_search(line)
  let filename = <sid>get_fzf_filename(a:line)
  let title = <sid>get_zettel_title(filename)
  " insert the filename and title into the current buffer
  let wikiname = <sid>get_wiki_file(filename)
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

function! s:wiki_yank_name()
  let filename = expand("%")
  let link = zettel#vimwiki#get_link(filename)
  let @@ = link
  return link
endfunction

" replace file name under cursor which corresponds to a wiki file with a
" corresponding Wiki link
function! s:replace_file_with_link()
  let filename = expand("<cfile>")
  let link = zettel#vimwiki#get_link(filename)
  execute "normal BvExa" . link
endfunction



function! s:execute_fzf(a, b, options)
  let Fzf_cmd = function("fzf#vim#" . g:zettel_fzf_command)
  return Fzf_cmd(a:a, a:b, a:options)
endfunction


" make fulltext search in all VimWiki files using FZF
" command! -bang -nargs=* ZettelSearch call fzf#vim#ag(<q-args>, 
command! -bang -nargs=* ZettelSearch call <sid>execute_fzf(<q-args>, 
      \'--skip-vcs-ignores', fzf#vim#with_preview({
      \'down': '~40%',
      \'sink':function('<sid>wiki_search'),
      \'dir':g:zettel_dir,
      \'options':['--exact']}))


command! -bang -nargs=* ZettelNew call zettel#vimwiki#zettel_new(<q-args>)

command! -bang -nargs=* ZettelYankName call <sid>wiki_yank_name()

command! -buffer ZettelGenerateLinks call zettel#vimwiki#generate_links()
command! -buffer -nargs=* -complete=custom,vimwiki#tags#complete_tags
      \ ZettelGenerateTags call zettel#vimwiki#generate_tags(<f-args>)

command! -buffer ZettelBackLinks call zettel#vimwiki#backlinks()
command! -buffer ZettelInbox call zettel#vimwiki#inbox()

if !exists('g:zettel_default_mappings')
  let g:zettel_default_mappings=1
endif

if !exists('g:zettel_filename_title')
    let g:zettel_filename_title=0
endif

nnoremap <silent> <Plug>ZettelSearchMap :ZettelSearch<cr>
nnoremap <silent> <Plug>ZettelYankNameMap :ZettelYankName<cr> 
nnoremap <silent> <Plug>ZettelReplaceFileWithLink :call <sid>replace_file_with_link()<cr> 
xnoremap <silent> <Plug>ZettelNewSelectedMap :call zettel#vimwiki#zettel_new_selected()<CR>


if g:zettel_default_mappings==1
  " inoremap [[ [[<esc>:ZettelSearch<CR>
  imap <silent> [[ [[<esc><Plug>ZettelSearchMap
  nmap T <Plug>ZettelYankNameMap
  " xnoremap z :call zettel#vimwiki#zettel_new_selected()<CR>
  xmap z <Plug>ZettelNewSelectedMap
  nmap gZ <Plug>ZettelReplaceFileWithLink
endif
