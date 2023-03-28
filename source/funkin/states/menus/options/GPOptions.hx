package funkin.states.menus.options;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;

class GPOptions extends MusicBeatState {
    override public function create() {
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        OptionsList.options = [
        new Option('downscroll', 'downscroll', 'bool'), 
        new Option('ghost tapping', 'ghostTapping', 'bool')
        ];
        
        var list = new OptionsList();
        add(list);
        
        super.create();
    }
}