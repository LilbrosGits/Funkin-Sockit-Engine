package funkin.states.menus.modding;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.ui.Alphabet;
import funkin.util.FunkinUtil;
import sys.FileSystem;

class ModMenu extends MusicBeatState {
    var listFont:FlxTypedGroup<Alphabet>;
    var gonnakms:Array<String> = [];
    var curS:Int = 0;
    var gay:FlxObject;

    override public function create() {
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        gay = new FlxObject(0, 0, 1, 1);
        add(gay);
        
        for (file in FileSystem.readDirectory('mods/')) {
            gonnakms.push(file);
        }
        listFont = new FlxTypedGroup<Alphabet>();
        add(listFont);

        for (i in 0...gonnakms.length) {
            var txt:Alphabet = new Alphabet(0, 0 + (i * 100), gonnakms[i], true);
            txt.ID = i;
            txt.isMenuItem = true;
            txt.targetY = i;
            listFont.add(txt);
        }

        FlxG.camera.follow(gay, LOCKON, FunkinUtil.adjustedFrame(0.06));
        
        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ENTER) {
            FunkinPaths.currentModDir = gonnakms[curS];
        }
        if (FlxG.keys.justPressed.UP) {
            curS -= 1;
        }
        if (FlxG.keys.justPressed.DOWN) {
            curS += 1;
        }
        if (curS >= gonnakms.length)
            curS = 0;
        if (curS < 0)
            curS = gonnakms.length - 1;
        
        listFont.forEach(function(txt:Alphabet) {
            if (txt.ID == curS) {
                txt.alpha = 1;
                gay.setPosition(FlxG.width / 2, txt.y);
            }
            else
                txt.alpha = 0.6;
        });

        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new MainMenuState());
        }
        super.update(elapsed);
    }
}