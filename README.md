## Wyoming Satellite on Android

This project provides a simple way of setting up 

### Prerequisites

- Install [Termux](https://github.com/termux/termux-app) (open source terminal emulator app)
- Install [Termux:API](https://github.com/termux/termux-api) (necessary to get mic access)
- Install [Termux:Boot](https://github.com/termux/termux-boot) (optional and only required if you want wyoming-satellite to autostart when your device restarts)

### How to install Wyoming Satellite on Android

Open Termux and run:

``` Bash
wget -qO- https://raw.githubusercontent.com/T-vK/wyoming-satellite-termux/refs/heads/main/install.sh | bash
```

### How to uninstall Wyoming Satellite on Android

Open Termux and run:

``` Bash
wget -qO- https://raw.githubusercontent.com/T-vK/wyoming-satellite-termux/refs/heads/main/uninstall.sh | bash
```

### Integrate into HomeAssistant

- Open Home Assistant go to Settings → Integrations → Add Integration → Wyoming Protocol
- It should ask you for a host and a port now. Enter the IP address of your Android device into the host-field (if unsure what you IP is, run `ifconfig` in Termux and check the output, it will most likely start with `192.`) and enter 10700 in the port-field.
