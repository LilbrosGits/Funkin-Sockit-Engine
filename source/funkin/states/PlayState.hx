package funkin.states;

import funkin.editors.StageEditor;
import funkin.scripting.GlobalScript;
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
import funkin.states.menus.StoryMenuState;
import funkin.system.*;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.ui.HUD;
import funkin.util.FunkinUtil;
import sys.FileSystem;

using StringTools;

class PlayState extends MusicBeatState
{
	private var unaddedNotes:Array<Note> = [];
	public static var storyList:Array<String> = [];
	public static var difficulty:String;
	public static var storyMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyDifficulty:Int = 0;
	public static var song:Song.SongData;
	var combo:Int = 0;
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
	public static var stage:Stage;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var camFollow:FlxObject;
	var swagScript:GlobalScript;
	var paused:Bool = false;
	var curStage:String = '';
	var finishedCountdown:Bool = false;
	var canPlay:Bool = false;
	public static var score:Int = 0;
	public static var misses:Int = 0;
	public static var accuracy:Float = 0.00;
	public static var totalHits:Float = 0;
	public static var totalPlayedNotes:Float = 0;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	
	override public function create()
	{
		FunkinPaths.clearMem();
		score = 0;
		misses = 0;
		accuracy = 0.00;

		swagScript = new GlobalScript('data/${song.song.toLowerCase()}');

		if (song == null)
			song = Song.loadSong('bopeebo', 'normal');

		curStage = song.stage;

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		/*if (FunkinPaths.exists('assets/scripts/script.hx'))
			swagScript.execute('assets/scripts/script.hx');*/
		
		swagScript.setVars('song', song);
		swagScript.setVars('generatedSong', loadedSong);
		swagScript.setVars('health', health);
		swagScript.setVars('unspawnedNotes', unaddedNotes);
		swagScript.setVars('Conductor', Conductor);
		swagScript.setVars('score', score);
		swagScript.setVars('misses', misses);
		swagScript.setVars('accuracy', accuracy);

		swagScript.executeScripts();
		
		swagScript.runGlobalFunc('onCreate', []);

		stage = new Stage(curStage);
		if (stage.scr != null) {
			stage.scr.executeFunc('onCreate', []);
			stage.scr.setVar('ui', hud);
			stage.scr.setVar('bfStrums', playerStrums);
			stage.scr.setVar('dadStrums', dadStrums);
			stage.scr.setVar('boyfriend', player1);
			stage.scr.setVar('dad', player2);
			stage.scr.setVar('gf', player3);
			stage.scr.setVar('stage', stage);
			stage.scr.setVar('camGame', camGame);
			stage.scr.setVar('camHUD', camHUD);
			stage.scr.setVar('camFollow', camFollow);
			stage.scr.setVar('paused', paused);
			stage.scr.setVar('finishedCountdown', finishedCountdown);
			stage.scr.setVar('loadedSong', loadedSong);
			stage.scr.setVar('song', song);
			stage.scr.setVar('generatedSong', loadedSong);
			stage.scr.setVar('health', health);
			stage.scr.setVar('unspawnedNotes', unaddedNotes);
			stage.scr.setVar('Conductor', Conductor);
			stage.scr.setVar('score', score);
			stage.scr.setVar('misses', misses);
			stage.scr.setVar('accuracy', accuracy);
		}
		add(stage);//NOTE: this dont gotta be here niggah!

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.1;

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.camera.zoom = stage.data.cameraZoom;

		player3 = new Character(stage.data.gfPosition[0], stage.data.gfPosition[1], song.characters[2]);//gf
		add(player3);

		player2 = new Character(stage.data.dadPosition[0], stage.data.dadPosition[1], song.characters[0]);//dad
		add(player2);

		player1 = new Character(stage.data.boyfriendPosition[0], stage.data.boyfriendPosition[1], song.characters[1]);//bf
		add(player1);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(player3.charJSON.camPos[0], player3.charJSON.camPos[1]);
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

		add(grpNoteSplashes);

		genSong();

		hud = new HUD();
		add(hud);

		swagScript.setVars('ui', hud);
		swagScript.setVars('bfStrums', playerStrums);
		swagScript.setVars('dadStrums', dadStrums);
		swagScript.setVars('boyfriend', player1);
		swagScript.setVars('dad', player2);
		swagScript.setVars('gf', player3);
		swagScript.setVars('stage', stage);
		swagScript.setVars('camGame', camGame);
		swagScript.setVars('camHUD', camHUD);
		swagScript.setVars('camFollow', camFollow);
		swagScript.setVars('paused', paused);
		swagScript.setVars('finishedCountdown', finishedCountdown);
		swagScript.setVars('loadedSong', loadedSong);

		startCountdown();

		grpNoteSplashes.cameras = [camHUD];
		hud.cameras = [camHUD];
		notes.cameras = [camHUD];
		playerStrums.cameras = [camHUD];
		dadStrums.cameras = [camHUD];
		strumLine.cameras = [camHUD];

		persistentDraw = true;
		persistentUpdate = true;
		
		super.create();

		swagScript.setVars('beats', beats);
		swagScript.setVars('steps', steps);
		if (stage.scr != null) {
			stage.scr.setVar('beats', beats);
			stage.scr.setVar('steps', steps);
		}

		swagScript.runGlobalFunc('onCreatePost', []);
		if (stage.scr != null)
			stage.scr.executeFunc('onCreatePost', []);
	}

