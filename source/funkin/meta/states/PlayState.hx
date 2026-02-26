package funkin.meta.states;

import funkin.obj.HUD;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.FlxG;
import audio.SockitMusic;
import funkin.obj.Strumline;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.obj.characters.Character;
import funkin.obj.Stage;
import funkin.data.Song;
import funkin.data.Song.SongData;

class PlayState extends GameState {
    public var song:SongData;
    public static var instance:PlayState;
    public static var editingEnabled:Bool = false;
    public var editorEnabled:Bool = false;
    public var stage:Stage;
    public var characters:Map<String, Character> = [];
    public var strumlineMap:Map<String, Strumline> = [];
    public var characterGrp:FlxTypedGroup<Character>;
    public var strumlineGrp:FlxTypedGroup<Strumline>;
    public var curStage:String = 'stage';
    public var inst:SockitMusic;
    public var vocals:Map<String, SockitMusic> = [];
    var startTimer:FlxTimer;
    public var camUI:FlxCamera;
    public var camGame:FlxCamera;
    public var camHUD:FlxCamera;
    public var hud:HUD;

    public function new() {
        super('PlayState');
        instance = this;
    }

    override public function create() {
        super.create();

        camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camUI.bgColor = FlxColor.TRANSPARENT;
        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camHUD.bgColor = FlxColor.TRANSPARENT;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);
        FlxG.cameras.add(camUI);

        instance.song = Song.loadSong('test');
        curStage = song.playData.stage;
        stage = new Stage(curStage);
        stage.script.set('curBeat', curBeat);
        stage.script.set('curStep', curStep);
        stage.script.set('Conductor', Conductor);
        stage.script.set('PlayState', instance);
        characterGrp = new FlxTypedGroup<Character>();
        strumlineGrp = new FlxTypedGroup<Strumline>();
        hud = new HUD();
        inst = new SockitMusic();
        inst.parseMusic(song.playData.inst);

        stage.cameras = [camGame];
        characterGrp.cameras = [camGame];
        strumlineGrp.cameras = [camHUD];
        hud.cameras = [camHUD];

        //add(stage);
        add(characterGrp);
        add(strumlineGrp);
        add(hud);
        stage.loadStage();
        loadCharacters();
        loadVocals();
        startCountdown();
    }

    override public function update(elapsed:Float) {
        Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);
    }

	function startCountdown():Void
	{
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
            for (char in characters.keys()) {
                characters.get(char).dance();
            }

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready.png', "set.png", "go.png"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3.ogg', 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[0]);
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.screenCenter();
                    ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2.ogg', 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[1]);
					set.scrollFactor.set();
					set.screenCenter();
                    set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1.ogg', 0.6);
				case 3:
                    loadStrumlines();
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[2]);
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
                    go.cameras = [camHUD];
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo.ogg', 0.6);
				case 4:
                    playSong();
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
    }

    public function loadCharacters() {
        for (i in song.playData.strumlines) {
            var character:Character = new Character();
            character.loadCharacterFile(i.character);
            character.setPosition(i.charPos[0], i.charPos[1]);
            characters.set(i.character, character);
            characterGrp.add(characters.get(i.character));
        }
    }

    public function loadStrumlines() {
        for (i in song.playData.strumlines) {
            var strumline:Strumline = new Strumline();
            strumline.loadStrumline(i, 'default');
            strumlineMap.set(i.character, strumline);
            strumlineGrp.add(strumline);
            strumline.generateSong(i, 0);
        }
    }

    public function loadVocals() {
        for (i in song.playData.strumlines) {
            var vocal:SockitMusic = new SockitMusic();
            vocal.parseAudio(i.strumlineAudio);
            vocals.set(i.strumlineAudio.name, vocal);
        }
    }

    public function playSong() {
        resyncVocals();
        inst.playMusic();
        for (i in vocals.keys()) {
            vocals.get(i).playAudio();
        }
    }

    public function pauseSong() {
        inst.pauseMusic();
        for (i in vocals.keys()) {
            vocals.get(i).pauseAudio();
        }
    }

    public function resyncVocals() {
        for (i in vocals.keys()) {
            vocals.get(i).time = FlxG.sound.music.time;
        }
    }
}