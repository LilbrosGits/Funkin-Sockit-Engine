package funkin.ui;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;

class CheckBox extends FlxSprite {
    public var value(default, set):Bool;
    public function new(x:Float, y:Float, variable:Bool = false) {
        super(x, y);

        frames = FunkinPaths.sparrowAtlas('UI/options/checkboxThingie');

        animation.addByPrefix('false', 'Check Box unselected', 24, false);
        animation.addByPrefix('true', 'Check Box selecting animation', 24, false);
        setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
        value = variable;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        switch (animation.curAnim.name)
		{
			case 'true':
				offset.set(17, 70);
			case 'false':
				offset.set();
            default:
                offset.set();
		}
    }

    public function set_value(state:Bool){
        if (state) {
            animation.play('true', true);
            //offset.set(17, 70);
        }
        else {
            animation.play('false');
            //offset.set();
        }
        return state;
    }
}