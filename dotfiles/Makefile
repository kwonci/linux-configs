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

.PHONY: polybar
polybar: polybar-deps
	@stow -t ~ polybar

.PHONY: polybar-deps
polybar-deps:
	# xrandr
	yay -S xorg-xrandr
	# bluetoothctl
	yay -S bluez-utils

.PHONY: git
git:
	stow -t ~ git

.PHONY: vim
vim:
	stow -t ~ vim

.PHONY: asdf
asdf:
	stow -t ~ asdf

# Download secrets from 1password
.PHONY: secrets-download
secrets-download:
	op document get awsconfig \
		--vault AIRSMedical > ~/.aws/config
	op document get awscredentials \
		--vault AIRSMedical > ~/.aws/credentials
	op document get kubeconfig \
		--vault AIRSMedical > ~/.kube/config
	op document get env.zsh \
		--vault Personal > ~/.oh-my-zsh/custom/env.zsh

.PHONY: secrets-write
secrets-write:
	op document edit awsconfig ~/.aws/config --vault AIRSMedical
	op document edit awscredentials ~/.aws/credentials --vault AIRSMedical
	op document edit kubeconfig ~/.kube/config --vault AIRSMedical
	op document edit env.zsh ~/.oh-my-zsh/custom/env.zsh --vault Personal

.PHONY: secrets-upload
secrets-upload:
	op document create ~/.aws/config \
		--vault AIRSMedical \
		--title "awsconfig"
	op document create ~/.aws/credentials \
		--vault AIRSMedical \
		--title "awscredentials"
	op document create ~/.kube/config \
		--vault AIRSMedical \
		--title "kubeconfig"
	op document create ~/.oh-my-zsh/custom/env.zsh \
		--vault Personal
