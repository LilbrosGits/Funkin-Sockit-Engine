package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.scripting.FunkinScript;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Util;

class MainMenuState extends MusicBeatState {
    var bg:FlxSprite;
    var magenta:FlxSprite;
    var menuItems:FlxTypedGroup<FlxSprite>;
    var swagJunk:Array<String> = ['story_mode', 'freeplay', 'options'];
    var curSelected:Int = 0;
    var camFol:FlxObject;
    var scriptSwag:FunkinScript;

    override public function create() {
        scriptSwag = new FunkinScript();
        if (FunkinPaths.exists(FunkinPaths.state('MainMenuState')))
            Util.getState('MainMenuState', scriptSwag);

        scriptSwag.executeFunc('onCreate', []);

        bg = new FlxSprite(0, 0).loadGraphic(FunkinPaths.image('UI/menus/menuBG'));
        bg.scrollFactor.set();
        add(bg);

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        camFol = new FlxObject(0, 0, 1, 1);
        add(camFol);

        for (i in 0...swagJunk.length) {
            var swaggyBalls:FlxSprite = new FlxSprite(0, 100 + (180 * i));
            swaggyBalls.frames = FunkinPaths.sparrowAtlas('UI/menus/mainmenu/menu_${swagJunk[i]}');
            swaggyBalls.animation.addByPrefix('idle', '${swagJunk[i]} basic', 24);
            swaggyBalls.animation.addByPrefix('selected', '${swagJunk[i]} white', 24);
            swaggyBalls.animation.play('idle');
            swaggyBalls.screenCenter(X);
            swaggyBalls.scrollFactor.set();
            swaggyBalls.ID = i;
            menuItems.add(swaggyBalls);
        }

        FlxG.camera.follow(camFol, null, Util.adjustedFrame(0.06));

        scriptSwag.executeFunc('onCreatePost', []);

        super.create();
    }

    override public function update(elapsed:Float) {

        scriptSwag.executeFunc('onUpdate', [elapsed]);

        if (FlxG.keys.justPressed.UP) {
            curSelected -= 1;
        }
        if (FlxG.keys.justPressed.DOWN) {
            curSelected += 1;
        }

        if (curSelected < 0) {
            curSelected = swagJunk.length - 1;
        }
        if (curSelected >= swagJunk.length) {
            curSelected = 0;
        }
        
        if (FlxG.keys.justPressed.ENTER) {
            var funy:String = swagJunk[curSelected];

            switch(funy) {
                case 'story_mode':
                    FlxG.switchState(new PlayState());
                case 'freeplay':
                    FlxG.switchState(new PlayState());
                case 'options':
                    FlxG.switchState(new OptionsMenu());
                default:
                    FlxG.switchState(new PlayState());
            }
        }
        super.update(elapsed);

        menuItems.forEach(function(wag:FlxSprite) {
            wag.animation.play('idle');
            if (curSelected == wag.ID) {
                wag.animation.play('selected');
                camFol.setPosition(wag.getGraphicMidpoint().x, wag.getGraphicMidpoint().y);
            }
            wag.updateHitbox();
            wag.screenCenter(X);
        });

        scriptSwag.executeFunc('onUpdatePost', [elapsed]);
    }
}