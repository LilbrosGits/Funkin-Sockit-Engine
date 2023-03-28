package funkin.system;

import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;

class FunkinPaths {
    public static var currentModDir:String = '';
    inline public static function getPath(file:String = '') {
        #if MODS_ENABLED
        if (OpenFlAssets.exists('mods/$currentModDir/$file'))
            return 'mods/$currentModDir/$file';
        #end
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
        return File.getContent(getPath(file));
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
    
    inline public static function stage(stage:String) {
        return getText('stages/$stage.json');
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

    inline public static function font(font:String) {
        return getPath('fonts/$font');
    }

    inline public static function script(scr:String) {
        return getPath('data/$scr');
    }

    inline public static function state(scr:String) {
        return getPath('states/$scr');
    }//couldve been one function but i alr spent to much time
}