package funkin.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.obj.Character;
import funkin.system.Conductor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatSubState;

class GameOverSubState extends MusicBeatSubState {
    var deadMF:Character;
    var camFollow:FlxObject;
    var ded:Bool = false;
    var bg:FlxSprite;

    public function new (x:Float, y:Float) {
        super();
        if (FlxG.sound.music != null) {
            FlxG.sound.music.stop();
            FlxG.sound.play(FunkinPaths.sound('fnf_loss_sfx'));
        }
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        add(bg);
        deadMF = new Character(x, y, 'bf-dead');
        add(deadMF);

        deadMF.playAnim('dead');
        camFollow = new FlxObject(deadMF.getGraphicMidpoint().x, deadMF.getGraphicMidpoint().y, 1, 1);
        add(camFollow);
        
        Conductor.songPos = 0;
        Conductor.setBPM(100);

        FlxG.camera.scroll.set();
		FlxG.camera.target = null;
    }

    override public function onBeat() {
        if (ded) {
            deadMF.playAnim('deathTwitch');
        }
        super.onBeat();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        if (deadMF.animation.curAnim.name == 'dead' && deadMF.animation.curAnim.curFrame == 12)
        {
            FlxG.camera.follow(camFollow, LOCKON, 0.01);
        }

        if (deadMF.animation.curAnim.name == 'dead' && deadMF.animation.curAnim.finished) {
            deadMF.playAnim('deathTwitch');
            if (!FlxG.sound.music.playing)
                FlxG.sound.playMusic(FunkinPaths.music('gameOver'));
            ded = true;
        }

        if (FlxG.keys.justPressed.ENTER && ded) {
            ded = false;
			deadMF.playAnim('retry', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(FunkinPaths.music('gameOverEnd'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxG.switchState(new PlayState());
				});
			});
        }

        if (FlxG.sound.music.playing)
        {
            Conductor.songPos = FlxG.sound.music.time;
        }
    }
}