# My super awesome Windows 10

![desktop](https://i.imgur.com/3Qf25H8.png)

# Applications

## Productivity

**[Wox](http://www.wox.one/) - Launcher**

> _Note: I use [a fork](https://github.com/liberize/Wox/releases) by the user **liberize**. This fork allows launching Wox with a query already set. This, in combination with [AutoHotKey](#autohotkey), makes the automation of searches very easy._

> _Note: For Wox to work, we have to also download the [**Everything** search engine](https://www.voidtools.com/).

![wox screenshot](screenshots/wox.png)

* I've been using Alfred for MacOS in the past, and while Wox is not that strong in terms of community and existing plugins, it is equally capable of doing the same stuff as Alfred does.

* Although C#, and Python are the languages that provide libraries for developing the Wox plugins, one can do so in any language you want, as long as it can be compiled to an executable, [according to the docs](http://doc.wox.one/en/plugin/create_plugin.html).

**[AutoHotKey](https://www.autohotkey.com/) - General automation**

* AHK provides a scripting language that allows you to automate most of the things in Windows. From remapping keys, to moving the mouse, you can automate everything.
* I have used AHK extensively in the past and I even created bots for online games with it (yes, I was THAT guy, but not always). You can imagine the power of this tool now.
* You can define also text expansions, so you don't repeat yourself everywhere. [This article](http://www.thenickmay.com/articles/how-to-expand-text-for-free-with-autohotkey/) is super useful on that.

**[Todoist](https://todoist.com/) - Todo lists**

* I use Todoist because it has a nice Android app that comes with a shortcut to add to inbox.
* I'm slowly getting used to GTD, and from my point of view, Todoist has everything I need in the free tier (at least for now). Also it has a nice [Python library](https://github.com/Doist/todoist-python), so someday I can write a Wox plugin with it 😄

**[1password](https://1password.com/) - Password management**

* Having the same password for all the sites is a very bad practice. I learn't this once a friend's Steam account got hacked, and with it, his email, Facebook, and everything.
* Thanks to passwords managers like this one, I don't even need to remember my passwords.

**[ManicTime](https://www.manictime.com/) - Time management**

* Time management is **extremely** important for me. Without it, I can get lost in some computer task for hours, without noticing. It helps me maintain my sanity by making sure that I don't overwork also, as I work remotely.

* I try to be as mindful as possible in my life, so having an app that helps me stay mindful with the computer is a plus.

![manictime screenshot](screenshots/manictime.png)


## Coding

**[Visual Studio Code](https://code.visualstudio.com/) - My main code editor**

**[Microsoft Terminal](https://www.microsoft.com/store/productId/9N0DX20HK701) - Terminal emulator**

**[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) - Run Linux apps natively on Windows**

## Social

**[Unigram](https://github.com/UnigramDev/Unigram) - A Telegram client optimized for Windows 10**

* The regular Telegram client has some issues with DPI scaling, meaning that if I move the window from my 1080p monitor to the Surface one, it'll stay with the same resolution. This doesn't happen with Unigram, and I get integrated notifications.

## Web browsing

**[Microsoft Edge](https://www.microsoft.com/en-us/windows/microsoft-edge)**

* Edge is just the best browser for my Surface Pro, it saves a ton of battery. Plus, it is surprisingly fast. I have all the required extensions that I need, except perhaps, Vim keybindings. (I'm aware of [edge-vimium](https://github.com/iscriptology/edge-vimium) but it is unmaintained, buggy, and it isn't published on the Microsoft Store 😢)

### Edge extensions

**[Grammarly](https://app.grammarly.com/)**

**[uBlock Origin](https://www.microsoft.com/en-us/p/ublock-origin/9nblggh444l4)**

**[1password](https://www.microsoft.com/en-us/p/1password/9wzdncrdr64j)**

## Command Line Apps

**[`bat`](https://github.com/sharkdp/bat) - A cat(1) clone with wings**

## Operating System Extensions

**[Link Shell Extension](http://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html#contact) - Context menu entry to create symlinks**

* Sometimes it is useful to create a symbolic link from a folder/file to another place. This is specially useful when dealing with configuration files that are checked in a version control system like Git.

# Preferences

## Set DNS to Google

* Docker has issues with the default DNS provided with Windows 10, to set it to Google's DNS, [follow step 2 of this guide](https://www.cactusvpn.com/tutorials/how-to-set-up-smart-dns-on-windows-10/).