	static function truncateFloat(number:Float, precision:Int):Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	override public function update(elapsed:Float)
	{
		Conductor.songPos = FlxG.sound.music.time;

		hud.health = health;

		swagScript.runGlobalFunc('onUpdate', [elapsed]);
		if (stage.scr != null)
			stage.scr.executeFunc('onUpdate', [elapsed]);

		super.update(elapsed);

		hud.scoreTxt = 'Score: $score • Misses: $misses • Accuracy: ${truncateFloat(accuracy, 2)}%';
		
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

		swagScript.runGlobalFunc('onUpdatePost', [elapsed]);
		if (stage.scr != null)
			stage.scr.executeFunc('onUpdatePost', [elapsed]);
	}

	function genScore(note:Note) {
		//var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPos);
		var noteScore:Int = 350;
		var rating:FlxSprite = new FlxSprite();
		var splash:Bool = true;
		var daRating:String = note.rating;

		switch(daRating) {
			case "shit":
				totalHits += 0.25;
				noteScore = -300;
				splash = false;
				health -= 0.1;
				combo = 0;
			case "bad":
				totalHits += 0.50;
				noteScore = 0;
				splash = false;
				health -= 0.06;
				combo--;
			case "good":
				totalHits += 0.75;
				noteScore = 200;
				splash = false;
				health += 0.04;
				combo++;
			case "sick":
				totalHits += 1;
				splash = true;
				health += 0.1;
				combo++;
		}
		
		if (splash)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(splash);
		}

		score += noteScore;

		rating.loadGraphic(FunkinPaths.image('UI/HUD/ratings/$daRating'));
		rating.screenCenter();
		rating.x = FlxG.width * 0.55 - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/HUD/ratings/combo'));
		comboSpr.screenCenter();
		comboSpr.x = FlxG.width * 0.55;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = true;
		comboSpr.updateHitbox();

