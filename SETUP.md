# macOS Sierra GnuPG modern setup #

In order to install GnuPG modern on macOS and get it running with SSH only a few
things are required:

## Software installation ##
Install `gnupg` and `pinentry-mac`.  
`pinentry-mac` is used to prompt for your smartcard PIN.
```sh
brew install gnupg pinentry-mac
```

## `$HOME/.gnupg/gpg-agent.conf` ##
```sh
enable-ssh-support
pinentry-program /usr/local/bin/pinentry-mac
```

## `$HOME/Library/LaunchAgents/gpg.agent.daemon.plist` ##
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>gpg.agent.daemon.plist</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/gpgconf</string>
		<string>--launch</string>
		<string>gpg-agent</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
```

To set the location of the GPG Agent socket you have two choices:
* Set it in your rc file, this is the easy way.
* Set it system wide with launchctl, this ensures you can use GPG
  with programs launched through the finder and spotlight.

## rc file (zsh, bash etc.) ##
```sh
SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
```

## `$HOME/Library/LaunchAgents/gpg.agent.setenv.plist` ##
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>gpg.agent.setenv</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/sh</string>
		<string>-c</string>
		<string>/bin/launchctl setenv SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
```

In order for `$SSH_AUTH_SOCK` not to be overwritten you will need to disable
the macOS ssh-agent that is automatically started at boot.  
(Un-)fortunately System Integrity Protection prevents you from just running
`launchctl unload /System/Library/LaunchAgents/com.openssh.ssh-agent.plist`.
You will need to boot into your Recovery OS (hold Cmd+R at boot) and run
`csrutil disable`, then boot normally, run the `unload` command and then
run `csrutil enable` in the Recovery OS.

## `$HOME/.gnupg/scdaemon.conf` ##
Disable the internal CCID driver.  
On some systems this driver does not work and you will have to wait for it to
time out before the smartcard daemon falls back to other drivers.  
You should try running without this first, but if logging in via SSH or signing
commits takes ages, try this workaround.
```
disable-ccid
```
