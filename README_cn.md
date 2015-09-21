CodeSignBreak
=============
由于[JailCoder](http://oneiros.altervista.org/jailcoder/)没有更新且在10.10下崩溃，所以仿照它自己写了一个iOS免证书真机调试的工具，主要功能是自动给Xcode6(-)和项目文件打补丁。请保证iOS设备已越狱并安装有`appsync`。

Xcode7(+)官方允许真机调试了,不得不说是个好消息.
[下载链接](http://mlyixi.qiniudn.com/CodeSignBreak.zip)

# 要求
## 电脑上
有两种安装Xcode的方法：

1. 下载dmg并拖拽到 `/Applications`.

2. 从Appstore里直接安装.
第2种方法安装的Xcode权限是`root:wheel`, 而第1种安装的权限`login user:admin`. 无论哪种，iPhoneSimulator动态库文件 'dyld_sim'必须是`root`:
> Detail: ` find . -user root -print`
> /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib/dyld_sim
> /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man/whatis
> /Applications/Xcode.app/Contents/Developer/usr/share/man/whatis
由于在程序里面提权并不好，所以，如果你是使用第二种方式安装的话，请使用下面的命令改变文件拥有组为`admin`:
 ```zsh
sudo chgrp -R admin /Applications/Xcode.app 
 ```
## 设备上

1. Jailbreak

2. [appsync(不要通过PP助手安装)](https://github.com/angelXwind/AppSync)

# 已测试
我只有一台设备供测试用，所以，如果你运行`CodeSignBreak`成功，欢迎给我发邮件。
* Xcode 6.3 with iOS8.1 on 10.10.3
* Xcode 6.1 with iOS8.1 on 10.10.1
* Xcode 5.1 with iOS8.1 on 10.9.3

# CodeSignBreak做了什么？
* [English](http://stackoverflow.com/a/4180498/555336)

* [中文](http://mlyixi.byethost32.com/blog/?p=84)

# 声明
只供个人开发者使用
