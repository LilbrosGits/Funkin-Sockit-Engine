var healthBarBG:FlxSprite;
var healthBar:Bar;

function onCreatePost() {
    healthBarBG = new SockitSprite('healthBG', FlxG.width / 2, FlxG.height * 0.9);
    healthBarBG.setImage('images/healthBar');
    healthBarBG.scrollFactor.set();
    add(healthBarBG);

    healthBar = new Bar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), PlayState,
        'health', 0, 2);
    healthBar.scrollFactor.set();
    healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
    add(healthBar);
    
    healthBar.cameras = [PlayState.camHUD];
    healthBarBG.cameras = [PlayState.camHUD];
}