package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import funkin.system.MusicBeat.MusicBeatSubState;

class PauseSubState extends MusicBeatSubState {
    public function new() {
        super();
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        bg.scrollFactor.set();
        add(bg);

        bg.cameras = [FlxG.cameras.list[1]];
    }

    override public function update(elapsed:Float) {
        super.update(elapsed); 

        if (FlxG.keys.justPressed.ENTER) {
            close();
        }
    }
}