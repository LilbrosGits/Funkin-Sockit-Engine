package funkin.states.menus.options;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Preferences;
import funkin.ui.Alphabet;
import funkin.ui.AlphabetList;
import funkin.ui.CheckBox;
import funkin.util.FunkinUtil;

using StringTools;

class OptionsMenu extends MusicBeatState {
    var list:AlphabetList;
    var curSelected:Int = 0;
    var fps:Option = new Option('framerate', 'fps', 'int', 1, 60, 240);

    public function openLibrary(state:Int = 0) {
        fps.onChange = changeFPS;
        switch(state) {
            case 0:
                FlxG.switchState(new OptionsState([new Option('downscroll', 'downscroll', 'bool'), 
                new Option('ghost tapping', 'ghostTapping', 'bool'),
                new Option('safe zone offset', 'safeZoneOffset', 'float', 0.1, 1, 10)]));
            case 1:
                FlxG.switchState(new OptionsState([new Option('antialiasing', 'antialiasing', 'bool'),
                fps]));
        }
    }
    
    override public function create() {
        var bg:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        list = new AlphabetList(['Gameplay', 'Visual'], false, true, true);
        add(list);

        super.create();
    }

    override public function update(elapsed:Float) {
        curSelected = list.curSelected;

        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new MainMenuState());
        }

        list.onSelect(function() {
            if (FlxG.keys.justPressed.ENTER) {
                openLibrary(curSelected);
            }
        });

        super.update(elapsed);
    }

    function changeFPS() {
		if(Preferences.fps > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = Preferences.fps;
			FlxG.drawFramerate = Preferences.fps;
		}
		else
		{
			FlxG.drawFramerate = Preferences.fps;
			FlxG.updateFramerate = Preferences.fps;
		}
    }
}