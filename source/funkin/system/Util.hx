package funkin.system;

import flixel.FlxG;
import funkin.scripting.FunkinScript;
import lime.utils.Assets;
import sys.FileSystem;

using StringTools;

class Util {
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
    }
}