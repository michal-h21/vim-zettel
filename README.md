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

## Filenames

By default, `Vim-zettel` creates filename in the form `YYMMDD-HHMM`. This
format can be changed using the `g:zettel_format` variable. Any date and time
formats supported by the `strftime()` function.

It is also possible to use other formatting strings:

- `%title` -- insert sanitized title
- `%raw_title` -- insert raw title
- `file_no` -- sequentially number files in wiki
- `file_alpha` -- sequentially number files in wiki, but use characters instead of numbers

To use filename based on current time and note title, you can use the following format:

    let g:zettel_format = "%y%m%d-%H%M-%title"

For sequentialy named files use:

    let g:zettel_format = "%file_no"

# Usage

`Vim-zettel` adds some commands and mappings on top of
[Vimwiki](http://vimwiki.github.io/). See Vimwiki documentation on how to set up a
basic wiki and navigate it.

## Commands available in the Vimwiki mode

- `:ZettelNew` command – it will create a new wiki file named as
  `%y%m%d-%H%M.wiki` (it is possible to change the file name format using
  `g:zettel_format` variable). The file uses basic template in the form

  ```
  %title Note title
  %date current date
  ```
  where title is the first parameter to `:ZettelNew`.

- `:ZettelBackLinks` command – insert list of notes that link to the current note.

- `:ZettelInbox` command – insert list of notes that no other note links to.

- `:ZettelGenerateLinks` command – insert list of all wiki pages in the current
  page. It needs updated tags database. The tags database can be updated  using the
  `:VimwikiRebuildTags` command.

- `:ZettelGenerateTags` command – insert list of tags and pages that used these tags in the current
  page. It needs updated tags database. The tags database can be updated  using the `:VimwikiRebuildTagsh` command.

- `z` command in the visual mode – create a new wiki file using selected text
  for the note title 

- `[[` command in the insert mode – create a link to a note. It uses FZF for the note searching.

- `T` command in the normal mode – yank the current note filename and title as a Vimwiki link

- `gZ` command in the normal mode – replace file path under cursor with Wiki link


## Useful Vimwiki commands

- `:VimwikiBacklinks` - display files that link to the current page
- `:VimwikiCheckLinks`- display files that no other file links to

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
