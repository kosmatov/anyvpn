ANYDIR := $(shell pwd)
USERNAME := $(shell head -1 auth)

all: disconnect connect

connect:
	@echo $(USERNAME) > auth
	$(eval PASSWD := $(shell read -e -p "yubikey: " PASSWD; echo $$PASSWD))
	@./remap $(PASSWD) >> auth
	@ps ax | grep AnyBar | grep -v grep || /Applications/AnyBar.app/Contents/MacOS/AnyBar
	@echo -n "yellow" | nc -4u -w0 localhost 1738
	sudo /usr/local/opt/openvpn/sbin/openvpn \
		--config $(ANYDIR)/config.ovpn \
		--script-security 2 \
		--daemon \
		--log $(ANYDIR)/openvpn.log \
		--route-up $(ANYDIR)/up \
		--down $(ANYDIR)/down \
		--auth-user-pass $(ANYDIR)/auth

disconnect:
	@ps ax | grep openvpn | grep -v grep | cut -d' ' -f1 | xargs sudo kill
	@echo -n "filled" | nc -4u -w0 localhost 1738
