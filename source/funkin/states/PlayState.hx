package funkin.states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkin.editors.CharacterEditor;
import funkin.editors.ChartEditor;
import funkin.obj.*;
import funkin.scripting.FunkinScript;
import funkin.system.*;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.ui.HUD;
import funkin.util.FunkinUtil;
import sys.FileSystem;

using StringTools;

class PlayState extends MusicBeatState
{
	private var unaddedNotes:Array<Note> = [];
	public static var storySongs:Array<String> = [];
	public static var song:Song.SongData;
	var playerStrums:FlxTypedGroup<StaticNote>;
	var dadStrums:FlxTypedGroup<StaticNote>;
	var player1:Character;
	var player2:Character;
	var player3:Character;
	var hud:HUD;
	var health:Float = 50;
	var notes:FlxTypedGroup<Note>;
	var vocals:FlxSound;
	var strumLine:FlxSprite;
	var loadedSong:Bool = false;
	var stage:Stage;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var camFollow:FlxObject;
	var swagScript:FunkinScript;
	var paused:Bool = false;
	var finishedCountdown:Bool = false;
	var canPlay:Bool = false;
	public static var score:Int = 0;
	public static var misses:Int = 0;
	public static var accuracy:Float = 1;
	
	override public function create()
	{
		score = 0;
		misses = 0;
		accuracy = 0;

		swagScript = new FunkinScript();

		if (song == null)
			song = Song.loadSong('bopeebo', 'normal');

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		/*if (FunkinPaths.exists(FunkinPaths.script('${song.song.toLowerCase()}/')))
			swagScript.execute(FunkinPaths.script('${song.song.toLowerCase()}/script'));*/

		for (scr in FileSystem.readDirectory('assets/data/${song.song.toLowerCase()}/')) {
            if (scr.endsWith('.hx') || scr.endsWith('.hxs') || scr.endsWith('.hscript')) {
				swagScript.execute(FunkinPaths.getText('data/${song.song.toLowerCase()}/$scr'));
            }
        }
		
		swagScript.setVar('song', song);
		swagScript.setVar('generatedSong', loadedSong);
		swagScript.setVar('health', health);
		swagScript.setVar('unspawnedNotes', unaddedNotes);
		swagScript.setVar('Conductor', Conductor);
		
		swagScript.executeFunc('onCreate', []);

		stage = new Stage('stage');
		add(stage);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.camera.zoom = stage.data.cameraZoom;

		player3 = new Character(stage.data.gfPosition[0], stage.data.gfPosition[1], song.characters[2]);//gf
		add(player3);

		player2 = new Character(stage.data.dadPosition[0], stage.data.dadPosition[1], song.characters[0]);//dad
		add(player2);

		player1 = new Character(stage.data.boyfriendPosition[0], stage.data.boyfriendPosition[1], song.characters[1]);//bf
		add(player1);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(player3.getMidpoint().x - 100, player3.getMidpoint().y - 100);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, FunkinUtil.adjustedFrame(0.04));
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (Preferences.downscroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		playerStrums = new FlxTypedGroup<StaticNote>();
		add(playerStrums);

		dadStrums = new FlxTypedGroup<StaticNote>();
		add(dadStrums);

		genSong();

		hud = new HUD();
		add(hud);

		swagScript.setVar('ui', hud);
		swagScript.setVar('bfStrums', playerStrums);
		swagScript.setVar('dadStrums', dadStrums);
		swagScript.setVar('boyfriend', player1);
		swagScript.setVar('dad', player2);
		swagScript.setVar('gf', player3);
		swagScript.setVar('stage', stage);
		swagScript.setVar('camGame', camGame);
		swagScript.setVar('camHUD', camHUD);
		swagScript.setVar('camFollow', camFollow);

		startCountdown();

		hud.cameras = [camHUD];
		notes.cameras = [camHUD];
		playerStrums.cameras = [camHUD];
		dadStrums.cameras = [camHUD];
		strumLine.cameras = [camHUD];

		persistentDraw = true;
		persistentUpdate = true;
		
		super.create();

		swagScript.setVar('beats', beats);
		swagScript.setVar('steps', steps);

		swagScript.executeFunc('onCreatePost', []);
	}

	override public function update(elapsed:Float)
	{
		Conductor.songPos = FlxG.sound.music.time;

		hud.health = health;
		
		hud.scoreTxt = 'Score: $score • Misses: $misses • Accuracy: $accuracy';

		swagScript.executeFunc('onUpdate', [elapsed]);

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

		if (loadedSong && finishedCountdown) {
			notes.forEachAlive(function(note:Note) {
				if (Preferences.downscroll)
					note.y = (strumLine.y - (Conductor.songPos - note.strumTime) * (-0.45 * FlxMath.roundDecimal(song.speed, 2)));
				else
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
						if (Preferences.ghostTapping)
							onNoteMiss(note.noteData);
						else {
							health -= 1;
							misses++;
						}
					}

					note.active = false;
					note.visible = false;

					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				if (!note.mustHit && note.hit) {
					player2.sing(note.noteData, '');
					
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

					player2.holdTmr = 0;
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

		if (health <= 0) {
			paused = true;
			
			persistentUpdate = false;
			persistentDraw = true;

			vocals.stop();
			FlxG.sound.music.stop();
			camHUD.visible = false;

			openSubState(new GameOverSubState(player1.getScreenPosition().x, player1.getScreenPosition().y));
		}

		updateStrums();
		if (canPlay)
			inputInit();
		updateVocals();
		updateCam();

		swagScript.executeFunc('onUpdatePost', [elapsed]);
	}

	function genScore(note:Note) {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPos);
		var noteScore:Int = 200;
		var swag:Float = 1;

		if (noteDiff > Conductor.milliFrames * 0.9)
		{
			swag = 0.05;
			noteScore = 10;
		}
		else if (noteDiff > Conductor.milliFrames * 0.75)
		{
			swag = 0.1;
			noteScore = 50;
		}
		else if (noteDiff > Conductor.milliFrames * 0.2)
		{
			swag = 0.5;
			noteScore = 100;
		}

		if (!note.susNote)
			accuracy += swag;

		score += noteScore;
	}

	override public function onFocusLost() {
		//paused = true;
		swagScript.executeFunc('onFocusLost', []);
		super.onFocusLost();
	}

	override public function onFocus() {
		//paused = false;
		swagScript.executeFunc('onFocus', []);
		resyncVocals();
		
		super.onFocus();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.play();
				vocals.play();
				resyncVocals();
			}
			paused = false;
		}

		super.closeSubState();
	}