		if (combo > 5) {
			add(comboSpr);
		}
		
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/HUD/ratings/num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = FlxG.width * 0.55 + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}
	public static function calculateRating(diff:Float, ?customSafeZone:Float):String
	{
		var ts = Conductor.milliFrames / 166;

		if (customSafeZone != null)
			ts = customSafeZone / 166;

		if (diff > 135 * ts)
			return "shit";
		else if (diff > 90 * ts)
			return "bad";
		else if (diff > 45 * ts)
			return "good";
		else if (diff < -45 * ts)
			return "good";
		else if (diff < -90 * ts)
			return "bad";
		else if (diff < -135 * ts)
			return "shit";
		return "sick";
	}

	function updateAccuracy() 
	{
		totalPlayedNotes += 1;
		accuracy = Math.max(0,totalHits / totalPlayedNotes * 100);
	}

	override public function onFocusLost() {
		//paused = true;
		swagScript.runGlobalFunc('onFocusLost', []);
		super.onFocusLost();
	}

	override public function onFocus() {
		//paused = false;
		swagScript.runGlobalFunc('onFocus', []);
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
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'));
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
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'));
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
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'));
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
					FlxG.sound.play(FunkinPaths.sound('countdown/${introSounds[swagCounter]}'));
				case 4:
					
			}

			swagCounter += 1;
		}, 5);
		
		swagScript.runGlobalFunc('onCountdown', [swagCounter]);
	}

	function updateVocals() {
		if (vocals.time != FlxG.sound.music.time)
			resyncVocals();
	}

	function updateCam() {
		if (PlayState.song.sections[Std.int(steps / 16)].mustHitSection) {
			camFollow.setPosition(player1.getMidpoint().x - 100, player1.getMidpoint().y - 100);
			camFollow.x += player1.charJSON.camPos[0];
			camFollow.y += player1.charJSON.camPos[1];
			swagScript.runGlobalFunc('onCamMove', ['bf']);
		}
		else
		{
			camFollow.setPosition(player2.getMidpoint().x + 150, player2.getMidpoint().y - 100);
			camFollow.x += player2.charJSON.camPos[0];
			camFollow.y += player2.charJSON.camPos[1];
			swagScript.runGlobalFunc('onCamMove', ['dad']);
		}

		if (loadedSong && PlayState.song.sections[Std.int(steps / 16)] != null) {
			FlxG.camera.zoom = FlxMath.lerp(stage.data.cameraZoom, FlxG.camera.zoom, FunkinUtil.adjustedFrame(0.95));
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
			player1.playAnim(player1.charJSON.defaultAnim);

		if (!player2.animation.curAnim.name.startsWith('sing'))
			player2.dance();

		player3.dance();

		if (beats % 8 == 7 && song.song == 'Bopeebo') {
			player1.playAnim('taunt');
		}
		
		swagScript.runGlobalFunc('onBeat', []);	

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

		swagScript.runGlobalFunc('onSongCreate', []);
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

		swagScript.setVars('notes', notes);

		swagScript.runGlobalFunc('onNoteLoad', []);
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
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPos);

			note.rating = calculateRating(noteDiff);
			
			if (!note.susNote) {
				combo += 1;
				genScore(note);
				updateAccuracy();
			}

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

			var dir = note.noteData;
			swagScript.runGlobalFunc('onNoteHit', [dir]);
		}
	}

	function onNoteMiss(dir:Int) {
		health -= 2;
		if (combo > 5 && player3.animOffsets.exists('sad'))
		{
			player3.playAnim('sad');
		}
		combo = 0;
		player1.sing(dir, 'miss');
		swagScript.runGlobalFunc('onNoteMiss', [dir]);
		misses++;
		score -= 50;
		updateAccuracy();
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
				if (note.prevNote.hit && note.susNote && note.canHit && note.mustHit && hArray[note.noteData])
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

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartEditor());
			FlxG.sound.music.stop();
			vocals.stop();
		}

		if (FlxG.keys.justPressed.NINE) {
			FlxG.switchState(new StageEditor());
			FlxG.sound.music.stop();
			vocals.stop();
		}

		if (FlxG.keys.justPressed.EIGHT) {
			FlxG.switchState(new CharacterEditor());
			FlxG.sound.music.stop();
			vocals.stop();
		}

		if (player1.holdTmr > 0.004 * Conductor.stepCrochet && !hArray.contains(true) && player1.animation.curAnim.name.startsWith('sing') && !player1.animation.curAnim.name.endsWith('miss')){
			player1.playAnim(player1.charJSON.defaultAnim);
		}
	}

	function onEnd() {
		if (storyMode) {
			if (storyList.length <= 0) {
				FlxG.switchState(new funkin.states.menus.StoryMenuState());

				Score.saveWeekScore(storyWeek, score, storyDifficulty);
			}
			else {
				storyList.remove(storyList[0]);
				song = Song.loadSong(storyList[0], difficulty);
				FlxG.switchState(new PlayState());
	
				Score.saveScore(song.song, score, storyDifficulty);
			}
		}
		else {
			FlxG.switchState(new funkin.states.menus.FreeplayMenu());
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
