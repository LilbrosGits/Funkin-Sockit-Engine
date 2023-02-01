package funkin.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.ui.FlxBar;
import funkin.system.*;

class HUD extends FlxSubState{
	private var healthBarBackdrop:FlxSprite;
	private var healthBar:FlxBar;
    public var health:Float = 50;
    public function new(){
        super();
		healthBarBackdrop = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(FunkinPaths.image('UI/HUD/healthBar'));
		healthBarBackdrop.screenCenter(X);
		healthBarBackdrop.scrollFactor.set();
		add(healthBarBackdrop);

		healthBar = new FlxBar(healthBarBackdrop.x + 4, healthBarBackdrop.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBackdrop.width - 8), Std.int(healthBarBackdrop.height - 8), this,
			'health', 0, 100);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}