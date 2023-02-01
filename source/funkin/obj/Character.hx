package funkin.obj;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;

class Character extends FlxSprite {
    public static var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
    public static var forceIdle:Bool = false;
    
    public function new(x:Float, y:Float, character:String = 'bf') {
        super(x, y);

        switch(character) {
            case 'bf':
                frames = FunkinPaths.sparrowAtlas('characters/BOYFRIEND');
                animation.addByPrefix('idle', 'BF idle dance', 24, false);
                animation.addByPrefix('singLEFT', 'BF NOTE LEFT', 24, false);
                animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT', 24, false);
                animation.addByPrefix('singUP', 'BF NOTE UP', 24, false);
                animation.addByPrefix('singDOWN', 'BF NOTE DOWN', 24, false);
                playAnim('idle');
            case 'dad':
                frames = FunkinPaths.sparrowAtlas('characters/DADDY_DEAREST');
                animation.addByPrefix('idle', 'Dad idle dance', 24, false);
                animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
                animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
                animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
                animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
                playAnim('idle');
        }
    }

    public function playAnim(anim:String, forceIdleAnim:Bool = false, force:Bool = false, reverse:Bool = false, frame:Int = 0) {
        animation.play(anim, force, reverse, frame);

        forceIdle = forceIdleAnim;
    }

    public function sing(dir:Int, altAnim:Bool = false, forceIdleAnim:Bool = false) {

        if (altAnim)
            playAnim('${singAnims[dir]}-alt', forceIdleAnim, true);
        else
            playAnim(singAnims[dir], forceIdleAnim, true);
    }

    override public function update(elapsed:Float) {
        if (animation.curAnim.name != 'idle' && animation.finished && !forceIdle){
            playAnim('idle');
        }
        super.update(elapsed);
    }
}