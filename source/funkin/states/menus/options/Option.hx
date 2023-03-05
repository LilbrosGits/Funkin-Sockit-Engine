package funkin.states.menus.options;

import flixel.FlxG;

class Option {
    public var name:String;
    public var type:String;
    public var id:String;
    public var value:Dynamic;

    public function new(name:String, id:String, type:String, value:Dynamic) {
        this.name = name;
        this.type = type;
        this.id = id;
        this.value = value;
    }
}