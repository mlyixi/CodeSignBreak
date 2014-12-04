CodeSignBreak
=============
This is a tool that patches Xcode and your projects in order to let you install your apps on your `jailbreak` device with `appsync` like [JailCoder](http://oneiros.altervista.org/jailcoder/) which not updates now(on 10.10 and XCode6 crashed).

[Download Link](http://mlyixi.qiniudn.com/CodeSignBreak.zip)

# Requirements
## On your computer
There are two methods to install Xcode:

1. drag from dmg to `/Applications`.

2. install from Appstore.

The latter installs the Xcode as `root` with group `wheel` while the former as `login user` with group `admin`. However, the owner of one iPhoneSimulator dynamic libs 'dyld_sim' must be `root` 

> Detail: ` find . -user root -print`
> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib/dyld_sim
> /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man/whatis
> /Applications/Xcode.app/Contents/Developer/usr/share/man/whatis

It's not a good option to elevate privileges in applications. So if you installed Xcode in Appstore, change it by following command: 
 ```zsh
sudo chgrp -R admin /Applications/Xcode.app 
 ```
 
 If you have better command, welcome to provide.

## On your device

1. Jailbreak

2. [appsync(not ppsync)](https://github.com/angelXwind/AppSync)

# Testing
* Xcode 6.1 with iOS8 on 10.10.1
* Xcode 5.1 with iOS8 on 10.9.3

# What CodeSignBreak does
* [For English](http://stackoverflow.com/a/4180498/555336)

* [For Chinese](http://mlyixi.byethost32.com/blog/?p=84)

# Announcement
For developers of personnal interest only.
