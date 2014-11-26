CodeSignBreak
=============
This is a tool that patches Xcode and your projects in order to let you install your apps on your `jailbreak` device with `appsync` like [JailCoder](http://oneiros.altervista.org/jailcoder/) which not updates now(on 10.10 and XCode6 crashed).

# Requirements
## On your computer
There are two methods to install Xcode:

1. draging it from dmg to `/Applications`.

2. install from Appstore.

The latter installs the Xcode as `root` while the former installs as `login user`. 
It's not a good idea to elevate privileges in applications. So if you install Xcode in Appstore, change it by following command: 
 ```zsh
 sudo chown -R $USER /Applications/Xcode.app
 ```

## On your device

1. Jailbreak

2. [appsync(not ppsync)](https://github.com/angelXwind/AppSync)

# Just for Testing now
Xcode 6.1 with iOS8

# What the app does

[For English](http://stackoverflow.com/a/4180498/555336)

[For Chinese](http://mlyixi.byethost32.com/blog/?p=84)
