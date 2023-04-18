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
    public static var options:Array<Option> = [];
    public static var optionGrp:FlxTypedGroup<Alphabet>;
    public var curSel:Int = 0;

    public function new() {
        super();

        cam = new FlxObject(0, 0, 1, 1);
        add(cam);

        optionGrp = new FlxTypedGroup<Alphabet>();
        add(optionGrp);

        for (i in 0...options.length) {
            var cum = new Alphabet(0, 0 + (i * 150), '${options[i].name} <${options[i].value}>', true);
            cum.ID = i;
            optionGrp.add(cum);
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

        options[curSel].updateOptions();
        
        optionGrp.forEach(function(bbc:Alphabet) {
            bbc.text = '${options[bbc.ID].name} <${options[bbc.ID].value}>';
        });
        
        super.update(elapsed);
    }

    function onSelect(sel:Int = 0) {
        curSel += sel;

        if (curSel < 0)
            curSel = options.length - 1;
        if (curSel >= options.length)
            curSel = 0;
        
        optionGrp.forEach(function(bbc:Alphabet) {
            if (bbc.ID == curSel) {
                bbc.alpha = 1;
                cam.setPosition(FlxG.width / 2, bbc.y);
            }
            if (bbc.ID != curSel) {
                bbc.alpha = 0.6;
            }
        });
    }
}