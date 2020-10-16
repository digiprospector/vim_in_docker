FROM ubuntu:20.04

ENV     DEBIAN_FRONTEND noninteractive
RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local

#apt source
COPY    sources.list /etc/apt/
COPY    vimrc /root/.vimrc
COPY    vimrc.local /root/.vimrc.local
COPY    vimrc.local.bundles /root/.vimrc.local.bundles

#install
RUN     buildDeps='gcc make libncurses5-dev g++ liblua5.3-dev libz-dev libtinfo5 cmake' InstallPkg='libpython3-dev git curl python3 ca-certificates ssh' \
        && apt update \
        && apt -y install $buildDeps $InstallPkg --no-install-recommends \
        && cd /root && git clone https://github.com/vim/vim.git \
        && cd /root/vim && make distclean && CFLAGS=-fPIC ./configure --with-features=huge --enable-multibyte --enable-python3interp=yes --with-python3-config-dir=/usr/lib/python3.8/config-3.8-x86_64-linux-gnu --enable-luainterp=yes --enable-cscope --prefix=/usr/local --enable-gui=no --with-tlib=ncurses && make install \
        && rm -rf /root/vim && cd /root\
		&& git clone https://github.com/lifepillar/vim-solarized8.git ~/.vim/pack/themes/opt/solarized8 \
		&& sh -c '/bin/echo -e “\n” | vim +PlugInstall +qall' \
		&& cd ~/.vim/plugged/YouCompleteMe/ && ./install.py && rm -rf ~/.vim/plugged/YouCompleteMe/.git \
        && apt-get purge -y --auto-remove $buildDeps\
		&& rm -rf /var/lib/apt/lists/*

EXPOSE 22
RUN mkdir /var/run/sshd
CMD ["/usr/sbin/sshd", "-D"]