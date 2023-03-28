package funkin.system;

import flixel.FlxG;
import funkin.states.menus.options.OptionsList;

class Preferences {
    public static var downscroll:Bool = false;
    public static var antialiasing:Bool = true;
    public static var ghostTapping:Bool = false;
    public static var fps:Int = 60;

    public static function loadOptions() {
        if (FlxG.save.data.ds != null) {
            downscroll = FlxG.save.data.ds;
        }
        if (FlxG.save.data.aliasing != null) {
            antialiasing = FlxG.save.data.aliasing;
        }
        if (FlxG.save.data.gt != null) {
            ghostTapping = FlxG.save.data.gt;
        }
        if (FlxG.save.data.fps != null) {
            fps = FlxG.save.data.fps;
        }
    }

    public static function saveOptions() {
        FlxG.save.data.ds = downscroll;
        FlxG.save.data.aliasing = antialiasing;
        FlxG.save.data.gt = ghostTapping;
        FlxG.save.data.fps = fps;
        FlxG.save.flush();
    }
}