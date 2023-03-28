package funkin.states.menus.options;

import flixel.FlxG;
import funkin.system.Preferences;

class Option {
    public var name:String;
    public var type:String;
    public var id:String;
    public var value:Dynamic;
    public var scrollSpeed:Float;
    public var min:Float;
    public var max:Float;
    public var onChange:Void -> Void = null;

    public function new(name:String, id:String, type:String, ?scrollSpeed:Float = 1, ?min:Float = 0, ?max:Float = 1) {
        this.name = name;
        this.type = type;
        this.id = id;
        this.value = Reflect.getProperty(Preferences, id);
        if (type != 'bool') {
            this.scrollSpeed = scrollSpeed;
            this.min = min;
            this.max = max;
        }
    }
}