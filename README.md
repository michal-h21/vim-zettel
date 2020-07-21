# The `vim-zettel` package

This is a Vim plugin that implements ideas of the
[Zettelkasten](https://zettelkasten.de/) method using Vimwiki. 
It supports both Vimwiki and Markdown syntaxes.

You can read the full documentation using

    :help vim-zettel

command in Vim after package installation.

# Install

Using Vundle:


    Plugin 'vimwiki/vimwiki'
    Plugin 'junegunn/fzf'
    Plugin 'junegunn/fzf.vim'
    Plugin 'michal-h21/vim-zettel'
    
[Silver Searcher](https://github.com/ggreer/the_silver_searcher) is used for searching in the notes by default. 
The used command can be changed by setting the `g:zettel_fzf_command` variable.


# Usage

`Vim-zettel` adds some commands and mappings on top of
[Vimwiki](http://vimwiki.github.io/). See Vimwiki documentation on how to set up a
basic wiki and navigate it.


# Related packages

The following packages may be useful in conjunction with Vimwiki and Vim-zettel:

- [Notational FZF](https://github.com/alok/notational-fzf-vim) - fast searching
  notes with preview window. Similar functionality is now built in in
  `Vim-Zettel` using `:ZettelOpen` command.

To search in the Zettelkasten, set the following variable with path to the Zettelkasten direcory in `.vimrc`:

    let g:nv_search_paths = ['/path/to/zettelkasten/dir']

- [Vimwiki-sync](https://github.com/michal-h21/vimwiki-sync) - automatically commit changes in wiki and synchronize them with external Git repository.
