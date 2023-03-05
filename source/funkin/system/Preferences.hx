package funkin.system;

import flixel.FlxG;

class Preferences {
    public static var downscroll:Bool = false;
    public static var antialiasing:Bool = true;

    public static function loadOptions() {
        if (FlxG.save.data.ds != null) {
            downscroll = FlxG.save.data.ds;
        }
        if (FlxG.save.data.aliasing != null) {
            antialiasing = FlxG.save.data.aliasing;
        }
    }

    public static function saveOptions() {
        if (FlxG.save.data.ds != null) {
            FlxG.save.data.ds = downscroll;
        }
        if (FlxG.save.data.aliasing != null) {
            FlxG.save.data.aliasing = antialiasing;
        }
    }
}