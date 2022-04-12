#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#		 ORIGINALLY MS VSCODE dockerfile for dev in container work
# PLEASE DO NOT EDIT IT DIRECTLY.

# NOTES ##  ##  ## see likely useful ref: 		
#										https://github.com/fcwu/docker-ubuntu-vnc-desktop
#

FROM ubuntu:20.04

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# set TERM
ENV TERM=xterm-256color

# set location to avoid hang on tzdata
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# HSTH: ALWAYS RUN THIS FIRST:
RUN apt-get update

# extra dependencies (over what base already includes, was buildpack-deps, now ubuntu:20.04)
# added HSTH: apt-utils
RUN apt-get update && apt-get install -y --no-install-recommends \
	apt-utils \		
	libbluetooth-dev \
	tk-dev \
	uuid-dev \					
	&& rm -rf /var/lib/apt/lists/*

# HSTH: THEN INSTALL BASICS
# standard issue update && ...
RUN apt-get update && apt-get install -y apt-transport-https

# HSTH: STEPS to install a few extras
RUN apt-get install -y \
	unzip \
	curl \
	wget \
	virtualenv \
	python3-pip

######   
###### 
#		INSTALL NOTES  
######   
######   
#
# ALREADY INSTALLED WITH UBUNTU_20.04
#			Document viewer - for pdf 
#			SNAP
#			GIT	(fullname, Bird date punkt)
#				NOT ALWAYS
#
# NOT INCLUDED WITH UBUNTU_20.04
#
# so install manually once set up, or?
#
# 		Mouse Utilities
#			RUN add-apt-repository ppa:atareao/atareao
#			RUN apt update
#			RUN apt install -y touchpad-indicator

#		Spotify (old e, renewed lyric)
#			RUN snap install spotify
# 		VLC
#			RUN apt-get install vlc
#			 --or:	sudo snap install vlc
#		GIMP
#			RUN sudo apt install gimp
#		Office365WebDesktop for linux (posco e, lyric and and)
#			RUN snap install unofficial-webapp-office
#		Slack (posco e, )
#			RUN snap install slack --classic
#		VS Code
#			#### 	https://linuxize.com/post/how-to-install-visual-studio-code-on-ubuntu-18-04/
#			sudo apt install gnupg2 software-properties-common apt-transport-https wget
#			wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
#			sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
#			sudo apt update
#			sudo apt install code
#		Docker (hughharford			Bird date)
#			RUN apt-get install -y docker.io docker-compose
#				sudo snap install docker          # version 20.10.11, or
#				sudo apt  install docker-compose  # version 1.25.0-1
#
#
#		System profiler (hardinfo)
#			RUN sudo apt install hardinfo
#
#		VNC Viewer
#			RUN apt-get install vncviewer (DOESN'T WORK...)
#				So far have to download and manually install, via the .deb and then use software install
#				REF: 
#					https://www.realvnc.com/en/connect/download/vnc/linux/
#
# Further useful:
#
#  FROM get-pip.py (see below and: https://github.com/pypa/get-pip)
#		wheel
#		setuptools
#		pip
#
#	NOTE how more complex get-pip.py with specific versions is sidestepped below


# SSH NOTES
#
# see in git_config_SSH_working_POSCO_and_YETI.txt


# was: RUN apt-get install docker.io -y
RUN apt-get install -y docker.io docker-compose
# LOGIN TO DOCKER: 			hughharford			Bird date


#### LE WAGON INSTALLS ##### start #
# REF                                https://gto76.github.io/python-cheatsheet/
### TODO: Convert to requirements.txt

RUN pip3 install pygame \
	&& pip3 install PySimpleGUI \
	# FROM 					REF/#logging
	&& pip3 install loguru \ 
	# for logging
	&& pip3 install requests beautifulsoup4 \
	# for web-scraping
	&& pip3 install bottle \
	# for web
	&& pip3 install line_profiler memory_profiler \
	# for profiling by line
	&& pip3 install pycallgraph2 \
	# for a PNG image of the call graph with highlighted bottlenecks (see example)
	&& pip3 install pillow \
	# for image
	&& pip3 install pyttsx3 \
	# for text to speech recognition
	#													&& pip3 install simpleaudio \
	# for synthesizer
	&& pip3 install plotly kaleido \
	# for plotly
	&& pip3 install cython \
	# for the Library that compiles Python code into C.
	&& pip3 install tqdm \
	# progress bar
	&& pip3 install tabulate 
# can prints a CSV file as an ASCII table

### TODO: Convert to requirements.txt
#### LE WAGON INSTALLS ##### end #


# # make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# ENV GPG_KEY A035C8C19219BA821ECEA86B64E628F8D684696D
#### Not even sure what this is used for below?
#### Trying without...
#### Suspect this GPG key usage is a security measure, to avoid cyber threats. see 'gpg --batch verify python.tar.xz.asc python.tar.xz'
#### See: https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages



############# PYTHON VERSIONS #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################
############# @@@@@@@@@@@@@@@ #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################
############# @@@@@@@@@@@@@@@ #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################



############# First, PYTHON 2.7 #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################

ENV PYTHON_VERSION 2.7

## got to be different for 2.7
## Leave for now...



############# Then, PYTHON 3.10.1 #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################

ENV PYTHON_VERSION 3.10.0

RUN set -ex \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	#	&& export GNUPGHOME="$(mktemp -d)" \
	#	&& gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY" \
	#	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	#	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	#	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
	--build="$gnuArch" \
	--enable-loadable-sqlite-extensions \
	--enable-optimizations \
	--enable-option-checking=fatal \
	--enable-shared \
	--with-lto \
	--with-system-expat \
	--with-system-ffi \
	--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
	\( \
	\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
	-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
	\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version

############# @@@@@@@@@@@@@@@ #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################
############# @@@@@@@@@@@@@@@ #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################
############# PYTHON VERSIONS #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 21.0.0
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 57.0.0
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/3cb8888cc2869620f57d5d2da64da38f516078c7/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 c518250e91a70d7b20cceb15272209a4ded2a0c263ae5776f129e0d9b5674309

# HSTH additional to deal with: WARNING: pip is configured with locations that require TLS/SSL, however the ssl module in Python is not available.
RUN apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

RUN set -ex; \
	\
	# wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	# echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	# \
	# python get-pip.py \
	# 	--disable-pip-version-check \
	# 	--no-cache-dir \
	# 	"pip==$PYTHON_PIP_VERSION" \
	# 	"setuptools==$PYTHON_SETUPTOOLS_VERSION" \
	curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
	python get-pip.py \
	pip --version; \
	\
	find /usr/local -depth \
	\( \
	\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
	-o \
	\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
	\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

# HSTH fulfill from requirements.txt
COPY /docs/build_run_requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# ###################################
#		Anaconda Conda
#		and
#		Anaconda Navigator
# ###################################

# HSTH install Anaconda and Navigator
# prerequisites: REF: https://docs.anaconda.com/anaconda/install/linux/
RUN apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6

# DOWNLOAD from:
# https://www.anaconda.com/products/distribution#linux
RUN bash ~/Downloads/Anaconda3-2020.02-Linux-x86_64.sh



# example command to run CMD ["/usr/bin/firefox"]
CMD ["/bin/bash"]
