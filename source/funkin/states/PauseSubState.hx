package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.obj.Stage.ImageSprite;
import funkin.system.MusicBeat.MusicBeatSubState;
import funkin.ui.Alphabet;

class PauseSubState extends MusicBeatSubState {
    var swagphabet:FlxTypedGroup<Alphabet>;
    var options:Array<String> = ['Resume', 'Restart Song', 'Exit To Menu'];
    var curSelected:Int = 0;
    
    public function new() {
        super();
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        bg.scrollFactor.set();
        add(bg);

        swagphabet = new FlxTypedGroup<Alphabet>();
        add(swagphabet);

        for (i in 0...options.length) {
            var swag:Alphabet = new Alphabet(0, 0, options[i], true);//I LOVE THE WORD SWAG ARGH
            swag.isMenuItem = true;
            swag.targetY = i;
            swagphabet.add(swag);
        }

        select();

        cameras = [FlxG.cameras.list[1]];
    }

    override public function update(elapsed:Float) {
        super.update(elapsed); 

        var up:Bool = FlxG.keys.justPressed.UP;
        var down:Bool = FlxG.keys.justPressed.DOWN;
        var accept:Bool = FlxG.keys.justPressed.ENTER;

        if (up) {
            select(-1);
        }
        if (down) {
            select(1);
        }

        if (accept) {
            var daSelected:String = options[curSelected];
            switch(daSelected) {
                case 'Resume':
                    close();
                case 'Restart Song':
                    FlxG.switchState(new PlayState());
                case 'Exit To Menu':
                    FlxG.switchState(new funkin.states.menus.MainMenuState());
            }
        }
    }

    function select(change:Int = 0) {
        curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in swagphabet.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}