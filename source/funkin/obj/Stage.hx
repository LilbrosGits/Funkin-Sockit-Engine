package funkin.obj;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatSubState;
import funkin.system.Preferences;
import haxe.Json;

typedef File = {
    cameraZoom:Float,
    ?images:Array<ImageSprite>,
    ?createdSprites:Array<MakeSprite>,
    ?animatedSprites:Array<AnimSprite>,
    boyfriendPosition:Array<Float>,
    dadPosition:Array<Float>,
    gfPosition:Array<Float>
}

typedef ImageSprite = {
    image:String,
    positions:Array<Float>,
    ?scrollFactor:Array<Float>,
    ?active:Bool,
    ?angle:Float,
    ?color:Array<Int>,
    ?width:Int,
    ?height:Int,
    ?flipX:Bool,
    ?flipY:Bool,
    ?scale:Array<Float>,
    antialiasing:Bool,
}

typedef AnimSprite = {
    image:String,
    positions:Array<Float>,
    animations:Array<AnimThing>,
    ?scrollFactor:Array<Float>,
    ?active:Bool,
    ?angle:Float,
    ?color:Array<Int>,
    ?width:Int,
    ?height:Int,
    ?flipX:Bool,
    ?flipY:Bool,
    ?scale:Array<Float>,
    antialiasing:Bool,
}

typedef AnimThing = {
    name:String,
    prefix:String,
    framerate:Int,
    loop:Bool,
    defaultAnim:Bool
}

typedef MakeSprite = {
    color:Array<Int>,
    width:Int,
    height:Int,
    ?scrollFactor:Array<Float>,
    ?angle:Float,
    ?active:Bool,
    ?flipX:Bool,
    ?flipY:Bool,
    ?scale:Array<Float>,
    positions:Array<Float>,
}

class Stage extends MusicBeatSubState
{
    public var data:File;

    public var allSprGrp:FlxTypedGroup<FlxSprite>;
    
    public function new(stage:String){
        super();

        data = Json.parse(FunkinPaths.stage(stage));

        allSprGrp = new FlxTypedGroup<FlxSprite>();
        add(allSprGrp);

        if (data.images != null) {
            for (img in data.images) {
                var image:FlxSprite = new FlxSprite(img.positions[0], img.positions[1]).loadGraphic(FunkinPaths.image('stages/$stage/${img.image}'));
                if (img.angle != null)
                    image.angle = img.angle;
                if (img.width != null)
                    image.width = img.width;
                if (img.height != null)
                    image.height = img.height;
                if (img.color != null)
                    image.color = FlxColor.fromRGB(img.color[0], img.color[1], img.color[2]);
                if (img.scrollFactor != null)
                    image.scrollFactor.set(img.scrollFactor[0], img.scrollFactor[1]);
                if (img.active != null)
                    image.active = img.active;
                if (img.scale != null)
                    image.scale.set(img.scale[0], img.scale[1]);
                if (img.antialiasing != false)
                    image.antialiasing = Preferences.antialiasing;
                allSprGrp.add(image);
            }
        }

        if (data.createdSprites != null) {
            for (swag in data.createdSprites) {
                var swagSpr:FlxSprite = new FlxSprite(swag.positions[0], swag.positions[1]).makeGraphic(swag.width, swag.height, FlxColor.fromRGB(swag.color[0], swag.color[1], swag.color[2]));
                swagSpr.angle = swag.angle;
                if (swag.active != null)
                    swagSpr.active = swag.active;
                if (swag.scrollFactor != null)
                    swagSpr.scrollFactor.set(swag.scrollFactor[0], swag.scrollFactor[1]);
                if (swag.scale != null)
                    swagSpr.scale.set(swag.scale[0], swag.scale[1]);
                allSprGrp.add(swagSpr);
            }
        }

        if (data.animatedSprites != null) {
            for (animSpr in data.animatedSprites) {
                var anim:FlxSprite = new FlxSprite(animSpr.positions[0], animSpr.positions[1]);
                anim.frames = FunkinPaths.sparrowAtlas('stages/$stage/${animSpr.image}');
                for (i in 0...animSpr.animations.length) {
                    anim.animation.addByPrefix(animSpr.animations[i].name, animSpr.animations[i].prefix, animSpr.animations[i].framerate);
                    if (animSpr.animations[i].defaultAnim)
                        anim.animation.play(animSpr.animations[i].name);
                }
                if (animSpr.angle != null)
                    anim.angle = animSpr.angle;
                if (animSpr.width != null)
                    anim.width = animSpr.width;
                if (animSpr.height != null)
                    anim.height = animSpr.height;
                if (animSpr.color != null)
                    anim.color = FlxColor.fromRGB(animSpr.color[0], animSpr.color[1], animSpr.color[2]);
                if (animSpr.scrollFactor != null)
                    anim.scrollFactor.set(animSpr.scrollFactor[0], animSpr.scrollFactor[1]);
                if (animSpr.active != null)
                    anim.active = animSpr.active;
                if (animSpr.scale != null)
                    anim.scale.set(animSpr.scale[0], animSpr.scale[1]);
                if (animSpr.antialiasing != false)
                    anim.antialiasing = Preferences.antialiasing;
                allSprGrp.add(anim);
            }
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        allSprGrp.forEach(function(spr:FlxSprite) {
            spr.updateHitbox();
        });
    }
}