FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

# Uncomment it if you are in China
RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive
# Add common tools available in apt repository. We choose not to support python2
RUN export HTTP_PROXY= HTTPS_PROXY= NO_PROXY= http_proxy= https_proxy= no_proxy= && \
    apt -o Acquire::http::proxy=false update && \
    apt -o Acquire::http::proxy=false install -y apt-utils software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt -o Acquire::http::proxy=false update && \
    apt -o Acquire::http::proxy=false install -y aria2 man telnet tmux locales pkg-config inetutils-ping net-tools git zsh thefuck mc sed ack-grep ranger htop silversearcher-ag python3 python3-dev build-essential autoconf automake libtool make gcc-12 g++-12 curl wget tar libevent-dev libncurses-dev clang-12 clang-format-12 clang-tidy-12 lld ccache nasm  unzip openjdk-8-jdk colordiff mlocate iftop libpulse-dev libv4l-dev python3-venv libcurl4-openssl-dev libopenblas-dev gdb texinfo libreadline-dev cmake valgrind tzdata zip libstdc++-12-dev tree && \
    apt clean

RUN locale-gen "en_US.UTF-8"

RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# Allow optional proxy build arguments for GitHub downloads.
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG http_proxy
ARG https_proxy
ARG no_proxy

ARG NINJA_VERSION=1.11.1
ARG NINJA_SHA256=b901ba96e486dce377f9a070ed4ef3f79deb45f4ffe2938f8e7ddc69cfb3df77

# Install Ninja from GitHub with proxy support and checksum verification.
RUN set -eux; \
    http_proxy_value="${http_proxy:-${HTTP_PROXY:-}}"; \
    https_proxy_value="${https_proxy:-${HTTPS_PROXY:-$http_proxy_value}}"; \
    no_proxy_value="${no_proxy:-${NO_PROXY:-}}"; \
    if [ -n "${http_proxy_value}${https_proxy_value}" ]; then \
        export http_proxy="$http_proxy_value" HTTP_PROXY="$http_proxy_value"; \
        export https_proxy="$https_proxy_value" HTTPS_PROXY="$https_proxy_value"; \
        export no_proxy="$no_proxy_value" NO_PROXY="$no_proxy_value"; \
    fi; \
    curl -fL --retry 5 --retry-connrefused --retry-max-time 60 \
      -o /tmp/ninja-linux.zip "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip"; \
    echo "${NINJA_SHA256}  /tmp/ninja-linux.zip" | sha256sum -c -; \
    unzip /tmp/ninja-linux.zip -d /usr/local/bin; \
    chmod +x /usr/local/bin/ninja; \
    rm -f /tmp/ninja-linux.zip

# RUN echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" >> /etc/apt/sources.list.d/clang.list
#
# RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - && apt -o Acquire::http::proxy=false update && apt install -y clang-format-8 clang-tidy-8 clang-tools-8 && cd /usr/bin && ln -s clangd-8 clangd && ln -s clang-tidy-8 clang-tidy && ln -s clang-tidy-diff-8.py clang-tidy-diff.py && ln -s clang-format-diff-8 clang-format-diff && ln -s clang-format-8 clang-format && apt clean

# RUN git config --global http.proxy xxx && git config --global https.proxy

RUN add-apt-repository ppa:neovim-ppa/stable -y && \
    apt -o Acquire::http::proxy=false update && \
    apt -o Acquire::http::proxy=false install -y neovim && \
    apt clean

# Install tmux
RUN ["/bin/bash", "-c", "TMUX_VERSION=3.0a &&       \
wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz &&    \
mkdir tmux-unzipped &&    \
tar xf tmux-${TMUX_VERSION}.tar.gz -C tmux-unzipped &&     \
rm -f tmux-${TMUX_VERSION}.tar.gz &&       \
pushd tmux-unzipped/tmux-${TMUX_VERSION} &&        \
./configure &&     \
make -j`nproc`&&        \
make install &&       \
popd &&        \
rm -rf tmux-unzipped"]
# -----------

RUN ["/bin/bash", "-c", "mkdir git-lfs && curl -L https://github.com/git-lfs/git-lfs/releases/download/v2.8.0/git-lfs-linux-amd64-v2.8.0.tar.gz | tar xzf - -C git-lfs && pushd git-lfs && ./install.sh && popd && rm -rf git-lfs"]

COPY apply-format /usr/bin/
COPY clangformat-git-hook /usr/bin/
COPY clangtidy-git-hook /usr/bin/
COPY install-clangformat-hook /usr/bin/
COPY install-clangtidy-hook /usr/bin/

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

# Set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "export LC_ALL=en_US.UTF-8" >> /etc/zsh/zshenv && echo "export LANG=en_US.UTF-8" >> /etc/zsh/zshenv

# change shell to zsh for user dev
RUN chsh -s `which zsh` root

USER root
WORKDIR /root/

# Install yarn
# Configure the Yarn repository
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install Yarn
RUN apt-get update && apt-get install -y yarn

# Install oh-my-zsh
RUN wget -O /tmp/ohmyzsh.tar.gz https://codeload.github.com/ohmyzsh/ohmyzsh/tar.gz/refs/heads/master && \
    mkdir -p /root/.oh-my-zsh && \
    tar -xzf /tmp/ohmyzsh.tar.gz -C /root/.oh-my-zsh --strip-components=1 && \
    rm /tmp/ohmyzsh.tar.gz

# Install autosuggestions and syntax-highlighting
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Add nvim config to share config with vim
RUN mkdir -p /root/.config/nvim/ && \
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" >> /root/.config/nvim/init.vim && \
echo "let &packpath=&runtimepath" >> /root/.config/nvim/init.vim && \
echo "source ~/.vimrc" >> /root/.config/nvim/init.vim
# -----------

COPY --chown=root:root .gitconfig /root/
COPY --chown=root:root .vimrc /root/
COPY --chown=root:root .vimrc.local /root/
COPY --chown=root:root coc-settings.json /root/.config/nvim/
RUN mkdir -p /root/.vim/autoload

# Set PyPI mirror
RUN mkdir -p /root/.config/pip && \
echo "[global]" >> /root/.config/pip/pip.conf && \
echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >> /root/.config/pip/pip.conf && \
echo "format = columns" >> /root/.config/pip/pip.conf
# Install uv for fast Python dependency management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    install -Dm755 /root/.local/bin/uv /usr/local/bin/uv && \
    if [ -f /root/.local/bin/uvx ]; then install -Dm755 /root/.local/bin/uvx /usr/local/bin/uvx; fi
# -----------

# Copy .zshrc
COPY --chown=root:root .zshrc /root/.zshrc
# Install fzf last so that the modified .zsrc will not be overwritted
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf && /root/.fzf/install --key-bindings --completion --update-rc
# -----------

COPY default_clang_tidy /usr/share/default_clang_tidy
COPY default_clang_format /usr/share/default_clang_format

# RUN apt-get update && apt-get install -y openssh-server
# RUN mkdir /var/run/sshd
# RUN echo 'root:aGVsbG9yaGlubw@2022' |chpasswd
# RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
# RUN mkdir /root/.ssh
# EXPOSE 22
# CMD ["/usr/sbin/sshd", "-D"]

# Install cmake via pip, install pygments for gtags, pynvim for neovim
# RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple cmake pygments pynvim thefuck pylint flake8 autopep8 mypy ipdb gpustat opencv-python cython yacs termcolor tabulate gdown matplotlib

CMD ["zsh"]
