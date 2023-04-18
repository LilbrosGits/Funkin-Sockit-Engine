package funkin.states.menus.options;

import flixel.FlxG;
import flixel.util.FlxTimer;
import funkin.system.MusicBeat.MusicBeatSubState;
import funkin.system.Preferences;
import funkin.ui.Alphabet;
import funkin.ui.CheckBox;

class Option {
    public var name:String;
    public var type:String;
    public var id:String;
    public var value:Dynamic;
    public var scrollSpeed:Float;
    public var min:Float;
    public var max:Float;
    public var onChange:Void -> Void = null;
    public var boolThing:Array<Bool> = [true, false];
    public var curVal:Int = 0;

    public function new(?x:Float = 0, ?y:Float = 0, name:String, id:String, type:String, ?scrollSpeed:Float = 1, ?min:Float, ?max:Float) {
        this.name = name;
        this.type = type;
        this.id = id;
        this.value = Reflect.getProperty(Preferences, id);
        if (type != 'bool') {
            this.scrollSpeed = scrollSpeed;
            this.min = min;
            this.max = max;
        }
        if (value == true)
            curVal = 0;
        else
            curVal = 1;
    }

    public function updateOptions() {
        if (min > value)
            value = min;

        if (max < value)
            value = max;
        
        changeValue();

        if (curVal > boolThing.length - 1)
            curVal = 0;

        if (curVal < 0)
            curVal = boolThing.length - 1;
        
        if (type == 'bool') {
            Reflect.setProperty(Preferences, id, boolThing[curVal]);
        }

        value = Reflect.getProperty(Preferences, id);
    }

    public function changeValue() {
        if (FlxG.keys.justPressed.LEFT) {
            if(type == 'int') {
                Reflect.setProperty(Preferences, id, value -= scrollSpeed);
                if (onChange != null)
                    onChange();
            }
            if(type == 'bool') {
                curVal += 1;
                if (onChange != null)
                    onChange();
            }
            Preferences.saveOptions();
        }
        if (FlxG.keys.justPressed.RIGHT) {
            if(type == 'int') {
                Reflect.setProperty(Preferences, id, value += scrollSpeed);
                if (onChange != null)
                    onChange();
            }
            if(type == 'bool') {
                curVal -= 1;
                if (onChange != null)
                    onChange();
            }
            Preferences.saveOptions();
        }
    }
}