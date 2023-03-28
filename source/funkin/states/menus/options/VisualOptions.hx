package funkin.states.menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Preferences;

class VisualOptions extends MusicBeatState {
    override public function create() {
        var bg = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        bg.scrollFactor.set();
        add(bg);

        var fps:Option = new Option('framerate', 'fps', 'int', 1, 60, 240);
        fps.onChange = changeFPS;

        OptionsList.options = [
        new Option('antialiasing', 'antialiasing', 'bool'), 
        fps
        ];
        
        var list = new OptionsList();
        add(list);
        
        super.create();
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