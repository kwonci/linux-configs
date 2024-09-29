.PHONY: example
example: # install example package on target directory(home)
	# if a directory in package already exists in target directory, it skips
	# If a directory in package does not exist in target directory, it creates a symlink
	# if a file in package already exists, it will crash
	# if a file in package does not exist, it creates a symlink
	stow -t ~ example

.PHONY: example-adopt
example-adopt:  # copy existing package to dotfiles, then create symlink
	stow --adopt -t ~ example

.PHONY: nvim
nvim:
	stow -t ~/.config/nvim nvim

.PHONY: zsh
zsh:
	stow -t ~ zsh

.PHONY: tmux
tmux:
	stow -t ~ tmux
	# then install tmux plugins(links: https://github.com/tmux-plugins/tpm)
	# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	# tmux source ~/.tmux.conf
	# # then press `prefix + I` to install plugins

.PHONY: config
config:
	@stow -t ~ config
