package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Song;
import funkin.ui.Alphabet;
import funkin.ui.AlphabetList;
import funkin.util.FunkinUtil;
import sys.FileSystem;

class FreeplayMenu extends MusicBeatState {
    var songz:Array<String> = [];
    var list:AlphabetList;
    var curSelected:Int = 0;
    var diffShit:FlxText;
    var curDiff:Int = 0;

    override public function create() {
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        diffShit = new FlxText(0, 0, 0, '', 32);
        diffShit.setFormat(FunkinPaths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
        diffShit.scrollFactor.set();
        add(diffShit);
        
        for (i in FileSystem.readDirectory('assets/songs')) {
            songz.push(i);
        }
        #if MODS_ENABLED
        if (FunkinPaths.exists('assets/${FunkinPaths.currentModDir}/songs')) {
            for (i in FileSystem.readDirectory('assets/${FunkinPaths.currentModDir}/songs')) {
                songz.push(i);
            }
        }
        #end

        list = new AlphabetList(songz, curSelected, true, true, true);
        add(list);

        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.LEFT) {
            curDiff -= 1;
        }

        if (FlxG.keys.justPressed.RIGHT) {
            curDiff += 1;
        }
        
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new MainMenuState());
        }

        curSelected = list.curSelected;
        
        list.onSelect(function() {
            if (FlxG.keys.justPressed.ENTER) {
                PlayState.song = Song.loadSong(songz[curSelected], FunkinUtil.difficulties[curDiff]);
                FlxG.switchState(new PlayState());
            }
        });

        if (curDiff < 0) {
            curDiff = FunkinUtil.difficulties.length - 1;
        }
        if (curDiff >= FunkinUtil.difficulties.length) {
            curDiff = 0;
        }

        diffShit.text = FunkinUtil.difficulties[curDiff];

        super.update(elapsed);
    }
}