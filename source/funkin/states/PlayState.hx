package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import funkin.obj.*;
import funkin.system.*;
import funkin.ui.HUD;

class PlayState extends MusicBeat.MusicBeatState
{
	private var unaddedNotes:Array<Note> = [];
	public static var song:Song.SongData;
	var playerStrums:FlxTypedGroup<StaticNote>;
	var dadStrums:FlxTypedGroup<StaticNote>;
	var player1:Character;
	var player2:Character;
	var hud:HUD;
	var health:Float = 50;
	var notes:FlxTypedGroup<Note>;
	var vocals:FlxSound;
	var strumLine:FlxSprite;
	var loadedSong:Bool = false;
	var stage:Stage;

	override public function create()
	{
		song = Song.loadSong('bopeebo', 'normal');

		stage = new Stage('stage');
		add(stage);

		FlxG.camera.zoom = stage.data.cameraZoom;

		player2 = new Character(stage.data.dadPosition[0], stage.data.dadPosition[1], song.characters[0]);//dad
		add(player2);

		player1 = new Character(stage.data.boyfriendPosition[0], stage.data.boyfriendPosition[1], song.characters[1]);//bf
		add(player1);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		add(strumLine);

		playerStrums = new FlxTypedGroup<StaticNote>();
		add(playerStrums);

		dadStrums = new FlxTypedGroup<StaticNote>();
		add(dadStrums);

		hud = new HUD();
		add(hud);

		genNotes();
		genSong();

		persistentDraw = true;
		persistentUpdate = true;
		
		super.create();
	}

