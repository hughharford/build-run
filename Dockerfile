# NOTE:
#   THIS DOCKERFILE IS(WAS) GENERATED VIA "update.sh"
#		 ORIGINALLY MS VSCODE dockerfile for dev in container work
####
#### HSTH NOTES:
  #
  # 24 10 09:   Builds fine all the way

  # SSH NOTES
  # # see in git_config_SSH_working_POSCO_and_YETI.txt

FROM ubuntu:24.04

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

# always:
RUN apt-get update

# extra dependencies
# (over what base already includes, was buildpack-deps, now ubuntu:20.04)
RUN apt-get update && apt-get install -y --no-install-recommends \
	apt-utils \
	libbluetooth-dev \
	tk-dev \
	uuid-dev \
	&& rm -rf /var/lib/apt/lists/*

# HSTH standard issue:
RUN apt-get update && apt-get install -y apt-transport-https

RUN apt-get install -y \
	unzip \
	curl \
	wget \
	python3-pip

# # make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

############# PYTHON VERSIONS #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################

############# Then, PYTHON was 3.8.0 now 3.10.1 #########################################################
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

# ''''''''''''''' ############################# '''''''''''''''''' ####################
############# PYTHON VERSIONS #########################################################
# ''''''''''''''' ############################# '''''''''''''''''' ####################

# if this is called "PIP_VERSION", pip explodes with
#           "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 24.0.4
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 57.0.0
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/3cb8888cc2869620f57d5d2da64da38f516078c7/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 c518250e91a70d7b20cceb15272209a4ded2a0c263ae5776f129e0d9b5674309

RUN apt-get install -y libncursesw5-dev \
  libssl-dev \
  tk-dev \
  libgdbm-dev \
  libc6-dev \
  libbz2-dev \
  libsqlite3-dev
  # this FAILS
# RUN apt-get install -y libreadline-gplv2-dev

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

# RUN pip3 install poetry __ this FAILS
RUN apt install python3-poetry -y

RUN poetry new docker_env
WORKDIR /docker_env
COPY /docs/build_run_requirements.txt requirements.txt

RUN poetry add $(cat requirements.txt)



# ###################################
#		Anaconda Conda
#		and
#		Anaconda Navigator
##
##
# _________________ don't need Anaconda...?? LWB
##
##
# ###################################

# HSTH install Anaconda and Navigator
# prerequisites: REF: https://docs.anaconda.com/anaconda/install/linux/
#
# RUN apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6

# DOWNLOAD from:
# https://www.anaconda.com/products/distribution#linux
#
# RUN bash ~/Downloads/Anaconda3-2020.02-Linux-x86_64.sh


# example command to run CMD ["/usr/bin/firefox"]
CMD ["/bin/bash"]
