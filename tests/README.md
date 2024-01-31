This folder contains the tests for the vim-zettel plugin.

# How to run the tests
The tests run with a dedicated vimrc (`./test_vimrc`), which specifies minimal settings and configures vimwiki and vim-zettel to use the wikis under `./resources/`.

## Prerequisites
- Install `vader`, `vimwiki`, `vim-zettel`
- Create a file named `rtp.vim` under `tests/`
- In `tests/rtp.vim`, add the plugins installation path to the `rtp`: (adjust the paths as needed)
```vim
set rtp+=~/.vim/pack/test-tools/start/vader.vim
set rtp+=~/.vim/pack/zettel-plugins/start/vimwiki
set rtp+=~/.vim/pack/zettel-plugins/start/vim-zettel
```

## Run the tests
To run all tests, change your working directory to `tests/` and issue the command:
```bash
vim -u test_vimrc -i NONE -c "Vader *"
```
This starts vim:
- with `test_vimrc` as `.vimrc` (`-u test_vimrc`)
- with no `.viminfo` file (`-i NONE`)
- and issues the Ex command `:Vader *` (`-c "Vader *"`), which will execute all `*.vader` files

### CAUTION :warning:
If you want to run the tests from vim with `:Vader *`, make sure to start vim with the `./test_vimrc` (`vim -u ./test_vimrc`).
Otherwise the tests (potentially destructive) will run on your wiki list.

