WORKDIR := $(shell pwd)

all: disconnect connect

start:
	open /Applications/xbar.app

stop:
	killall xbar

restart: stop start

connect: disconnect
	./connect-vpn

disconnect:
	@echo "signal SIGTERM" | nc -U socket || true

install: xkbswitch-macosx /Applications/xbar.app /opt/homebrew/sbin/openvpn
	sed s:__workdir__:$(WORKDIR):g xbar-vpn-plugin > ~/Library/Application\ Support/xbar/plugins/openvpn.5s.sh
	chmod a+x ~/Library/Application\ Support/xbar/plugins/openvpn.5s.sh
	@test -e socket || touch socket
	@sudo grep $(USER) /etc/sudoers | grep openvpn > /dev/null 2>&1 || make update_sudoers

/opt/homebrew/sbin/openvpn:
	brew install openvpn

xkbswitch-macosx:
	git clone https://github.com/xiehuc/xkbswitch-macosx
	make -C xkbswitch-macosx

/Applications/xbar.app:
	brew install --cask xbar

update_sudoers:
	@echo "$(USER) ALL = (ALL) NOPASSWD: /opt/homebrew/sbin/openvpn" | sudo tee -a /etc/sudoers

check-runned:
	@echo "state all" | nc -U socket | grep CONNECTING

check-connected: check_errors
	@echo "state all" | nc -U socket | grep CONNECTED

check-password-need:
	@echo "" | nc -U socket | grep -o PASSWORD

state:
	@echo "state all" | nc -U socket | grep "[0-9]*,[A-Z]*" | tail -1 | cut -d, -f2

check_errors:
	[ `tail -4 openvpn.log| grep "write UDP: Can't assign" | wc -l` -eq 4 ] && make connect || true
