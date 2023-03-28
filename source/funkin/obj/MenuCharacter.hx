package funkin.obj;

import flixel.FlxSprite;

typedef CharJSON = {
    graphic:String,
    animation:String,
}

class MenuCharacter extends FlxSprite {
    public function new(x:Float, y:Float) {
        super(x, y);
    }
}