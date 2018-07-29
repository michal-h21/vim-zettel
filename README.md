# The `vim-zettel` package

This is a Vim plugin that implements ideas of the
[Zettelkasten](https://zettelkasten.de/) method using Vimwiki. This is a work
in progress and it has just a basic features ATM. It supports both Vimwiki and
Markdown syntaxes.

## Install

Using Vundle:


    Plugin 'vimwiki/vimwiki'
    Plugin 'junegunn/fzf.vim'
    Plugin 'michal-h21/vim-zettel'

## Configuration

Sample configuration:

    " Filename format. The filename is created using strftime() function
    let g:zettel_format = "%y%m%d-%H%M"
    " Disable default keymappings
    let g:zettel_default_mappings = 0 
    " This is basically the same as the default configuration
    imap <silent> [[ [[<esc><Plug>ZettelSearchMap
    nmap T <Plug>ZettelYankNameMap
    xmap z <Plug>ZettelNewSelectedMap

    " Settings for Vimwiki
    let g:vimwiki_list = [{'path':'~/scratchbox/vimwiki/markdown/','ext':'.md','syntax':'markdown', 'zettel_template': "~/mytemplate.tpl"}, {"path":"~/scratchbox/vimwiki/wiki/"}]
    " Set template and custom header variable for the second Wiki
    let g:zettel_options = [{},{"front_matter" : {"tags" : ""}, "template" :  "~/mytemplate.tpl"}]


## Usage

It adds some commands and mappings on top of
[Vimwiki](http://vimwiki.github.io/). See it's documentation on how to set up a
basic wiki and navigate it.

### Create new Zetteln

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

- `T` command in the nomal mode - yank the current note filename and title as a Vimwiki link

- `:ZettelCapture` - create a new Zettel from a file. Usaful for scripting. It can be used in this way

  ```
  vim -c ZettelCapture filename
  ```

  It will replace the original file contents with a path to the new wiki file,
  so it should be used with temporary files!

## Related

The following packages may be useful in conjuction with Vimwiki and Vim-zettel:

- [Notational FZF](https://github.com/alok/notational-fzf-vim) - fast searching notes with preview window.
- [Vimwiki-sync](https://github.com/michal-h21/vimwiki-sync) - automatically commit changes in wiki and synchronize them with external Git repository.
