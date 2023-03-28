package funkin.util;

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

    public static function getState(name:String, scriptVar:FunkinScript) {
        for (scr in FileSystem.readDirectory('assets/states/')) {
            if (scr.endsWith('.hx') || scr.endsWith('.hxs') || scr.endsWith('.hscript')) {
                if (scr.contains(name))
				    scriptVar.execute(FunkinPaths.getText(scr));
            }
        }
    }//prob gonna put dese together soon

    public static function listFromFile(file:String) {
        var listThing:Array<String> = [];

        listThing = File.getContent(file).trim().split('\n');
        
        for (i in 0...listThing.length) {
            listThing[i].trim();
        }
        
        return listThing;
    }
}