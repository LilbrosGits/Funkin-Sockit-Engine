package funkin.obj;

import funkin.meta.states.PlayState;
import funkin.meta.substates.GameSubState;
import funkin.data.Song.NoteData;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import funkin.data.Song.Difficulty;
import funkin.data.Song.SongData;
import flixel.tweens.FlxEase;
import assets.Paths;
import flixel.tweens.FlxTween;
import objects.SockitSprite;
import funkin.data.Song.StrumlineData;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Strumline extends GameSubState {
    public var data:StrumlineData;
	public var notes:FlxTypedGroup<Note>;
	public var strumNotes:FlxTypedSpriteGroup<SockitSprite>;
	public var unspawnNotes:Array<Note> = [];

    public function new() {
        super('');
		strumNotes = new FlxTypedSpriteGroup<SockitSprite>();
		add(strumNotes);
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

			var gottaHitNote:Bool = !data.cpu;
			
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

		if (PlayState.instance.countdownFinished && PlayState.instance.editorEnabled == false) {
			notes.forEachAlive(function(daNote:Note) {
				daNote.y = (data.strumPos[1] - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(data.scrollSpeed, 2)));
				if (!daNote.mustPress) {
					if (daNote.strumTime <= Conductor.songPosition) {
						goodNoteHit(daNote);
					}
				}
				else {
					if (daNote.y < 0 - daNote.height) {
						noteMiss(daNote.noteData);
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			});

			for (strumNote in strumNotes.members) {
				if (strumNote.animation.curAnim.finished && strumNote.animation.curAnim.name == 'confirm-static-' + ['left', 'down', 'up', 'right'][strumNote.ID])
						strumNote.playAnim('static-' + ['left', 'down', 'up', 'right'][strumNote.ID]);
				
				if (strumNote.animation.curAnim.name == 'confirm-static-' + ['left', 'down', 'up', 'right'][strumNote.ID])
				{
					strumNote.centerOffsets();
					strumNote.offset.x -= 13;
					strumNote.offset.y -= 13;
				}
				else
					strumNote.centerOffsets();
			}
			keyShit();
		}
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

		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];

		var directions:Array<String> = ['left', 'down', 'up', 'right'];

		if (pressArray.contains(true))
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
							if (pressArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (pressArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									noteMiss(daNote.noteData);
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						if (pressArray[daNote.noteData])
							goodNoteHit(daNote);
						else {
							noteMiss(daNote.noteData);
						}
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							if (pressArray[daNote.noteData])
								goodNoteHit(coolNote);
							else 
								noteMiss(daNote.noteData);
						}
					}
				}
				else // regular notes?
				{
					if (pressArray[daNote.noteData])
						goodNoteHit(daNote);
					else 
						noteMiss(daNote.noteData);
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		if (holdArray.contains(true)) {
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote && daNote.strumTime <= Conductor.songPosition)
				{
					goodNoteHit(daNote);
				}
			});
		}
		else {
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.prevNote.isSustainNote && daNote.canBeHit && daNote.mustPress && !daNote.tooLate) {
					noteMiss(daNote.noteData);
					daNote.canBeHit = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
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
		if (!data.cpu)
			PlayState.instance.characters.get(data.character).playAnim('sing${['LEFT', 'DOWN', 'UP', 'RIGHT'][direction]}-miss', true);
		
		PlayState.instance.health -= 0.02;
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
			badNoteCheck();
		}
	}

	public function goodNoteHit(note:Note):Void
	{
		var swag:Array<String> = ['left', 'down', 'up', 'right'];
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;

			if (data != null && !data.cpu) {
				strumNotes.forEach(function(spr:SockitSprite)
				{	
					if (spr.ID == note.noteData) {
						spr.playAnim('confirm-static-' + swag[spr.ID]);
					}
				});
			}

			PlayState.instance.characters.get(data.character).playAnim('sing${swag[note.noteData].toUpperCase()}', true);

			if (!note.isSustainNote)
			{
				PlayState.instance.health += 0.02;
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			
			PlayState.instance.health += 0.04;
		}
		else {
			if (data != null && data.cpu) {
				strumNotes.forEach(function(spr:SockitSprite)
				{	
					if (spr.ID == note.noteData) {
						spr.playAnim('confirm-static-' + swag[spr.ID]);
					}
				});
			}

			PlayState.instance.characters.get(data.character).playAnim('sing${swag[note.noteData].toUpperCase()}', true);

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}
}