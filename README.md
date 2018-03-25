# The `vim-zettel` package

This is a Vim plugin that implements ideas of the
[Zettelkasten](https://zettelkasten.de/) method using Vimwiki. This is a work
in progress and it has just a basic features ATM.

## Install

Using Vundle:


    Plugin 'vimwiki/vimwiki'
    Plugin 'junegunn/fzf.vim'
    Plugin 'michal-h21/vim-zettel'

## Usage

It add some commands and mappings on top of
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


