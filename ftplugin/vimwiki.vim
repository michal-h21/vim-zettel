" get active VimWiki directory
let g:zettel_dir = VimwikiGet('path',g:vimwiki_current_idx)

" fzf returns selected filename and matched line from the file, we need to
" strip that
function! s:get_fzf_filename(line)
  " the filename is separated by : from rest of the line
  let parts =  split(a:line,":")
  " insert the filename into current buffer
  execute 'normal a' parts[0]
endfunction

" make fulltext search in all VimWiki files using FZF
command! -bang -nargs=* Zettel call fzf#vim#ag(<q-args>, 
      \'--skip-vcs-ignores', {
      \'down': '~40%',
      \'sink':function('<sid>get_fzf_filename'),
      \'dir':g:zettel_dir,
      \'options':'--exact'})


" remap [[ to start fulltext search
inoremap [[ [[<esc>:Zettel<CR>

