package funkin.ui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.typeLimit.OneOfTwo;
import funkin.system.MusicBeat.MusicBeatSubState;
import funkin.ui.Alphabet;
import funkin.util.FunkinUtil;

class AlphabetList extends MusicBeatSubState {
    var listGrp:FlxTypedGroup<Alphabet>;
    public var bold:Bool = false;
    public var typed:Bool = false;
    public var isMenuItem:Bool = false;
    public var curSelected:Int = 0;
    public var camLerp:Float = 0.06;
    public var list:Array<Dynamic> = [];
    var fol:FlxObject;

    public function new(list:Array<Dynamic>, index:Int, follow:Bool, bold:Bool, typed:Bool) {
        super();
        this.list = list;
        index = curSelected;
        this.typed = typed;
        this.bold = bold;
        fol = new FlxObject(0, 0, 1, 1);
        listGrp = new FlxTypedGroup<Alphabet>();
        add(listGrp);
        
        for (i in 0...list.length) {
            var txt = new Alphabet(0, 0 + (i * 100), list[i].toString(), bold, typed);
            txt.isMenuItem = isMenuItem;
            txt.targetY = i;
            txt.ID = i;
            listGrp.add(txt);
        }
        FlxG.camera.follow(fol, LOCKON, FunkinUtil.adjustedFrame(camLerp));
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.UP) {
            curSelected -= 1;
        }
        if (FlxG.keys.justPressed.DOWN) {
            curSelected += 1;
        }
        if (FlxG.keys.justPressed.ENTER) {
            onSelect;
        }

        listGrp.forEach(function(txt:Alphabet) {
            if (txt.ID == curSelected) {
                fol.setPosition(FlxG.width / 2, txt.y);
                txt.alpha = 1;
            }
            else {
                txt.alpha = 0.6;
            }
        });

        if (curSelected < 0) {
            curSelected = list.length - 1;
        }
        if (curSelected >= list.length) {
            curSelected = 0;
        }
        super.update(elapsed);
    }

    public function onSelect(func:Void -> Void) {
        func();
    }
}