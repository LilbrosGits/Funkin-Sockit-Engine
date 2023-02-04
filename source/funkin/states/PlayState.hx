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
	var playerStrums:Strumline;
	var dadStrums:Strumline;
	var player1:Character;
	var player2:Character;
	var hud:HUD;
	var health:Float = 50;
	var notes:FlxTypedGroup<Note>;
	private var unaddedNotes:Array<Note> = [];
	public static var song:Song.SongData;
	var vocals:FlxSound;
	var strumLine:FlxSprite;
	var loadedSong:Bool = false;

	override public function create()
	{
		song = Song.loadSong('bopeebo', 'normal');
		genSong();

		player2 = new Character(100, 100, song.characters[0]);//dad
		add(player2);

		player1 = new Character(770, 450, song.characters[1]);//bf
		add(player1);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		add(strumLine);

		playerStrums = new Strumline(0, strumLine.y, 1);
		add(playerStrums);

		dadStrums = new Strumline(0, strumLine.y, 0);
		add(dadStrums);

		hud = new HUD();
		add(hud);

		genNotes();

		persistentDraw = true;
		persistentUpdate = true;
		
		super.create();
	}

	function genSong() {
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

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

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

		// trace(unaddedNotes.length);
		// playerCounter += 1;

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
			});
		}
	}

	override public function onBeat() {
		if (loadedSong)
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		
		player2.playAnim('idle');
		player1.playAnim('idle');
		
		super.onBeat();
	}
}
