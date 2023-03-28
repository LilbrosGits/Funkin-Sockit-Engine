package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import funkin.scripting.FunkinScript;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Preferences;
import funkin.system.Song;
import funkin.util.FunkinUtil;

typedef Json = {
    weeks:Array<Week>,
    ?script:String
}

typedef Week = {
    weekName:String,
    songs:Array<String>,
    characters:Array<String>,
    locked:Bool,
    ?difficulties:Array<String>
}

class StoryMenuState extends MusicBeatState {
    public static var weekData:Json;
    var bro:FunkinScript;
    var broh:FlxTypedGroup<FlxSprite>;
    var diffSel:FlxTypedGroup<FlxSprite>;
    var selected:Int = 0;
    var yellowBG:FlxSprite;
    var curDiff:Int = 0;
    var diffSpr:FlxSprite;
    //ugh
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    override public function create() {
        weekData = haxe.Json.parse(FunkinPaths.getText('data/weeks.json'));
        bro = new FunkinScript();
        if (weekData.script != null) {
            bro.execute(weekData.script);
            bro.executeFunc('onCreate', []);
        }

        broh = new FlxTypedGroup<FlxSprite>();
        add(broh);

        diffSel = new FlxTypedGroup<FlxSprite>();
        add(diffSel);

        yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
        yellowBG.scrollFactor.set();
        add(yellowBG);

        var ui_spr = FunkinPaths.sparrowAtlas('UI/menus/storymenu/campaign_menu_UI_assets');

        for (i in 0...weekData.weeks.length) {
            var crazy = new FlxSprite(0, yellowBG.y + 396 + (i * 100)).loadGraphic(FunkinPaths.image('UI/menus/storymenu/weeks/${weekData.weeks[i].weekName}'));
            crazy.screenCenter(X);
            crazy.y = FlxMath.lerp(crazy.y, (i * 120) + 480, 0.17);
            broh.add(crazy);
        }

        diffSpr = new FlxSprite(0, yellowBG.y + 396);
        diffSpr.antialiasing = Preferences.antialiasing;
        diffSel.add(diffSpr);

        leftArrow = new FlxSprite(broh.members[0].x + broh.members[0].width + 10, broh.members[0].y + 10);
        leftArrow.frames = ui_spr;
        leftArrow.animation.addByPrefix('idle', 'arrow left');
        leftArrow.animation.addByPrefix('push', 'arrow push left');
        leftArrow.animation.play('idle');
		leftArrow.antialiasing = Preferences.antialiasing;
        diffSel.add(leftArrow);

        rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
        rightArrow.frames = ui_spr;
        rightArrow.animation.addByPrefix('idle', 'arrow right');
        rightArrow.animation.addByPrefix('push', 'arrow push right');
        rightArrow.animation.play('idle');
		rightArrow.antialiasing = Preferences.antialiasing;
        diffSel.add(rightArrow);
        
        sel();
        selDiff();
        
        super.create();

        if (weekData.script != null)
            bro.executeFunc('onCreatePost', []);
    }

    override public function update(elapsed:Float) {
        if (weekData.script != null)
            bro.executeFunc('onUpdate', [elapsed]);
        
        if (FlxG.keys.justPressed.DOWN)
            sel(1);
        if (FlxG.keys.justPressed.UP)
            sel(-1);

        if (FlxG.keys.justPressed.LEFT)
            selDiff(1);
        if (FlxG.keys.justPressed.RIGHT)
            selDiff(-1);

        if (FlxG.keys.justPressed.ENTER) {
            PlayState.song = Song.loadSong(weekData.weeks[selected].songs[0], FunkinUtil.difficulties[curDiff]);
            FlxG.switchState(new PlayState());
        }

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(new MainMenuState());

        super.update(elapsed);
        if (weekData.script != null)
            bro.executeFunc('onUpdatePost', [elapsed]);
    }

    function sel(change:Int = 0) {
        selected += change;

        if (selected >= weekData.weeks.length)
            selected = 0;
        if (selected < 0)
            selected = weekData.weeks.length - 1;

        broh.forEach(function(swag:FlxSprite) {
            if (swag.ID == selected && !weekData.weeks[swag.ID].locked) {
                swag.alpha = 1;
            }
            else
                swag.alpha = 0.6;
        });
    }

    function selDiff(change:Int = 0) {
        curDiff += change;

        if (curDiff >= weekData.weeks[selected].difficulties.length)
            curDiff = 0;
        if (curDiff < 0)
            curDiff = weekData.weeks[selected].difficulties.length - 1;

        FunkinUtil.difficulties = weekData.weeks[selected].difficulties;

        diffSpr.loadGraphic(FunkinPaths.image('UI/menus/storymenu/diff/${weekData.weeks[selected].difficulties[curDiff]}'));
        diffSpr.x = leftArrow.x + 60;
        diffSpr.x += (308 - diffSpr.width) / 3;
        diffSpr.y = leftArrow.y + 15;
        //rightArrow.x += diffSpr.width;
    }
}