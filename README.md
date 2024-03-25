# FNF: Sockit Engine

This is the new repository for the rewrite of FNF: Sockit Engine, a FNF Engine i had made, and that i'm rewriting completely from scratch.

Play the OG FNF On Newgrounds here: https://www.newgrounds.com/portal/view/770371

Support  the OG FNF on the itch.io page: https://ninja-muffin24.itch.io/funkin

## Credits / shoutouts

- [Lilbros (me!)](https://twitter.com/LilbrosD) - Programmer

## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE ENGINES SOURCE CODE!!!

### Installing the Required Programs

First, you need to install Haxe and HaxeFlixel. 
1. [Install Haxe 4.2.0](https://haxe.org/download/version/4.2.0/)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
```

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git polymod https://github.com/larsiusprime/polymod.git` to install Polymod.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.
5. Run `haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit` for LUA Compatability.
6. Run `haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit` for LUA Compatability.
7. Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` to install more Addons.

After that if your on windows you'll have to install Visual Studio (2019 COMMUNITY VERSION ONLY) While installing, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

(This may be from 5 to 25 GB)

### Compiling game
NOTE: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling

Once you have all those installed, it's pretty easy to compile the game. You just need to run `lime test html5 -debug` in the root of the project to build and run the HTML5 version. (ninjamuffins command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))
To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run `lime test linux -debug` and then run the executable file in export/release/linux/bin. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\OSname `ex: windows, linux, etc.`\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

### Recommended	IDE'S/Code Editors

Visual Studio Code

HaxeDevelop (Only for Windows)

First run limes setup for flixel
```
haxelib run lime setup flixel
haxelib run lime setup
```
It should ask you what IDE or Code editor you would like to use.
After that you're good to go!
