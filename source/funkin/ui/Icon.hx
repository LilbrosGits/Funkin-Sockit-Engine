package funkin.ui;

import flixel.FlxSprite;
import funkin.system.FunkinPaths;

class Icon extends FlxSprite {
    public var sprTracker:FlxSprite;

    public function new(char:String = 'bf', isPlayer:Bool) {
        super();

        loadGraphic(FunkinPaths.image('UI/HUD/icons/icon-$char'), true, 150, 150);

        antialiasing = true;
        animation.add(char, [0, 1], 0, false, isPlayer);
        animation.play(char);
        scrollFactor.set();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
    }
}