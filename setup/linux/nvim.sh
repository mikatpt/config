#!/usr/bin/bash

install_neovim() {
    yes | sudo add-apt-repository ppa:neovim-ppa/unstable
    yes | sudo apt-get update
    yes | sudo apt-get install neovim
}

setup_neovim() {
    nvim --headless +PackerInstall +qall
    nvim --headless +"LspInstall bash" +"LspInstall lua" +"LspInstall vim" +"LspInstall efm" +qall
}

configure_language_servers() {
    # Language formatters
    npm i -g eslint_d prettier

    # Go debugging
    mkdir -p ~/.debug
    cd ~/.debug
    git clone https://github.com/golang/vscode-go
    cd ~/.debug/vscode-go
    npm i
    npm run compile

    # JavaScript debugging
    cd ~/.debug
    git clone https://github.com/microsoft/vscode-node-debug2.git
    cd ~/.debug/vscode-node-debug2
    npm i
    npm run build
}

install_neovim
setup_neovim
configure_language_servers
