package funkin.util;

import funkin.system.Preferences;
import flixel.FlxG;
import funkin.scripting.FunkinScript;
import funkin.system.FunkinPaths;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class FunkinUtil {
    public static var difficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
    
	public static function adjustedFrame(input:Float) {
        return input * (60 / FlxG.drawFramerate);
    } //fix shit getting faster with higher framerates unlike kade engine

    public static function getScript(path:String, scriptVar:FunkinScript) {
        for (scr in FileSystem.readDirectory(path)) {
            if (scr.endsWith('.hx') || scr.endsWith('.hxs') || scr.endsWith('.hscript')) {
				scriptVar.execute(FunkinPaths.getText(scr));
            }
        }
    }

    public static function listFromFile(file:String) {
        var listThing:Array<String> = [];

        listThing = File.getContent(file).trim().split('\n');
        
        for (i in 0...listThing.length) {
            listThing[i].trim();
        }
        
        return listThing;
    }
    public static function listFromFolder(file:String, ?exc:String) {
        var list:Array<String> = [];
        for (i in FileSystem.readDirectory(file)){
            list.push(i.replace(exc, ''));
        }
        return list;
    }

    public static function bound(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

    public static function resetMenuMusic() {
        if (FlxG.sound.music == null)
            return FlxG.sound.playMusic(FunkinPaths.music('freakyMenu'));
        else
            return FlxG.sound.playMusic(FunkinPaths.music('freakyMenu'));
    }
}