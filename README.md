# The `vim-zettel` package

This is a Vim plugin that implements ideas of the
[Zettelkasten](https://zettelkasten.de/) method using Vimwiki. 
It supports both Vimwiki and Markdown syntaxes.

Main features:

- customizable filenames (date and time, title, consecutive numbering)
- links always show titles, regardless of the actual filename
- fulltext support using FZF for searching and hyperlinking
- search your Zettelkasten from LaTeX or Markdown documents and insert selected notes to the document
- template support 
- automatically updated tag index
- backlinks

You can read the full documentation using

    :help vim-zettel

command in Vim after package installation.

# Install

## Using Vundle:


    Plugin 'vimwiki/vimwiki'
    Plugin 'junegunn/fzf'
    Plugin 'junegunn/fzf.vim'
    Plugin 'michal-h21/vim-zettel'
    

## Using [vim-plug](https://github.com/junegunn/vim-plug)

    call plug#begin()
    Plug 'vimwiki/vimwiki'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'michal-h21/vim-zettel'
    call plug#end()

[Silver Searcher](https://github.com/ggreer/the_silver_searcher) is used for searching in the notes by default. 
The used command can be changed by setting the `g:zettel_fzf_command` variable.

# Usage

`Vim-zettel` adds some commands and mappings on top of
[Vimwiki](http://vimwiki.github.io/). See Vimwiki documentation on how to set up a
basic wiki and navigate it.

# Known issues

- [ZettelOpen and ZettelSearch fail because of an "Error running fzf..."](https://github.com/michal-h21/vim-zettel/issues/58). 
  This issue is probably caused by too old version of
  [FZF](https://github.com/junegunn/fzf) on your machine. Try to update both
  `fzf` binary and `fzf.vim`.

# Related packages

The following packages may be useful in conjunction with Vimwiki and Vim-zettel:

- [Notational FZF](https://github.com/alok/notational-fzf-vim) - fast searching
  notes with preview window. Similar functionality is now built in in
  `Vim-Zettel` using `:ZettelOpen` command.

To search in the Zettelkasten, set the following variable with path to the Zettelkasten direcory in `.vimrc`:

    let g:nv_search_paths = ['/path/to/zettelkasten/dir']

- [Vimwiki-sync](https://github.com/michal-h21/vimwiki-sync) - automatically commit changes in wiki and synchronize them with external Git repository.
