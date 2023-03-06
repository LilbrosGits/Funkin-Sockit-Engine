package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Song;
import funkin.ui.Alphabet;
import sys.FileSystem;

class FreeplayMenu extends MusicBeatState {
    var songz:Array<String> = [];
    var ihatemylife:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    override public function create() {
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        add(bg);
        
        for (i in FileSystem.readDirectory('assets/songs')) {
            songz.push(i);
        }
        #if MODS_ENABLED
        for (i in FileSystem.readDirectory('assets/${FunkinPaths.currentModDir}/songs')) {
            songz.push(i);
        }
        #end

        ihatemylife = new FlxTypedGroup<Alphabet>();
        add(ihatemylife);

        for (cool in 0...songz.length) {
            var txt:Alphabet = new Alphabet(0, 0, songz[cool], true);
            txt.isMenuItem = true;
            txt.targetY = cool;
            txt.ID = cool;
            ihatemylife.add(txt);
        }

        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.UP) {
            curSelected -= 1;
        }

        if (FlxG.keys.justPressed.DOWN) {
            curSelected += 1;
        }

        ihatemylife.forEach(function(cool:Alphabet) {
            if (cool.ID == curSelected) {
                cool.alpha = 1;
            }
            else {
                cool.alpha = 0.6;
            }
        });

        if (FlxG.keys.justPressed.ENTER) {
            PlayState.song = Song.loadSong(songz[curSelected], 'normal');
            FlxG.switchState(new PlayState());
        }

        if (curSelected < 0) {
            curSelected = songz.length - 1;
        }
        if (curSelected >= songz.length) {
            curSelected = 0;
        }

        super.update(elapsed);
    }
}