
# Reinstalling same packages
### https://help.ubuntu.com/community/ReinstallingSamePackages

## https://phoenixnap.com/kb/ubuntu-list-installed-packages
### NOTE
The explanations of what [installed], [installed, automatic] and [installed, local] mean.

### 3 x commands to list and save packages:

dpkg --get-selections > path/to/files/packages/dpkg-packages.txt


apt list --installed | grep -v '^\s' > path/to/files/packages/apt-installed-packages.txt


apt list --installed | grep "\\[installed\\]" > path/to/files/apt-installed-user-packages.txt
