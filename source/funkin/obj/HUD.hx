package funkin.obj;

import funkin.meta.states.PlayState;
import assets.Paths;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import scripts.SockitScript;
import scripts.SockitScriptGroup;

class HUD extends FlxTypedGroup<FlxBasic> {
    public var script:SockitScriptGroup;

    public function new(hudName:String = 'sockit') {
        super();
        script = new SockitScriptGroup('UI/HUD/$hudName');
        script.set('PlayState', PlayState);
		script.set('add', add);
		script.set('remove', remove);
    }

    public function loadHUD() {
        script.execute();
        script.call('onLoad',  []);
    }

    public function call(func:String, arg:Array<Dynamic>) {
        script.call(func, arg);
    }
}