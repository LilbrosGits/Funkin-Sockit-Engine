package funkin.ui;

import flixel.FlxSprite;
import funkin.system.*;

class Icon extends FlxSprite {
    public var sprTracker:FlxSprite;
	var isPlayer(default, null):Bool;


    public function new(char:String = 'bf', isPlayer:Bool) {
        super();
        changeIcon(char);
        flipX = isPlayer;
    }

    public function changeIcon(char:String = 'bf') {
        if (!FunkinPaths.exists(FunkinPaths.image('UI/HUD/icons/icon-$char')))
            loadGraphic(FunkinPaths.image('UI/HUD/icons/icon-face'), true, 150, 150);
        else
            loadGraphic(FunkinPaths.image('UI/HUD/icons/icon-$char'), true, 150, 150);

        antialiasing = true;
        animation.add(char, [0, 1], 0, false);
        animation.play(char);
        antialiasing = Preferences.antialiasing;
        scrollFactor.set();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
    }
}