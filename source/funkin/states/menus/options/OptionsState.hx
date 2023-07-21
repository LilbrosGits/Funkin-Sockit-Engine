package funkin.states.menus.options;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;

class OptionsState extends MusicBeatState {
    public function new(optionArray:Array<Option>) {
        super();
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);
        
        var list = new OptionsList(optionArray);
        add(list);
    }
}