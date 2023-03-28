package funkin.states.menus.options;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatSubState;
import funkin.system.Preferences;
import funkin.ui.Alphabet;
import funkin.ui.CheckBox;
import funkin.util.FunkinUtil;

using StringTools;

class OptionsList extends MusicBeatSubState {
    public var cam:FlxObject;
    public static var alphabitch:FlxTypedGroup<Alphabet>;
    public static var intVal:FlxTypedGroup<FlxText>;
    public static var boxes:FlxTypedGroup<CheckBox>;
    public static var options:Array<Option> = [];
    public var curSel:Int = 0;

    public function toggleOption(change:Float = 0) {
        if (options[curSel].type == 'bool') {
            Reflect.setProperty(Preferences, options[curSel].id, !options[curSel].value);
            options[curSel].value = Reflect.getProperty(Preferences, options[curSel].id);
            //trace(Reflect.setProperty(Preferences, options[curSel].id, options[curSel].value));
            boxes.forEach(function(ow:CheckBox) {
                if (ow.ID == curSel) {
                    ow.set_value(options[curSel].value);
                }
            });
            Preferences.saveOptions();
        }

        if (options[curSel].type != 'bool') {
            options[curSel].value += change;
            Reflect.setProperty(Preferences, options[curSel].id, options[curSel].value);
        }
        
        if (options[curSel].onChange != null)
            options[curSel].onChange();
    }

    public function new() {
        super();

        cam = new FlxObject(0, 0, 1, 1);
        add(cam);
        
        alphabitch = new FlxTypedGroup<Alphabet>();
        add(alphabitch);

        boxes = new FlxTypedGroup<CheckBox>();
        add(boxes);

        intVal = new FlxTypedGroup<FlxText>();
        add(intVal);

        for (i in 0...options.length) {
            if (options[i].type == 'bool') {
                var txt:Alphabet = new Alphabet(0, 0 + (150 * i), options[i].name, true);
                txt.ID = i;
                alphabitch.add(txt);
                var hi:CheckBox = new CheckBox(txt.width, txt.y / 2, options[i].value);
                hi.ID = i;
                boxes.add(hi);
            }

            if (options[i].type == 'int' || options[i].type == 'float') {
                var txt:Alphabet = new Alphabet(0, 0 + (150 * i), '${options[i].name} ${options[i].value.toString()}', true);
                txt.ID = i;
                alphabitch.add(txt);
                var balls:FlxText = new FlxText(txt.width + 20, txt.y, 0, options[i].value, 32);
                balls.setFormat(FunkinPaths.font('vcr.ttf'), 64, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                balls.ID = i;
                intVal.add(balls);
            }
        }

        FlxG.camera.follow(cam, LOCKON, FunkinUtil.adjustedFrame(0.06));

        onSelect();

        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.UP)
            onSelect(-1);
        if(FlxG.keys.justPressed.DOWN)
            onSelect(1);
        if(FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new funkin.states.menus.options.OptionsMenu());
        }

        if (options[curSel].type != 'bool') {
        if (options[curSel].min > options[curSel].value)
            options[curSel].value = options[curSel].min;

        if (options[curSel].max < options[curSel].value)
            options[curSel].value = options[curSel].max;
        }

        if (FlxG.keys.justPressed.ENTER) {
            toggleOption();
        }

        intVal.forEach(function(bbc:FlxText) {
            if (options[curSel].type == 'int' || options[curSel].type == 'float') {
                bbc.text = options[curSel].value;
                Reflect.setProperty(Preferences, options[curSel].id, options[curSel].value);
            }
        });

        if (FlxG.keys.justPressed.LEFT && options[curSel].type != 'bool') {
            if(options[curSel].type == 'int')
                toggleOption(-options[curSel].scrollSpeed);
            else
                toggleOption(-options[curSel].scrollSpeed);
        }
        if (FlxG.keys.justPressed.RIGHT && options[curSel].type != 'bool') {
            if(options[curSel].type == 'int')
                toggleOption(options[curSel].scrollSpeed);
            else
                toggleOption(options[curSel].scrollSpeed);
        }

        options[curSel].value = Reflect.getProperty(Preferences, options[curSel].id);
        
        super.update(elapsed);
    }

    function onSelect(sel:Int = 0) {
        curSel += sel;

        if (curSel < 0)
            curSel = options.length - 1;
        if (curSel >= options.length)
            curSel = 0;
        
        alphabitch.forEach(function(bbc:Alphabet) {
            if (bbc.ID == curSel) {
                bbc.alpha = 1;
                cam.setPosition(FlxG.width / 2, bbc.y);
            }
            if (bbc.ID != curSel) {
                bbc.alpha = 0.6;
            }
        });

        intVal.forEach(function(bbc:FlxText) {
            if (bbc.ID == curSel) {
                bbc.alpha = 1;
            }
            if (bbc.ID != curSel) {
                bbc.alpha = 0.6;
            }
        });

        boxes.forEach(function(ow:CheckBox) {
            if (ow.ID == curSel) {
                ow.alpha = 1;
            }
            if (ow.ID != curSel) {
                ow.alpha = 0.6;
            }
            //ow.set_value(options[ow.ID].value);//do it work???
        });
    }
}