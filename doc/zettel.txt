*vim-zettel.txt*    A Zettelkasten VimWiki Addon Last change: 2020 Mar 14

  _____    _   _       _ _             _
 |__  /___| |_| |_ ___| | | _____  ___| |_ ___ _ __
   / // _ \ __| __/ _ \ | |/ / _ \/ __| __/ _ \ '_ \
 / /|  __/ |_| ||  __/ |   < (_| \__ \ ||  __/ | | |
/____\___|\__|\__\___|_|_|\_\__,_|___/\__\___|_| |_|


==============================================================================
CONTENTS                                                           *vim-zettel*

0. Intro                                     |Vim-Zettel-Intro|
1. Installation                              |Vim-Zettel-Install|
2. Configuration                             |Vim-Zettel-Configure|
3. Commands                                  |Vim-Zettel-Commands|
   `ZettelNew`                                |Vim-Zettel_ZettelNew|
   `ZettelOpen`                               |Vim-Zettel_ZettelOpen|
   `ZettelInsertNote`                         |Vim-Zettel_ZettelInsertNote|
   `ZettelCapture`                            |Vim-Zettel_ZettelCapture|
   `ZettelBackLinks`                          |Vim-Zettel_ZettelBackLinks|
   `ZettelInbox`                              |Vim-Zettel_ZettelInbox|
   `ZettelGenerateLinks`                      |Vim-Zettel_ZettelGenerateLinks|
   `ZettelGenerateTags`                       |Vim-Zettel_ZettelGenerateTags|
   `ZettelSearch`                             |Vim-Zettel_ZettelSearch|
   `ZettelYankName`                           |Vim-Zettel_ZettelYankName|
4. Mappings                                  |Vim-Zettel-Mappings|
   `z`                                        |Vim-Zettel_z|
   `[[`                                       |Vim-Zettel_[[|
   `T`                                        |Vim-Zettel_T|
   `gZ`                                       |Vim-Zettel_gZ|
5. Variables                                 |Vim-Zettel-Variables|
6. Templates                                 |Vim-Zettel-Templates|
7. Related Packages                          |Vim-Zettel-Related|
8. ChangeLog                                 |Vim-Zettel-ChangeLog|

==============================================================================
0. Intro                                                     *Vim-Zettel-Intro*

This is a Vim plugin that implements ideas of the zettelkasten method of
note taking as described at https://zettelkasten.de/.  It is an add-on to
the Vimwiki extension for Vim and supports both Vimwiki and Markdown syntaxes.

==============================================================================
1. Installation                                           *Vim-Zettel-Install*

This extension requires an external search utility.  It uses The Silver
Searcher by default.
(Available at https://github.com/ggreer/the_silver_searcher/ or in your OS
repositories).

Using Vundle: >

   Plugin 'vimwiki/vimwiki'
   Plugin 'junegunn/fzf'
   Plugin 'junegunn/fzf.vim'
   Plugin 'michal-h21/vim-zettel'
<
==============================================================================
2. Configuration                                        *Vim-Zettel-Configure*

First of all, it is necessary to configure Vimwiki, as Vim-Zettel builds
on top of it.  Vim-Zettel can be used out of the box without further
configuration if you have only one wiki.  However, you will probably want to
customize your Vim-Zettel configuration and will have to if you have more than
one wiki. >

   " Settings for Vimwiki
   let g:vimwiki_list = \
     [{'path':'~/scratchbox/vimwiki/markdown/','ext':'.md',\
     'syntax':'markdown'}, {"path":"~/scratchbox/vimwiki/wiki/"}]

You may want to set some of the following options in your .vimrc file to make
Vim-Zettel work to your liking:

- |g:zettel_options|
- |g:zettel_format|
- |g:zettel_default_mappings|
- |g:zettel_fzf_command|
- |g:zettel_fzf_options|
- |g:zettel_backlinks_title|

You can also supply a custom template for creating new zettels. See
|Vim-Zettel-Templates|.

==============================================================================
3. Commands                                              *Vim-Zettel-Commands*

Vim-Zettel implements the following commands on top of Vimwiki.

                                                       *Vim-Zettel_ZettelNew*
                                                                  *ZettelNew*
- `:ZettelNew` command – it will create a new wiki file named as
 %y%m%d-%H%M.wiki (it is possible to change the file name format using
 |g:zettel_format| variable). The file uses basic template in the form >

   %title Note title
   %date current date

where title is the first parameter to `:ZettelNew`.

If you use the default mappings provided by `Vim-Zettel`, it is possible to
call this command by pressing the `z` character in visual mode. The selected
text will be used as title of the new note.

                                                       *Vim-Zettel_ZettelOpen*
                                                                  *ZettelOpen*
- `:ZettelOpen` command - perform fulltext search using FZF. It keeps the
  history of opened pages.

                                                 *Vim-Zettel_ZettelInsertNote*
                                                            *ZettelInsertNote*
- `:ZettelInsertNote` - select notes using FZF and insert them in the current
  document.  Multiple notes can be selected using the `<TAB>` key.  They are
  automatically converted to the document syntax format using Pandoc.

                                                   *Vim-Zettel_ZettelCapture*
                                                              *ZettelCapture*
- `:ZettelCapture` command – turn the content of the current file into a
   zettel.  This is a global command available throughout Vim. WARNING:
   this command is destructive. Use only on temporary files.  You can run
   this from within vim while viewing a file you want to turn into a zettel
   or from the command line: >

       vim -c ZettelCapture filename
<
    you can specify wiki numbner (starting from 0) if you have multiple
    wikis. It opens first declared wiki by default:

>
      vim -c "ZettelCapture 1" filename
<
                                                 *Vim-Zettel_ZettelBackLinks*
                                                            *ZettelBackLinks*
- `:ZettelBackLinks` command – insert list of notes that link to the current
   note.

                                                     *Vim-Zettel_ZettelInbox*
                                                                *ZettelInbox*
- `:ZettelInbox` command – insert list of notes that no other note links to.

                                             *Vim-Zettel_ZettelGenerateLinks*
                                                        *ZettelGenerateLinks*
- `:ZettelGenerateLinks` command – insert list of all wiki pages in the
   current page. It needs updated tags database. The tags database can be
   updated  using the `:VimwikiRebuildTags!` command.

                                              *Vim-Zettel_ZettelGenerateTags*
                                                         *ZettelGenerateTags*
- `:ZettelGenerateTags` command – insert list of tags and pages that used
   these tags in the current page. It needs updated tags database. The tags
   database can be updated  using the `:VimwikiRebuildTags!` command. It only
   supports the Vimwiki style tags in the form :tag1:tag2. These work
   even in the Markdown mode.

                                                   *Vim-Zettel_ZettelSearch*
                                                              *ZettelSearch*
- `:ZettelSearch` command – search the content of your zettelkasten and
   insert a link to the selected zettel in your current note.  Mapped to
   `[[` in insert mode.

                                                 *Vim-Zettel_ZettelYankName*
                                                            *ZettelYankName*
- `:ZettelYankName` – copy the current zettel file name and title to the
  unnamed register as a formatted link.  Mapped to `T` in normal mode.

Useful Vimwiki commands ~

- |:VimwikiBacklinks| - display files that link to the current page
- |:VimwikiCheckLinks|- display files that no other file links to

==============================================================================
4. Mappings                                               *Vim-Zettel-Mappings*

                                                               *Vim-Zettel_z*
- `z` command in visual mode – create a new wiki file using selected text for
   the note title

                                                              *Vim-Zettel_[[*
- [[ command in insert mode – create a link to a note. It uses FZF for the
   note searching.

                                                               *Vim-Zettel_T*
- T command in normal mode – yank the current note filename and title as a
   Vimwiki link

                                                              *Vim-Zettel_gZ*
- gZ command in normal mode – replace file path under cursor with Wiki link

It may be convenient to map `ZettelNew` to prompt for a note title also: >

   nnoremap <leader>zn :ZettelNew<space>
<
==============================================================================
5. Variables                                             *Vim-Zettel-Variables*

                                                           *g:zettel_options*
The g:zettel_options variable corresponds to the g:vimwiki_list variable.  If
you have more than one vimwiki and the second wiki listed in your
g:vimwiki_list variable is your zettelkasten, then you must represent the
first wiki in your g:zettel_options list as a set of empty braces: >

                   first wiki     zettelkasten wiki
                            ↓     ↓
   let g:zettel_options = [{}, {"front_matter" : {"tags" : ""}, "template" :  "~/mytemplate.tpl"}]
<
                                                            *g:zettel_format*
By default, Vim-Zettel creates filenames in the form YYMMDD-HHMM. This
format can be changed using the g:zettel_format variable. Any date and time
formats supported by the `strftime()` function.

It is also possible to use other formatting strings:

- %title -- insert sanitized title
- %raw_title -- insert raw title
- %file_no -- sequentially number files in wiki
- %file_alpha -- sequentially number files in wiki, but use characters
   instead of numbers

To use filename based on current time and note title, you can use the
following format: >

   let g:zettel_format = "%y%m%d-%H%M-%title"

For sequentialy named files use: >

   let g:zettel_format = "%file_no"
<
If the generated file name exists (this may happen when you use the default
format - `%y%m%d-%H-M`, letter suffix is added to the filename. You will then
get `200622-1114` and `200622-1114a` when you create two notes in one minute.

                                                     *g:zettel_default_title*
Text used for `%title` formatting string in new Zettel filename if title was
not provided.

                                                     *g:zettel_date_format*
Date format used for date metadata in front matter for new zettel. It will
need to be supported by the `strftime()` function.

For example:

    let g:zettel_date_format = "%y/%m/%d"

                                                  *g:zettel_default_mappings*
The default mappings used by Vim-Zettel can be changed by setting the
g:zettel_default_mappings variable to 0 and then prividing your own keymaps.
The code below can serve as a template to start from. >

   let g:zettel_default_mappings = 0
   " This is basically the same as the default configuration
   augroup filetype_vimwiki
     autocmd!
     autocmd FileType vimwiki imap <silent> [[ [[<esc><Plug>ZettelSearchMap
     autocmd FileType vimwiki nmap T <Plug>ZettelYankNameMap
     autocmd FileType vimwiki xmap z <Plug>ZettelNewSelectedMap
     autocmd FileType vimwiki nmap gZ <Plug>ZettelReplaceFileWithLink
   augroup END
<

                                                       *g:zettel_fzf_command*
Vim-Zettel uses The Silver Searcher (ag) by default when searching through
your files.  The g:zettel_fzf_command can be used to override the default
setting. >

   " command used for VimwikiSearch
   " default value is "ag". To use other command, like ripgrep, pass the
   " command line and options:
   let g:zettel_fzf_command = "rg --column --line-number --ignore-case \
     --no-heading --color=always "

<

                                                       *g:zettel_fzf_options*
Options used for the `fzf` command.

>
   let g:zettel_fzf_options = ['--exact', '--tiebreak=end']
<

                                                    *g:zettel_backlinks_title*
Text used as back links section.

>
   let g:zettel_backlinks_title = "Backlinks"
<


==============================================================================
6. Templates                                             *Vim-Zettel-Templates*

It is possible to populate new notes with basic structure using templates.
Template can be declared using the g:zettel_options variable: >

   let g:zettel_options = [{"template" :  "~/path/to/mytemplate.tpl"}]

Sample template: >

   = %title =

   Backlink: %backlink
   ----
   %footer

Variables that start with the % will be expanded. Supported variables:

- %title - title of the new note
- %backlink - back link to the parent note
- %footer - text from the parent note footer. Footer is separated from  the
 main text by horizontal rule  (----). It can contain some information
 shared by notes. For example notes about publication can share citation of
 that publication.

==============================================================================
7. Related packages                                        *Vim-Zettel-Related*

The following packages may be useful in conjunction with Vimwiki and
Vim-Zettel:

- [Notational FZF](https://github.com/alok/notational-fzf-vim) - fast
   searching notes with preview window.

   To search in the Zettelkasten, set the following variable with path to the
   Zettelkaster direcory in .vimrc: >

       let g:nv_search_paths = ['/path/to/zettelkasten/dir']

- [Vimwiki-sync](https://github.com/michal-h21/vimwiki-sync) - automatically
commit changes in wiki and synchronize them with external Git repository.


==============================================================================
8.  Changelog                                            *Vim-Zettel-ChangeLog*

2020-06-29  Michal Hoftich <michal.h21@gmail.com>

* autoload/zettel/vimwiki.vim: remove some punctuation from filenames in
  `zettel#vimwiki#escape_filename`.
* autoload/zettel/vimwiki.vim: save file before it is read by
  `prepare_template_variables`
  https://github.com/michal-h21/vim-zettel/issues/43
     
2020-06-27  Irfan Sharif

* autoload/zettel/vimwiki.vim: added `g:zettel_date_format` variable.

2020-06-26  Michal Hoftich <michal.h21@gmail.com>

* ftplugin/vimwiki.vim: detect correct register for `:ZettelYankName`.
* autoload/zettel/vimwiki.vim: detect imported file title in
  `capture()`.
* autoload/zettel/vimwiki.vim: use default title in `new_zettel_name()`

2020-06-25  Michal Hoftich <michal.h21@gmail.com>

* autoload/zettel/vimwiki.vim: add letter to filename if `:ZettelNew` is used
  multiple times in one minute.

2020-06-24  Michal Hoftich <michal.h21@gmail.com>

* autoload/zettel/vimwiki.vim: the back links title is configurable
* autoload/zettel/vimwiki.vim: template is now available also in the
  `:ZettelNew` command.
* ftplugin/vimwiki.vim: removed unused variable `g:zettel_filename_title`.
* doc/zettel.txt: added ChangeLog and documented few variables.


vim:tw=78:ts=8:ft=help
