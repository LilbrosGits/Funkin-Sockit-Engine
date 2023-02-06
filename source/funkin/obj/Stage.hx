package funkin.obj;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatSubState;
import haxe.Json;

typedef File = {
    cameraZoom:Float,
    ?images:Array<ImageSprite>,
    ?createdSprites:Array<MakeSprite>,
    ?animatedSprites:Array<AnimSprite>,
    boyfriendPosition:Array<Float>,
    dadPosition:Array<Float>
}

typedef ImageSprite = {
    image:String,
    positions:Array<Float>,
    ?scale:Array<Float>,
    ?active:Bool,
    ?setGraphicSize:Array<Float>,
    ?angle:Float,
    ?color:Array<Int>,
    ?width:Int,
    ?height:Int,
    antialiasing:Bool,
}

typedef AnimSprite = {
    image:String,
    positions:Array<Float>,
    animations:Array<AnimThing>,
    ?scale:Array<Float>,
    ?active:Bool,
    ?setGraphicSize:Array<Float>,
    ?angle:Float,
    ?color:Array<Int>,
    ?width:Int,
    ?height:Int,
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
    ?angle:Float,
    ?active:Bool,
    ?setGraphicSize:Array<Float>,
    positions:Array<Float>,
}

class Stage extends MusicBeatSubState
{
    public var data:File;
    
    public function new(stage:String){
        super();

        data = Json.parse(FunkinPaths.stage(stage));

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
                if (img.scale != null)
                    image.scale.set(img.scale[0], img.scale[1]);
                if (img.setGraphicSize != null)
                    image.setGraphicSize(Std.int(image.width * img.setGraphicSize[0]), Std.int(image.height * img.setGraphicSize[1]));
                if (img.active != null)
                    image.active = img.active;
                add(image);
            }
        }

        if (data.createdSprites != null) {
            for (swag in data.createdSprites) {
                var swagSpr:FlxSprite = new FlxSprite(swag.positions[0], swag.positions[1]).makeGraphic(swag.width, swag.height, FlxColor.fromRGB(swag.color[0], swag.color[1], swag.color[2]));
                swagSpr.angle = swag.angle;
                if (swag.setGraphicSize != null)
                    swagSpr.setGraphicSize(Std.int(swagSpr.width * swag.setGraphicSize[0]), Std.int(swagSpr.height * swag.setGraphicSize[1]));
                if (swag.active != null)
                    swagSpr.active = swag.active;
                add(swagSpr);
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
                if (animSpr.scale != null)
                    anim.scale.set(animSpr.scale[0], animSpr.scale[1]);
                if (animSpr.setGraphicSize != null)
                    anim.setGraphicSize(Std.int(anim.width * animSpr.setGraphicSize[0]), Std.int(anim.height * animSpr.setGraphicSize[1]));
                if (animSpr.active != null)
                    anim.active = animSpr.active;
                add(anim);
            }
        }
    }
}