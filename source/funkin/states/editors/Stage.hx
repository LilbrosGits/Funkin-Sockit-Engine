package funkin.states.editors;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxColor;
import funkin.system.*;
import funkin.system.MusicBeat.MusicBeatSubState;
import funkin.ui.*;
import haxe.Json;

typedef StageData = {
    var animatedSprite:Array<AnimSprite>;
    var sprite:Array<Sprite>;
    var makeSprite:Array<CreateSprite>;
}

typedef Sprite = {
    image:String,
    positions:Array<Float>,
}

typedef AnimSprite = {
    image:String,
    frames:FlxFramesCollection, //i fought so hard for that lmao
    animations:AnimAdder,
    playAnimation:String,
    positions:Array<Float>,
}

typedef AnimAdder = {
    animationName:String,
    xmlTitle:String
}

typedef CreateSprite = {
    width:Int,
    height:Int,
    color:FlxColor,
    positions:Array<Float>,
}

class Stage extends MusicBeatSubState {
    var stageJSON:StageData;

    override public function new(stage:String) {
        super();
        stageJSON = Json.parse(FunkinPaths.stageJson(stage));

        for (i in stageJSON.sprite) {
            var sprite:FlxSprite = new FlxSprite(i.positions[0], i.positions[1]).loadGraphic(FunkinPaths.image(i.image));
            add(sprite);
        }

        for (i in stageJSON.animatedSprite) {
            var sprite:FlxSprite = new FlxSprite(i.positions[0], i.positions[1]);
            sprite.frames = FunkinPaths.sparrowAtlas(i.image);
            sprite.animation.addByPrefix(i.animations.animationName, i.animations.xmlTitle);
            sprite.animation.play(i.playAnimation);
            add(sprite);
        }

        for (i in stageJSON.makeSprite) {
            var sprite:FlxSprite = new FlxSprite(i.positions[0], i.positions[1]).makeGraphic(i.width, i.height, i.color);
            add(sprite);
        }
        super.create();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}