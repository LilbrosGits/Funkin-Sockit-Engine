package funkin.obj;

import cpp.abi.Abi;
import flixel.FlxSprite;
import funkin.system.FunkinPaths;
import funkin.system.Preferences;
import haxe.Json;

using StringTools;

typedef CharacterFile = {
    ?singAnims:Array<String>,
    ?defaultAnim:String,
    ?danceIdle:Bool,
    spriteSheet:String,
    ?flipX:Bool,
    ?flipY:Bool,
    camPos:Array<Float>,
    animations:MasterAnim,
    antialiasing:Bool
}

typedef MasterAnim = {
    ?indiciesAnim:Array<IndiciesAnim>,
    ?prefixAnim:Array<PrefixAnim>
}

typedef PrefixAnim = {
    name:String,
    xmlName:String,
    offsets:Array<Float>,
    ?fr:Int,
    ?loop:Bool,
    ?flipX:Bool,
    ?flipY:Bool
}

typedef IndiciesAnim = {
    name:String,
    xmlName:String,
    indices:Array<Int>,
    offsets:Array<Float>,
    ?fr:Int,
    ?loop:Bool,
    ?flipX:Bool,
    ?flipY:Bool
}


class Character extends FlxSprite {
    public static var forceIdle:Bool = false;

    public var animOffsets:Map<String, Array<Dynamic>>;

    public var charJSON:CharacterFile;

    public var char:String;

    public var holdTmr:Float = 0;
    
    public function new(x:Float, y:Float, character:String = 'bf') {
        super(x, y);

        animOffsets = new Map<String, Array<Dynamic>>();

        char = character;

        charJSON = Json.parse(FunkinPaths.characterJson(character));

        #if MODS_ENABLED
        if (FunkinPaths.exists('mods/${FunkinPaths.currentModDir}/characters/$character.json'))
            charJSON = haxe.Json.parse(FunkinPaths.getText('mods/${FunkinPaths.currentModDir}/characters/$character.json'));
        #end

        frames = FunkinPaths.sparrowAtlas(charJSON.spriteSheet);

        if (charJSON.animations.prefixAnim != null) {
            for (swag in charJSON.animations.prefixAnim) {
                animation.addByPrefix(swag.name, swag.xmlName, swag.fr, swag.loop, swag.flipX, swag.flipY);
                addOffset(swag.name, swag.offsets[0], swag.offsets[1]);
            }
        }
        
        if (charJSON.animations.indiciesAnim != null) {
            for (indiswag in charJSON.animations.indiciesAnim) {
                if (indiswag.indices.length > 0){
                    animation.addByIndices(indiswag.name, indiswag.xmlName, indiswag.indices, "", indiswag.fr, indiswag.loop, indiswag.flipX, indiswag.flipY);
                }
                addOffset(indiswag.name, indiswag.offsets[0], indiswag.offsets[1]);
            }
        }

        playAnim(charJSON.defaultAnim);

        if (charJSON.antialiasing != false) {
            charJSON.antialiasing = Preferences.antialiasing;
        }
        antialiasing = charJSON.antialiasing;
    }

    public var danced:Bool;

    public function playAnim(anim:String, force:Bool = false, reverse:Bool = false, frame:Int = 0) {
        animation.play(anim, force, reverse, frame);

		var daOffset = animOffsets.get(anim);
		if (animOffsets.exists(anim))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

        if (charJSON.danceIdle)
        {
            if (anim == 'singLEFT')
            {
                danced = true;
            }
            else if (anim == 'singRIGHT')
            {
                danced = false;
            }

            if (anim == 'singUP' || anim == 'singDOWN')
            {
                danced = !danced;
            }
        }
    }

    public function sing(dir:Int, altAnim:String = '') {
        playAnim(charJSON.singAnims[dir] + altAnim, true);
    }

    public function dance() {
        if (charJSON.danceIdle) {
            danced = !danced;

            if (danced)
                playAnim('danceRight');
            else
                playAnim('danceLeft');
        }
        else
            playAnim(charJSON.defaultAnim);
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
    {
        animOffsets[name] = [x, y];
    }

    override public function update(elapsed:Float) {
        if (!char.startsWith('bf')) {
            if (animation.curAnim.name.startsWith('sing'))
                holdTmr += elapsed;

            var dadJunk:Float = 4;

            if (char == 'dad')
                dadJunk = 6.1;

            if (holdTmr >= funkin.system.Conductor.stepCrochet * dadJunk * 0.001){
                dance();
                holdTmr = 0;
            }
        }
        else {
            if (animation.curAnim.name.startsWith('sing'))
                {
                    holdTmr += elapsed;
                }
                else
                    holdTmr = 0;
        }
        super.update(elapsed);
    }
}