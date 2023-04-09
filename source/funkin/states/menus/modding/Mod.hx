package funkin.states.menus.modding;

import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import funkin.system.FunkinPaths;

class Mod extends FlxSprite {
    public var modName:String;
    public var onOffButton:FlxButton;
    public var enabledText:String = 'Disabled';
    override public function new(x:Float, y:Float, modName:String) {
        super(x, y);
        this.modName = modName;
        makeGraphic(600, 400, FlxColor.BLACK);
        alpha = 0.6;
        onOffButton = new FlxButton(0, 0, enabledText, function() {
            FunkinPaths.currentModDir = modName;
        });
    }

    override public function update(elapsed:Float) {
        if (FunkinPaths.currentModDir == modName)
            enabledText = 'Enabled';
        else
            enabledText = 'Disabled';
        super.update(elapsed);
    }
}