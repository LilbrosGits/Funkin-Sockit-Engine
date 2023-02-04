package funkin.system;

import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

class FunkinPaths {
    inline public static function getPath(file:String = '') {
        return 'assets/$file';
    }

    inline public static function exists(file:String) {
        if (OpenFlAssets.exists(file))
            return true;
        else
            return false;
    }

    inline public static function image(img:String) {
        return getPath('images/$img.png');
    }

    inline public static function txt(txt:String) {
        return getPath('data/$txt.txt');
    }

    inline public static function getText(file:String) {
        return Assets.getText(getPath(file));
    }

    inline public static function songJson(song:String, diff:String) {
        return getText('data/${song.toLowerCase()}/${diff.toLowerCase()}.json');
    }

    inline public static function characterJson(char:String) {
        return getText('characters/$char.json');
    }

    inline public static function json(json:String) {
        return getText('data/$json.json');
    }

    inline public static function sparrowAtlas(sprAtlas:String) {
        return FlxAtlasFrames.fromSparrow(getPath('images/$sprAtlas.png'), getPath('images/$sprAtlas.xml'));
    }

    inline public static function packerAtlas(packerAtlas:String) {
        return FlxAtlasFrames.fromSpriteSheetPacker(getPath('images/$packerAtlas.png'), getPath('images/$packerAtlas.txt'));
    }

    inline public static function sound(snd:String) {
        return getPath('sounds/$snd.ogg');
    }

    inline public static function music(song:String) {
        return getPath('music/$song.ogg');
    }

    inline public static function inst(song:String) {
        return getPath('songs/${song.toLowerCase()}/Inst.ogg');
    }

    inline public static function voices(song:String) {
        return getPath('songs/${song.toLowerCase()}/Voices.ogg');
    }
}