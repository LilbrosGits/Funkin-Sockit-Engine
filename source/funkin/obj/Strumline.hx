package funkin.obj;

import funkin.meta.substates.GameSubState;
import funkin.data.Song.NoteData;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import funkin.data.Song.Difficulty;
import funkin.data.Song.SongData;
import flixel.group.FlxSpriteGroup.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import assets.Paths;
import flixel.tweens.FlxTween;
import objects.SockitSprite;
import funkin.data.Song.StrumlineData;
import flixel.FlxSprite;

class Strumline extends GameSubState {
    public var data:StrumlineData;
	public var notes:FlxTypedGroup<Note>;
	public var strumNotes:FlxSpriteGroup;
	public var unspawnNotes:Array<Note> = [];

    public function new() {
        super('');
		strumNotes = new FlxSpriteGroup();
    }

    public function loadStrumline(strumdata:StrumlineData, type:String) {
		var dir:Array<String> = ['left', 'down', 'up', 'right'];
        data = strumdata;
		for (i in 0...data.keys)
		{
			var babyArrow:SockitSprite = new SockitSprite(0, data.strumPos[1]);

			switch (type)
			{
				case 'retro':
					babyArrow.loadSpriteFile(Paths.getJson('UI/noteStyles/retro/style'));

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.6));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;

				default:
					babyArrow.loadSpriteFile(Paths.getJson('UI/noteStyles/default/style'));

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					babyArrow.x += Note.swagWidth * i;
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			babyArrow.playAnim('static-' + dir[i]);
			babyArrow.x += data.strumPos[0];

			strumNotes.add(babyArrow);
		}
	}

	public function generateSong(songNotes:StrumlineData, curDifficulty:Int = 0):Void
	{
		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<NoteData> = [];

		// NEW SHIT
		noteData = songNotes.strumlineData[curDifficulty].notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (note in noteData)
		{
			var daStrumTime:Float = note.strumTime;
			var daNoteData:Int = Std.int(note.noteID % 4);

			var gottaHitNote:Bool = songNotes.cpu;

			if (note.noteID < 4)
			{
				gottaHitNote = !songNotes.cpu;
			}

			var oldNote:Note;
			if (unspawnNotes.length > 0)
				oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
			else
				oldNote = null;

			var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
			swagNote.sustainLength = note.sustainLength;
			swagNote.scrollFactor.set(0, 0);

			var susLength:Float = note.sustainLength;

			susLength = susLength / Conductor.stepCrochet;
			unspawnNotes.push(swagNote);

			for (susNote in 0...Math.floor(susLength))
			{
				oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

				var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
				sustainNote.scrollFactor.set();
				unspawnNotes.push(sustainNote);

				sustainNote.mustPress = gottaHitNote;

				sustainNote.x += songNotes.strumPos[0]; 
			}

			swagNote.mustPress = gottaHitNote;


			swagNote.x = swagNote.x + songNotes.strumPos[0]; 
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		notes.forEachAlive(function(daNote:Note) {
			daNote.y = (data.strumPos[1] - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(data.scrollSpeed, 2)));
			if (daNote.mustPress && daNote.wasGoodHit) {
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
		});
		keyShit();
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		var directions:Array<String> = ['left', 'down', 'up', 'right'];

		if ((upP || rightP || downP || leftP))
		{
			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				if (daNote.wasGoodHit)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left))
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (data != null && !data.cpu) {
			strumNotes.forEach(function(spr:SockitSprite)
			{
				switch (spr.ID)
				{
					case 0:
						if (leftP && spr.animation.curAnim.name != 'confirm-static-' + directions[spr.ID])
							spr.playAnim('hit-static-' + directions[spr.ID]);
						if (leftR)
							spr.playAnim('static-' + directions[spr.ID]);
					case 1:
						if (downP && spr.animation.curAnim.name != 'confirm-static-' + directions[spr.ID])
							spr.playAnim('hit-static-' + directions[spr.ID]);
						if (downR)
							spr.playAnim('static-' + directions[spr.ID]);
					case 2:
						if (upP && spr.animation.curAnim.name != 'confirm-static-' + directions[spr.ID])
							spr.playAnim('hit-static-' + directions[spr.ID]);
						if (upR)
							spr.playAnim('static-' + directions[spr.ID]);
					case 3:
						if (rightP && spr.animation.curAnim.name != 'confirm-static-' + directions[spr.ID])
							spr.playAnim('hit-static-' + directions[spr.ID]);
						if (rightR)
							spr.playAnim('static-' + directions[spr.ID]);
				}
	
				if (spr.animation.curAnim.name == 'confirm-static-' + directions[spr.ID])
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
	}

	function badNoteCheck()
	{
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			//badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		var swag:Array<String> = ['left', 'down', 'up', 'right'];
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}
}