# The `vim-zettel` package

This is a Vim plugin that implements ideas of the
[Zettelkasten](https://zettelkasten.de/) method using Vimwiki. This is a work
in progress and it has just a basic features ATM. It supports both Vimwiki and
Markdown syntaxes.

# Install

Using Vundle:


    Plugin 'vimwiki/vimwiki'
    Plugin 'junegunn/fzf'
    Plugin 'junegunn/fzf.vim'
    Plugin 'michal-h21/vim-zettel'
    
[Silver Searcher](https://github.com/ggreer/the_silver_searcher) is used for searching in the notes by default. 
The used command can be changed by setting the `g:zettel_fzf_command` variable.

# Configuration

First of all, it is necessary to configure Vimwiki, as `Vim-zettel` builds on top of it.

    " Settings for Vimwiki
    let g:vimwiki_list = [{'path':'~/scratchbox/vimwiki/markdown/','ext':'.md','syntax':'markdown', 'zettel_template': "~/mytemplate.tpl"}, {"path":"~/scratchbox/vimwiki/wiki/"}]

To open the index page of your wiki, invoke Vim with the following parameters:

    vim -c VimwikiIndex


`Vim-zettel` also provides some custom configurations. The following sample
contains default values for  available settings. It is not necessary to use
them in your `.vimrc` unless you want to use a different value.

    " Filename format. The filename is created using strftime() function
    let g:zettel_format = "%y%m%d-%H%M"
    " command used for VimwikiSearch 
    " possible values: "ag", "rg", "grep"
    let g:zettel_fzf_command = "ag"
    " Disable default keymappings
    let g:zettel_default_mappings = 0 
    " This is basically the same as the default configuration
    augroup filetype_vimwiki
      autocmd!
      autocmd FileType vimwiki imap <silent> [[ [[<esc><Plug>ZettelSearchMap
      autocmd FileType vimwiki nmap T <Plug>ZettelYankNameMap
      autocmd FileType vimwiki xmap z <Plug>ZettelNewSelectedMap
      autocmd FileType vimwiki nmap gZ <Plug>ZettelReplaceFileWithLink
    augroup END

    " Set template and custom header variable for the second Wiki
    let g:zettel_options = [{},{"front_matter" : {"tags" : ""}, "template" :  "~/mytemplate.tpl"}]


# Usage

`Vim-zettel` adds some commands and mappings on top of
[Vimwiki](http://vimwiki.github.io/). See Vimwiki documentation on how to set up a
basic wiki and navigate it.

## Commands available in the Vimwiki mode

- `:ZettelNew` command - it will create a new wiki file named as
  `%y%m%d-%H%M.wiki` (it is possible to change the file name format using
  `g:zettel_format` variable). The file uses basic template in the form

  ```
  %title Note title
  %date current date
  ```

- `z` command in the visual mode - create a new wiki file using selected text
  for the note title 

- `[[` command in the insert mode - create a link to a note. It uses FZF for the note searching.

- `T` command in the normal mode - yank the current note filename and title as a Vimwiki link

- `gZ` command in the normal mode - replace file path under cursor with Wiki link

## Useful Vimwiki commands

- `:VimwikiBacklinks` - display files that link to the current page
- `:VimwikiCheckLinks`- display files that no other file links to
- `:VimwikiGenerateTags`- generate index of notes sorted by tags in the current page

## Import text from the command line

- `:ZettelCapture` - create a new Zettel from a file. This command is useful for scripting. It can be used in the following way:

  ```
  vim -c ZettelCapture filename
  ```

  The original file contents will be replaced with a path to the new wiki file.
  It should be used with temporary files!

# Related packages

The following packages may be useful in conjunction with Vimwiki and Vim-zettel:

- [Notational FZF](https://github.com/alok/notational-fzf-vim) - fast searching notes with preview window.

To search in the Zettelkasten, set the following variable with path to the Zettelkaster direcory in `.vimrc`:

    let g:nv_search_paths = ['/path/to/zettelkasten/dir']

- [Vimwiki-sync](https://github.com/michal-h21/vimwiki-sync) - automatically commit changes in wiki and synchronize them with external Git repository.