	override public function update(elapsed:Float)
	{
		Conductor.songPos = FlxG.sound.music.time;

		hud.health = health;

		super.update(elapsed);

		if (unaddedNotes[0] != null)
		{
			if (unaddedNotes[0].strumTime - Conductor.songPos < 1500)
			{
				var dunceNote:Note = unaddedNotes[0];
				notes.add(dunceNote);

				var index:Int = unaddedNotes.indexOf(dunceNote);
				unaddedNotes.splice(index, 1);
			}
		}

		if (vocals.time != FlxG.sound.music.time)
			resyncVocals();

		if (loadedSong) {
			notes.forEachAlive(function(note:Note) {
				note.y = (strumLine.y - (Conductor.songPos - note.strumTime) * (0.45 * FlxMath.roundDecimal(song.speed, 2)));

				if (note.susNote && note.hit)
				{
					if (note.y < -note.height)
					{
						note.active = false;
						note.visible = false;

						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
				else if (note.late || note.hit)
				{
					if (note.late && !note.susNote)
					{
						health -= 1;
					}

					note.active = false;
					note.visible = false;

					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				if (!note.mustHit && note.hit) {
					player2.sing(note.noteData, '', true);
					
					note.active = false;
					note.visible = false;

					note.kill();
					notes.remove(note, true);
					note.destroy();

					dadStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
				}

				if (note.prevNote.late || !note.prevNote.hit) {
					if (note.susNote) {
						note.canHit = false;
						//note.late = true;
					}
				}
			});
		}

		if (health >= 100)
			health = 100;
		if (health <= 0)
			health = 0;

		updateStrums();
		inputInit();
	}

	function updateStrums() {
		dadStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished && spr.animation.curAnim.name == 'confirm') {
					spr.animation.play('static');
				}

				if (spr.animation.curAnim.name == 'confirm')
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
	}

	override public function onBeat() {
		if (loadedSong)
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		
		player2.playAnim('idle');
		player1.playAnim('idle');

		if (beats % 8 == 7 && song.song == 'Bopeebo') {
			player1.playAnim('taunt');
		}

		hud.everyBeat();
		
		super.onBeat();
	}

	function genSong() {
		genStrums(0);
		genStrums(1);
		
		FlxG.sound.playMusic(FunkinPaths.inst(song.song));

		vocals = new FlxSound().loadEmbedded(FunkinPaths.voices(song.song));
		vocals.play();

		Conductor.songPos = FlxG.sound.music.time;
		Conductor.setBPM(song.bpm);
		resyncVocals();
	}

	function resyncVocals() {
		vocals.time = FlxG.sound.music.time;
	}

	function genNotes() {
		var songData = song;

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<Sec.SecData>;

		noteData = songData.sections;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			for (songNotes in section.notes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unaddedNotes.length > 0)
					oldNote = unaddedNotes[Std.int(unaddedNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.susLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var sustainLng:Float = swagNote.susLength;

				sustainLng = sustainLng / Conductor.stepCrochet;
				unaddedNotes.push(swagNote);

				for (susNote in 0...Math.floor(sustainLng))
				{
					oldNote = unaddedNotes[Std.int(unaddedNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unaddedNotes.push(sustainNote);

					sustainNote.mustHit = gottaHitNote;

					if (sustainNote.mustHit)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustHit = gottaHitNote;

				if (swagNote.mustHit)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		unaddedNotes.sort(sortByShit);

		loadedSong = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note)
	{
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	function onNoteHit(note:Note) {
		if (!note.hit)//its false here!!!! cause thats the default
		{
			player1.sing(note.noteData, '', true);

			health += 2; //same amount as miss cause fuck how imbalanced base game is

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.kill();
			notes.remove(note, true);
			note.destroy();	

			note.hit = true;
		}
	}

	function onNoteMiss(dir:Int) {
		health -= 2;
		player1.sing(dir, 'miss', true);
	}

	function inputInit() {
		var pArray:Array<Bool> = [
			FlxG.keys.justPressed.LEFT, 
			FlxG.keys.justPressed.DOWN, 
			FlxG.keys.justPressed.UP, 
			FlxG.keys.justPressed.RIGHT
		]; //da keys you press
		var hArray:Array<Bool> = [
			FlxG.keys.pressed.LEFT, 
			FlxG.keys.pressed.DOWN, 
			FlxG.keys.pressed.UP, 
			FlxG.keys.pressed.RIGHT
		]; //da keys you hold
		var rArray:Array<Bool> = [
			FlxG.keys.justReleased.LEFT, 
			FlxG.keys.justReleased.DOWN, 
			FlxG.keys.justReleased.UP, 
			FlxG.keys.justReleased.RIGHT
		]; //da keys you let go of haha

		if (hArray.contains(true) && loadedSong) {
			notes.forEach(function(note:Note) {
				if (note.susNote && note.canHit && note.mustHit && hArray[note.noteData])
					onNoteHit(note);
			});
		}

		if (pArray.contains(true) && loadedSong) {

			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canHit && daNote.mustHit && !daNote.late && !daNote.hit)
				{
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (possibleNotes.length > 0)
			{
				for (shit in 0...pArray.length)
				{ // if a direction is hit that shouldn't be
					if (pArray[shit] && !directionList.contains(shit))
						onNoteMiss(shit);
				}
				for (coolNote in possibleNotes)
				{
					if (pArray[coolNote.noteData])
						onNoteHit(coolNote);
				}
			}
			else
			{
				for (shit in 0...pArray.length)
					if (pArray[shit])
						onNoteMiss(shit);
			}
		}

		playerStrums.forEach(function(spr:StaticNote)
		{
			if (hArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!hArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});

		if (!pArray.contains(false)){
			var noKey = pArray.lastIndexOf(true);

			pArray[noKey] = false;
		}

		if (!hArray.contains(false)){
			var noKey = hArray.lastIndexOf(true);

			hArray[noKey] = false;
		}
	}

	function genStrums(player:Int) {
		for (i in 0...4)
		{
			var strumNote:StaticNote = new StaticNote(0, strumLine.y, i);

			if (player > 0)
				playerStrums.add(strumNote);
			else
				dadStrums.add(strumNote);

			strumNote.ID = i;

			strumNote.x += 50;
			strumNote.x += ((FlxG.width / 2) * player);

			strumNote.fixPositionings();
		}
	}
}
