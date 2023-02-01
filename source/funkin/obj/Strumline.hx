package funkin.obj;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.system.*;

class StaticNote extends FlxSprite
{
	public var noteData:Int = 0;

	public function new(x:Float, y:Float, noteData:Int)
	{
		super(x, y);

		this.noteData = noteData;

		frames = FunkinPaths.sparrowAtlas('UI/HUD/NOTE_assets');

		setGraphicSize(Std.int(width * 0.7));

		switch (noteData)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT', 24, false);
				animation.play('static');
			case 1:
				animation.addByPrefix('static', 'arrowDOWN', 24, false);
				animation.play('static');
			case 2:
				animation.addByPrefix('static', 'arrowUP', 24, false);
				animation.play('static');
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT', 24, false);
				animation.play('static');
		}
	}

	public function fixPositionings()
	{
		x += Note.noteWidth * noteData;
	}
}

class Strumline extends FlxSubState
{
	public function new(x:Float, y:Float, player:Int)
	{
		super();
		for (i in 0...4)
		{
			var strumNote:StaticNote = new StaticNote(x, y, i);
			add(strumNote);

			strumNote.ID = i;

			strumNote.x += 50;
			strumNote.x += ((FlxG.width / 2) * player);

			strumNote.fixPositionings();
		}
	}
}
