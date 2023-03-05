package funkin.obj;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.system.*;

class StaticNote extends FlxSprite
{
	public var keyAmt:Int = 0;

	public function new(x:Float, y:Float, keyAmt:Int, skin:String = 'NOTE_assets')
	{
		super(x, y);

		this.keyAmt = keyAmt;

		frames = FunkinPaths.sparrowAtlas('UI/HUD/$skin');

		setGraphicSize(Std.int(width * 0.7));

		switch (keyAmt)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT', 24, false);
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
				animation.play('static');
			case 1:
				animation.addByPrefix('static', 'arrowDOWN', 24, false);
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
				animation.play('static');
			case 2:
				animation.addByPrefix('static', 'arrowUP', 24, false);
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
				animation.play('static');
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT', 24, false);
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
				animation.play('static');
		}
		antialiasing = Preferences.antialiasing;
	}

	public function fixPositionings()
	{
		x += Note.noteWidth * keyAmt;
	}
}