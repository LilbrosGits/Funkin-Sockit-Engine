package funkin.system;

import flixel.FlxG;

class Preferences {
    public static var downscroll:Bool = false;
    public static var antialiasing:Bool = true;
    public static var ghostTapping:Bool = false;
    public static var fps:Int = 60;
    public static var cbf:String = 'Test1';
    public static var safeZoneOffset:Float = 10;
    public static var masterVol:Float = 1;

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
        if (FlxG.save.data.cbf != null) {
            cbf = FlxG.save.data.cbf;
        }
        if (FlxG.save.data.safeZoneOffset != null) {
            safeZoneOffset = FlxG.save.data.safeZoneOffset;
        }
        if (FlxG.save.data.masterVol != null) {
            masterVol = FlxG.save.data.masterVol;
        }
    }

    public static function saveOptions() {
        FlxG.save.data.ds = downscroll;
        FlxG.save.data.aliasing = antialiasing;
        FlxG.save.data.gt = ghostTapping;
        FlxG.save.data.fps = fps;
        FlxG.save.data.cbf = cbf;
        FlxG.save.data.safeZoneOffset = safeZoneOffset;
        FlxG.save.data.masterVol = masterVol;
        FlxG.save.flush();
    }
}