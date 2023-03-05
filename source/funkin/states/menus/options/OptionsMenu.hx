package funkin.states.menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Preferences;
import funkin.ui.Alphabet;
import funkin.ui.CheckBox;

class OptionsMenu extends MusicBeatState {
    public var alphabitch:FlxTypedGroup<Alphabet>;
    public var boxes:FlxTypedGroup<CheckBox>;
    public var options:Array<Option> = [];
    public var curSel:Int = 0;

    public function makeOption(name:String, id:String, type:String) {
        var kys:Option = new Option(name, id, type, Reflect.getProperty(Preferences, id));
        options.push(kys);
    }

    public function toggleOption() {
        if (options[curSel].type == 'bool') {
            var value = options[curSel].value;
            value = !value;
            options[curSel].value = value;
            Reflect.setProperty(Preferences, options[curSel].id, options[curSel].value);
            boxes.forEach(function(ow:CheckBox) {
                if (ow.ID == curSel) {
                    ow.set_value(options[curSel].value);
                }
            });
            Preferences.saveOptions();
        }
    }

    override public function create() {
        Preferences.loadOptions();
        var bg:FlxSprite = new FlxSprite().loadGraphic(FunkinPaths.image('UI/menus/menuBGBlue'));
        add(bg);

        makeOption('downscroll', 'downscroll', 'bool');
        makeOption('antialiasing', 'antialiasing', 'bool');
        
        alphabitch = new FlxTypedGroup<Alphabet>();
        add(alphabitch);

        boxes = new FlxTypedGroup<CheckBox>();
        add(boxes);

        for (i in 0...options.length) {
            var txt:Alphabet = new Alphabet(0, 0 + (100 * i), options[i].name, true);
            txt.ID = i;
            alphabitch.add(txt);
            if (options[i].type == 'bool') {
                var hi:CheckBox = new CheckBox(txt.width, 0 + (60 * i), options[i].value);
                hi.ID = i;
                boxes.add(hi);
            }
        }

        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.UP)
            onSelect(-1);
        if(FlxG.keys.justPressed.DOWN)
            onSelect(1);
        if(FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(new funkin.states.menus.MainMenuState());

        if (FlxG.keys.justPressed.ENTER) {
            toggleOption();
        }
        
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
            ow.set_value(options[ow.ID].value);//do it work???
        });
    }
}