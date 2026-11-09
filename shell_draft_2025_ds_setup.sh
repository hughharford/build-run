# # following data-setup from the awesome le wagon, and a few extras, noted under # included:
# # does exclude some steps, like Chrome, VS Code liveshare etc

# # #  2025 03 18
# # Notes
# #  not bad, but got pretty tricky around
# #     1. GPG keys being out of date (obvious when you realise)
# #     2. some basics around .zshrc additions
# #     3. Docker installation as recommended by Le Wagon just not actually installing. Manual sudo apt install in the end.


# # adjustments here:
export PYTHON_VERSION=3.12.0

# # NOTE:
# # lines with  # TROUBLE:

# # # vs code
# # either just use ubuntu snap, or:
# # # https://code.visualstudio.com/docs/setup/linux
# sudo apt-get install wget gpg
# wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
# sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
# echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
# rm -f packages.microsoft.gpg


# chrome
# just use ubuntu snapwget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install google-chrome-stable

# OR JUST
# chrome
# sudo apt-get install libxss1 libappindicator1 libindicator7
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# sudo apt install -f ./google-chrome*.deb


# # # vs code extensions
code --install-extension ms-vscode.sublime-keybindings
code --install-extension emmanuelbeziat.vscode-great-icons
code --install-extension MS-vsliveshare.vsliveshare
code --install-extension ms-python.python
code --install-extension KevinRose.vsc-python-indent
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter

# # # zsh & git
sudo apt remove -y gitsome # gh command can conflict with gitsome if already installed

# # TROUBLE: make sure GPG key is up to date:
# ## REF # https://github.com/lewagon/data-engineering-setup/blob/main/LINUX.md
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
# # # check ok with 'gh --version'
gh --version

# # # direnv and zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt-get update; sudo apt-get install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# # # github CLI login, with SSH code setup
gh auth login -s 'user:email' -w
# # # check ok with 'gh auth status'


# # # include:
# # # to get git to default to SSH not HTTPS
git config --global url.ssh://git@github.com/.insteadOf https://github.com/


# # # dotfiles setup:
export GITHUB_USERNAME=`gh api user | jq -r '.login'`
echo $GITHUB_USERNAME

mkdir -p ~/code/$GITHUB_USERNAME && cd $_
gh repo fork lewagon/dotfiles --clone

cd ~/code/$GITHUB_USERNAME/dotfiles && zsh install.sh

gh api user/emails | jq -r '.[].email'
cd ~/code/$GITHUB_USERNAME/dotfiles && zsh git_setup.sh

# # disable SSH prompt
# # THIS GETS TAKEN CARE O AUTOMATICALLY
# code ~/.zshrc

# # MANUAL STEP, but was already there... 24 07 09
# # Then:

# #     Spot the line starting with plugins=
# #     Add ssh-agent at the end of the plugins list

# # ✔️ Save the .zshrc file with Ctrl + S and close your text editor.

# # pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
exec zsh
sudo apt-get update; sudo apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev python3-dev

# # python install
# # TROUBLE - just to skip if already done.
# # only trouble was selected an available version
pyenv install $PYTHON_VERSION
exec zsh

pyenv global $PYTHON_VERSION

# # # install virtualenv and a few others
sudo apt-get update && sudo apt-get install -y apt-transport-https
sudo apt-get install -y \
	unzip \
	curl \
	wget \
	virtualenv \
	python3-pip

git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
exec zsh

# set virtual environment(s)
pyenv virtualenv $PYTHON_VERSION initial_env
pyenv global initial_env

# pip
pip install --upgrade pip

# list of le wagon packages:
pip install -r https://raw.githubusercontent.com/lewagon/data-setup/master/specs/releases/linux.txt

# juypter extensions
# install nbextensions
jupyter contrib nbextension install --user
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main
jupyter nbextension enable spellchecker/main
jupyter nbextension enable code_prettify/code_prettify

# custom css look
# # cd $(jupyter --config-dir)
# # mkdir -p custom
# # touch custom/custom.css
# # code custom/custom.css

# manual step, paste into cusom.css:
# # summary {
# #    cursor: pointer;
# #     display:list-item;
# # }
# # summary::marker {
# #     font-size: 1em;
# # }

# checks:
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/lewagon/data-setup/master/checks/python_checker.sh)" ${PYTHON_VERSION}
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/lewagon/data-setup/master/checks/pip_check.sh)"
python -c "$(curl -fsSL https://raw.githubusercontent.com/lewagon/data-setup/master/checks/pip_check.py)"



# slack
# sudo snap install slack

#debeaver
sudo snap install dbeaver-ce

# # __________ docker and friends
# # TROUBLE:
# # THIS LOT BELOW FAILED, JUST ACTUALLY NOT INSTALLED
# remove old packages first
#  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# # instead:
sudo apt update
sudo apt install docker.io docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo rm -rf ~/.docker/
