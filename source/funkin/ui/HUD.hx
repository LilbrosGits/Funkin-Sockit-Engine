package funkin.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import funkin.states.PlayState;
import funkin.system.*;

class HUD extends FlxSubState{
	private var healthBarBackdrop:FlxSprite;
	private var healthBar:FlxBar;
    public var health:Float = 50;
	public var iconP1:Icon;
	public var iconP2:Icon;
	public var scoreTxt:String = '';
	public var scoreBar:FlxText;//should probably name this something else???
	
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

		iconP1 = new Icon(PlayState.song.characters[1], true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new Icon(PlayState.song.characters[0], false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(FlxG.width / 2, healthBarBackdrop.y + 40, 0, scoreTxt, 32);
		scoreBar.setFormat(FunkinPaths.font('vcr.ttf'), 18, FlxColor.WHITE);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreBar.antialiasing = true;
		add(scoreBar);
    }

    override public function update(elapsed:Float) {
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 70)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		scoreBar.text = scoreTxt;
		
        super.update(elapsed);
    }

	public function everyBeat() {
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}
}