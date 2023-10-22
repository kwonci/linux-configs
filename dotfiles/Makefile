.PHONY: example
example: # install example package on target directory(home)
	stow -t ~ example

.PHONY: example-adopt
example-adopt:  # copy existing package to dotfiles, then create symlink
	stow --adopt -t ~ example

.PHONY: nvim
nvim:
	stow -t ~/.config/nvim nvim
