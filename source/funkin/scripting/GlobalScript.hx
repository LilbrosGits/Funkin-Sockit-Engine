package funkin.scripting;

import funkin.system.FunkinPaths;
import flixel.group.FlxGroup.FlxTypedGroup;
import sys.FileSystem;

using StringTools;

class GlobalScript {
    public var globalScripts:Array<FunkinScript> = [];
    public var globalPaths:Array<String> = [];
    public var path:String = '';

    public function new(path:String) {
        globalScripts = [];
        this.path = path;
		for (scr in FileSystem.readDirectory('assets/$path/')) {
            if (scr.endsWith('.hx') || scr.endsWith('.hxs') || scr.endsWith('.hscript')) {
                globalPaths.push('$path/$scr');
                trace('assets/$path/$scr');
				globalScripts.push(new FunkinScript());
            }
        }
    }

    public function executeScripts() {
        for (i in 0...globalScripts.length) {
            globalScripts[i].execute(FunkinPaths.getText(globalPaths[i]));
        }
    }

    public function runGlobalFunc(func:String, para:Array<Dynamic>) {
        for (i in 0...globalScripts.length) {
            globalScripts[i].executeFunc(func, para);
        }
    }

    public function setVars(name:String, val:Dynamic) {
		for (i in 0...globalScripts.length) {
            globalScripts[i].setVar(name, val);
        }
    }
}