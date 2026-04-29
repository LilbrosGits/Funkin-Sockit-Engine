package funkin.obj;

import funkin.backend.inputs.PlayerSettings;
import funkin.data.Song.StrumlineData;
import assets.Paths;
import objects.SockitSprite;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import funkin.backend.inputs.Controls.Control;
import flixel.util.FlxColor;

using StringTools;

class Note extends SockitSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var rating:String = "sick";
	public var prevNote:Note;
	public var speed:Float = 1.0;
	public var type:String = 'default';

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public var dir:Array<String> = ['left', 'down', 'up', 'right'];

	public var tooEarly:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?type:String = 'default')
	{
		super(0, 0);

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		x -= 20;
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		this.type = type;

		switch (type)
		{
			case 'retro':
				loadSpriteFile(Paths.getJson('UI/noteStyles/retro/style'));

				setGraphicSize(Std.int(width * 0.65));
				updateHitbox();

			default:
				loadSpriteFile(Paths.getJson('UI/noteStyles/default/style'));

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		x += swagWidth * noteData;
		playAnim(dir[noteData]);
		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			playAnim('hold-' + dir[noteData]);

			updateHitbox();

			x -= width / 2;

			if (type == 'retro')
				x += 30;

			if (prevNote.isSustainNote)
			{
				playAnim('endhold-' + dir[noteData]);

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
			{
				canBeHit = true;
			}
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
				tooLate = true;
			else {
				if (strumTime > Conductor.songPosition + Conductor.safeZoneOffset && strumTime > Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					tooEarly = true;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
			{
				wasGoodHit = true;
			}
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}

class NoteSplash extends SockitSprite {
	public var noteID:Int = 0;
	public function new(x, y, data) {
		super(x, y);
		noteID = data;
	}

	public function loadNoteSplashes(data:StrumlineData) {
		loadSpriteFile(Paths.getJson('UI/noteStyles/default/splashes'));
		setGraphicSize(Std.int(width * 0.7));
		x += Note.swagWidth * noteID;
		visible = false;

		x += data.strumPos[0];

		ID = noteID;
	}

	override public function update(elapsed) {
		super.update(elapsed);

		if (animation.curAnim != null) {
			if (animation.curAnim.finished) {
				if (animation.curAnim.name.contains('start')) {
					playAnim('${['purple', 'blue', 'green', 'red'][noteID]}-hold');
				}
				if (animation.curAnim.name.contains('end')) {
					visible = false;
				}
				if (animation.curAnim.name.contains('splash-')) {
					visible = false;
				}
			}
		}

	}
}