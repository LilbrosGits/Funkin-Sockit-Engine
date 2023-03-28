package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.scripting.FunkinScript;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Preferences;
import funkin.util.FunkinUtil;

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
            FunkinUtil.getState('MainMenuState', scriptSwag);

        scriptSwag.executeFunc('onCreate', []);

        var yScroll:Float = Math.max(0.25 - (0.05 * (swagJunk.length - 4)), 0.1);
        bg = new FlxSprite(0, 0).loadGraphic(FunkinPaths.image('UI/menus/menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = Preferences.antialiasing;
        add(bg);

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        camFol = new FlxObject(0, 0, 1, 1);
        add(camFol);

        for (i in 0...swagJunk.length) {
            var swaggyBalls:FlxSprite = new FlxSprite(0, 60 + (200 * i));
            swaggyBalls.frames = FunkinPaths.sparrowAtlas('UI/menus/mainmenu/menu_${swagJunk[i]}');
            swaggyBalls.animation.addByPrefix('idle', '${swagJunk[i]} basic', 24);
            swaggyBalls.animation.addByPrefix('selected', '${swagJunk[i]} white', 24);
            swaggyBalls.animation.play('idle');
            swaggyBalls.screenCenter(X);
            swaggyBalls.scrollFactor.set();
            swaggyBalls.ID = i;
            menuItems.add(swaggyBalls);
        }

        FlxG.camera.follow(camFol, null, FunkinUtil.adjustedFrame(0.06));

        scriptSwag.executeFunc('onCreatePost', []);

        select();

        super.create();
    }

    override public function update(elapsed:Float) {

        scriptSwag.executeFunc('onUpdate', [elapsed]);

        if (FlxG.keys.justPressed.UP) {
            select(-1);//gay shit cause the anims don't play
        }
        if (FlxG.keys.justPressed.DOWN) {
            select(1);//gay shit cause the anims don't play
        }
        
        if (FlxG.keys.justPressed.ENTER) {
            var funy:String = swagJunk[curSelected];

            switch(funy) {
                case 'story_mode':
                    FlxG.switchState(new StoryMenuState());
                case 'freeplay':
                    FlxG.switchState(new FreeplayMenu());
                case 'options':
                    FlxG.switchState(new funkin.states.menus.options.OptionsMenu());
                default:
                    FlxG.switchState(new PlayState());
            }
        }
        if (FlxG.keys.justPressed.SEVEN) {
            FlxG.switchState(new funkin.states.menus.modding.ModsMenu());
        }
        super.update(elapsed);

        scriptSwag.executeFunc('onUpdatePost', [elapsed]);
    }

    function select(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0) {
            curSelected = swagJunk.length - 1;
        }
        if (curSelected >= swagJunk.length) {
            curSelected = 0;
        }
        
        menuItems.forEach(function(wag:FlxSprite) {
            wag.animation.play('idle');
            if (wag.ID == curSelected) {
                wag.animation.play('selected');
                camFol.setPosition(FlxG.width / 2, wag.getGraphicMidpoint().y);
            }
            wag.updateHitbox();
            wag.screenCenter(X);
        });
    }
}