	function startCountdown():Void {
		var introAssets:Array<String> = ['', 'ready', 'set', 'go'];
		var introSounds:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];
		var swagCounter:Int = 0;

		Conductor.songPos = 0;
		Conductor.songPos -= Conductor.crochet * 5;

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/HUD/countdown/${introAssets[swagCounter]}'));
					ready.scrollFactor.set();
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/HUD/countdown/${introAssets[swagCounter]}'));
					set.scrollFactor.set();
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/HUD/countdown/${introAssets[swagCounter]}'));
					go.scrollFactor.set();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
							startSong();
							canPlay = true;
						}
					});
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'), 0.6);
				case 4:
					
			}

			swagCounter += 1;
		}, 5);
		
		swagScript.executeFunc('onCountdown', [swagCounter]);
	}

	function updateVocals() {
		if (vocals.time != FlxG.sound.music.time)
			resyncVocals();
	}

	//PUT THE KETCHUP UNDER THE TOILET SEAT IN FIRST PERIOD!!

	function updateCam() {
		if (PlayState.song.sections[Std.int(steps / 16)].mustHitSection) {
			camFollow.setPosition(player1.getMidpoint().x - 100, player1.getMidpoint().y - 100);
			swagScript.executeFunc('onCamMove', ['bf']);
		}
		else
		{
			camFollow.setPosition(player2.getMidpoint().x + 150, player2.getMidpoint().y - 100);
			swagScript.executeFunc('onCamMove', ['dad']);
		}

		if (loadedSong && PlayState.song.sections[Std.int(steps / 16)] != null) {
			FlxG.camera.zoom = FlxMath.lerp(1.05, FlxG.camera.zoom, FunkinUtil.adjustedFrame(0.95));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FunkinUtil.adjustedFrame(0.95));
		}
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

		playerStrums.forEach(function(spr:StaticNote)
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
		
		if (!player1.animation.curAnim.name.startsWith('sing'))
			player1.playAnim('idle');

		if (!player2.animation.curAnim.name.startsWith('sing'))
			player2.dance();

		player3.dance();

		if (beats % 8 == 7 && song.song == 'Bopeebo') {
			player1.playAnim('taunt');
		}
		
		swagScript.executeFunc('onBeat', []);	

		hud.everyBeat();

			
		if (FlxG.camera.zoom < 1.35 && beats % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		
		super.onBeat();
	}

	function genSong() {
		genStrums(0);
		genStrums(1);
		genNotes();

		vocals = new FlxSound().loadEmbedded(FunkinPaths.voices(song.song));
		FlxG.sound.list.add(vocals);

		Conductor.setBPM(song.bpm);

		swagScript.executeFunc('onSongCreate', []);
	}

	function startSong() {
		resyncVocals();
		vocals.play();
		FlxG.sound.playMusic(FunkinPaths.inst(song.song));
		FlxG.sound.music.onComplete = onEnd;
		finishedCountdown = true;
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

		swagScript.setVar('notes', notes);

		swagScript.executeFunc('onNoteLoad', []);
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
			player1.sing(note.noteData, '');

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

			genScore(note);

			var dir = note.noteData;
			swagScript.executeFunc('onNoteHit', [dir]);
		}
	}

	function onNoteMiss(dir:Int) {
		health -= 2;
		player1.sing(dir, 'miss');
		swagScript.executeFunc('onNoteMiss', [dir]);
		misses++;
		score -= 50;
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
			player1.holdTmr = 0;

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
					if (pArray[shit] && !directionList.contains(shit) && !Preferences.ghostTapping)
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
					if (pArray[shit] && !Preferences.ghostTapping)
						onNoteMiss(shit);
			}
		}

		playerStrums.forEach(function(spr:StaticNote)
		{
			if (pArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
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

		if (FlxG.keys.justPressed.ENTER) {
			paused = true;
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new funkin.states.PauseSubState());
		}

		if (FlxG.keys.justPressed.F1) {
			FlxG.switchState(new PlayState());
			FlxG.sound.music.stop();
			vocals.stop();
		}

		if (FlxG.keys.justPressed.F2) {
			FlxG.switchState(new CharacterEditor());
			FlxG.sound.music.stop();
			vocals.stop();
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartEditor());
			FlxG.sound.music.stop();
			vocals.stop();
		}

		if (player1.holdTmr > 0.004 * Conductor.stepCrochet && !hArray.contains(true) && player1.animation.curAnim.name.startsWith('sing') && !player1.animation.curAnim.name.endsWith('miss')){
			player1.playAnim('idle');
		}
	}

	function onEnd() {
		song.song = storySongs[0];
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
