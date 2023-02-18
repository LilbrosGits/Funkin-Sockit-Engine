package funkin.obj;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;
import haxe.Json;

using StringTools;

typedef CharacterFile = {
    ?singAnims:Array<String>,
    ?defaultAnim:String,
    spriteSheet:String,
    ?flipX:Bool,
    ?flipY:Bool,
    animations:MasterAnim
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
    
    public function new(x:Float, y:Float, character:String = 'bf') {
        super(x, y);

        animOffsets = new Map<String, Array<Dynamic>>();

        char = character;

        charJSON = Json.parse(FunkinPaths.characterJson(character));

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

        if (char.startsWith('gf'))
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
        danced = !danced;

        if (danced)
            playAnim('danceRight');
        else
            playAnim('danceLeft');
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
    {
        animOffsets[name] = [x, y];
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}