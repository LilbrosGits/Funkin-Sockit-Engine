package funkin.obj;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;
import funkin.system.Preferences;

typedef CharJSON = {
    graphic:String,
    idleAnim:String,
    confirmAnim:String,
    positions:Array<Float>,
    ?flipX:Bool,
    antialiasing:Bool,
    scale:Array<Float>
}

class MenuCharacter extends FlxSprite {
    public var json:CharJSON;
    public function new(x:Float, character:String = 'bf') {
        super(x);

        changeChar(character);
    }

    public function changeChar(character:String) {
        json = haxe.Json.parse(FunkinPaths.getText('images/UI/menus/storymenu/menucharacters/$character.json'));
        #if MODS_ENABLED
        if (FunkinPaths.exists('mods/${FunkinPaths.currentModDir}/images/UI/menus/storymenu/menucharacters/$character.json'))
            json = haxe.Json.parse(FunkinPaths.getText('mods/${FunkinPaths.currentModDir}/images/UI/menus/storymenu/menucharacters/$character.json'));
        #end
        offset.set(json.positions[0], json.positions[1]);
        scale.set(json.scale[0], json.scale[1]);
        if (json.flipX != null)
            flipX = json.flipX;
        
        frames = FunkinPaths.sparrowAtlas('UI/menus/storymenu/menucharacters/${json.graphic}');
        animation.addByPrefix('idle', json.idleAnim, 24, true);
        animation.addByPrefix('confirm', json.confirmAnim, 24, false);
        animation.play('idle');
        if (json.antialiasing)
            antialiasing = Preferences.antialiasing;
        else
            antialiasing = false;
    }
}