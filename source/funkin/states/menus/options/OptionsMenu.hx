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

    public function openLibrary(state:Int = 0) {
        switch(state) {
            case 0:
                FlxG.switchState(new GPOptions());
            case 1:
                FlxG.switchState(new VisualOptions());
            case 2:
                FlxG.switchState(new GPOptions());
        }
    }
    
    override public function create() {
        var bg:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        list = new AlphabetList(['Gameplay', 'Visual', 'Controls'], curSelected, false, true, true);
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
}