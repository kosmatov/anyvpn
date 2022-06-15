WORKDIR := $(shell pwd)

all: disconnect connect

start: /Applications/xbar.app
	open /Applications/xbar.app

stop:
	killall xbar

restart: stop start

connect:
	./connect-vpn

disconnect:
	@echo "signal SIGTERM" | nc -U socket

install: xkbswitch-macosx
	sed s:__workdir__:$(WORKDIR): xbar-vpn-plugin > ~/Library/Application\ Support/xbar/plugins/openvpn.5s.sh
	chmod a+x ~/Library/Application\ Support/xbar/plugins/openvpn.5s.sh
	@test -e socket || touch socket
	@sudo grep $(USER) /etc/sudoers | grep openvpn > /dev/null 2>&1 || make update_sudoers

xkbswitch-macosx:
	git clone https://github.com/myshov/xkbswitch-macosx

/Applications/xbar.app:
	brew install --cask xbar

update_sudoers:
	@echo "$(USER) ALL = (ALL) NOPASSWD: /usr/local/opt/openvpn/sbin/openvpn" | sudo tee -a /etc/sudoers

check-runned:
	@(grep "Initialization Sequence Completed" openvpn.log > /dev/null 2>&1 && echo "verb 0" || echo "pid") | nc -U socket

check-connected:
	@echo "load-stats" | nc -U socket | grep "bytesin=[1-9]*"
