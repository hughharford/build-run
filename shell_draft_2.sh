# following data-setup from the awesome le wagon, and a few extras, noted under # included:
# does exclude some steps, like Chrome, VS Code liveshare etc

PYTHON_VERSION=3.12.6

# vs code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# vs code extensions
code --install-extension ms-vscode.sublime-keybindings
code --install-extension emmanuelbeziat.vscode-great-icons
code --install-extension MS-vsliveshare.vsliveshare
code --install-extension ms-python.python
code --install-extension KevinRose.vsc-python-indent
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter

# zsh & git
sudo apt remove -y gitsome # gh command can conflict with gitsome if already installed
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
# check ok with 'gh --version'

# direnv and zsh 
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt-get update; sudo apt-get install direnv                           
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# github CLI login, with SSH code setup
gh auth login -s 'user:email' -w  
# check ok with 'gh auth status'

# include:
# to get git to default to SSH not HTTPS
git config --global url.ssh://git@github.com/.insteadOf https://github.com/


# dotfiles setup:
export GITHUB_USERNAME=`gh api user | jq -r '.login'`
echo $GITHUB_USERNAME

mkdir -p ~/code/$GITHUB_USERNAME && cd $_
gh repo fork lewagon/dotfiles --clone

cd ~/code/$GITHUB_USERNAME/dotfiles && zsh install.sh

gh api user/emails | jq -r '.[].email'
cd ~/code/$GITHUB_USERNAME/dotfiles && zsh git_setup.sh

# disable SSH prompt
code ~/.zshrc

# MANUAL STEP, but was already there... 24 07 09
# Then:

#     Spot the line starting with plugins=
#     Add ssh-agent at the end of the plugins list

# ✔️ Save the .zshrc file with Ctrl + S and close your text editor.

# pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
# add pyenv to path etc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.zshrc
exec zsh

# pyenv python dependencies
sudo apt-get update; sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
python3-dev

# python install
pyenv install {PYTHON_VERSION}
exec zsh

# install virtualenv and a few others
sudo apt-get update && sudo apt-get install -y apt-transport-https
sudo apt-get install -y \
	unzip \
	curl \
	wget \
	virtualenv \
	python3-pip

# set virtual environment(s)
pyenv virtualenv PYTHON_VERSION initial_env
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
cd $(jupyter --config-dir)
mkdir -p custom
touch custom/custom.css
code custom/custom.css

# manual step, paste into cusom.css:
summary {
    cursor: pointer;
    display:list-item;
}
summary::marker {
    font-size: 1em;
}

# checks:
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/lewagon/data-setup/master/checks/python_checker.sh)" 3.10.6
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/lewagon/data-setup/master/checks/pip_check.sh)"
python -c "$(curl -fsSL https://raw.githubusercontent.com/lewagon/data-setup/master/checks/pip_check.py)"

# install docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install latest Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# check with:
sudo docker run hello-world

# allow non-priviledged users (not always recommended)
sudo groupadd docker 
sudo usermod -aG docker $USER
newgrp docker  # gets groups re-initialised and working

