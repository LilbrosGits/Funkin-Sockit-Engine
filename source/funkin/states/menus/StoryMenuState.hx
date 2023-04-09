package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.obj.MenuCharacter;
import funkin.scripting.FunkinScript;
import funkin.system.FunkinPaths;
import funkin.system.MusicBeat.MusicBeatState;
import funkin.system.Preferences;
import funkin.system.Score;
import funkin.system.Song;
import funkin.util.FunkinUtil;

typedef Json = {
    weeks:Array<Week>,
    ?script:String
}

typedef Week = {
    weekID:String,
    weekName:String,
    songs:Array<String>,
    characters:Array<String>,
    locked:Bool,
    ?difficulties:Array<String>
}

class StoryMenuState extends MusicBeatState {
    public static var weekData:Json;
    var scoreText:FlxText;
    var bro:FunkinScript;
    var menuCharacters:FlxTypedGroup<MenuCharacter>;
    var broh:FlxTypedGroup<FlxSprite>;
    var diffSel:FlxTypedGroup<FlxSprite>;
    var selected:Int = 0;
    var yellowBG:FlxSprite;
    var curDiff:Int = 1;
    var diffSpr:FlxSprite;
    var weekTitle:FlxText;
    //ugh
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;
    var tracklist:FlxText;

    override public function create() {
        weekData = haxe.Json.parse(FunkinPaths.getText('data/weeks.json'));
        bro = new FunkinScript();
        if (weekData.script != null) {
            bro.setVar('weekJSON', weekData);
            bro.execute(weekData.script);
            bro.executeFunc('onCreate', []);
        }

        broh = new FlxTypedGroup<FlxSprite>();
        add(broh);

        diffSel = new FlxTypedGroup<FlxSprite>();
        add(diffSel);

        scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		weekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		weekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		weekTitle.alpha = 0.7;

        yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
        yellowBG.scrollFactor.set();
        add(yellowBG);

        menuCharacters = new FlxTypedGroup<MenuCharacter>();
        add(menuCharacters);

        var ui_spr = FunkinPaths.sparrowAtlas('UI/menus/storymenu/campaign_menu_UI_assets');

        for (i in 0...weekData.weeks.length) {
            var crazy = new FlxSprite(0, yellowBG.y + 396 + (i * 100)).loadGraphic(FunkinPaths.image('UI/menus/storymenu/weeks/${weekData.weeks[i].weekID}'));
            crazy.screenCenter(X);
            crazy.y = FlxMath.lerp(crazy.y, (i * 120) + 480, 0.17);
            crazy.ID = i;
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

        for (i in 0...3) {
            var weekCharacter:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + i) - 150, weekData.weeks[selected].characters[i]);
            weekCharacter.antialiasing = Preferences.antialiasing;
            menuCharacters.add(weekCharacter);
        }

        tracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		tracklist.alignment = CENTER;
		tracklist.font = weekTitle.font;
		tracklist.color = 0xFFe55777;
		add(tracklist);

        add(scoreText);
		add(weekTitle);

        if (weekData.script != null) {
            bro.setVar('weekListGrp', broh);
            bro.setVar('difficultySelectors', diffSel);
            bro.setVar('weekScoreText', scoreText);
            bro.setVar('weekTitle', weekTitle);
            bro.setVar('yellowBG', yellowBG);
            bro.setVar('characters', menuCharacters);
            bro.setVar('ui_image', ui_spr);
            bro.setVar('difficultyTxt', diffSpr);
            bro.setVar('leftArrow', leftArrow);
            bro.setVar('rightArrow', rightArrow);
            bro.setVar('weekTracklist', tracklist);
        }

        sel();
        selDiff();

        updateText();
        
        super.create();

        if (weekData.script != null)
            bro.executeFunc('onCreatePost', []);
    }

    var lerpScore:Float = 0;
	var intendedScore:Int = 0;

    override public function update(elapsed:Float) {
        if (weekData.script != null)
            bro.executeFunc('onUpdate', [elapsed]);
        
        lerpScore = lerpScore + FlxG.elapsed / (1 / 60) * 0.5 * (intendedScore - lerpScore);

		scoreText.text = "WEEK SCORE:" + Math.round(lerpScore);

        weekTitle.text = weekData.weeks[selected].weekName.toUpperCase();
		weekTitle.x = FlxG.width - (weekTitle.width + 10);

        diffSel.visible = !weekData.weeks[selected].locked;

        if (FlxG.keys.justPressed.DOWN)
            sel(1);
        if (FlxG.keys.justPressed.UP)
            sel(-1);

        if (FlxG.keys.justPressed.LEFT)
            selDiff(-1);
        if (FlxG.keys.justPressed.RIGHT)
            selDiff(1);

        if (FlxG.keys.justPressed.ENTER) {
            PlayState.song = Song.loadSong(weekData.weeks[selected].songs[0], FunkinUtil.difficulties[curDiff]);
            PlayState.storyList = weekData.weeks[selected].songs;
            PlayState.storyMode = true;
            PlayState.difficulty = FunkinUtil.difficulties[curDiff];
            PlayState.storyWeek = selected;
            PlayState.storyDifficulty = curDiff;
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
        updateText();
    }

    function selDiff(change:Int = 0) {
        curDiff += change;

        if (curDiff >= weekData.weeks[selected].difficulties.length)
            curDiff = 0;
        if (curDiff < 0)
            curDiff = weekData.weeks[selected].difficulties.length - 1;

        if (weekData.weeks[selected].difficulties != null)
            FunkinUtil.difficulties = weekData.weeks[selected].difficulties;

        diffSpr.loadGraphic(FunkinPaths.image('UI/menus/storymenu/diff/${weekData.weeks[selected].difficulties[curDiff]}'));

        diffSpr.y = leftArrow.y - 20;
        diffSpr.alpha = 0;
        FlxTween.tween(diffSpr, {y: leftArrow.y + 15, alpha: 1}, 0.05);
        diffSpr.x = leftArrow.x + 60;
        diffSpr.x += (308 - diffSpr.width) / 3;
        //diffSpr.y = leftArrow.y + 15;
        //rightArrow.x += diffSpr.width;
    }

    function updateText()
    {
        var weekShit:Array<String> = weekData.weeks[selected].characters;
        for (i in 0...menuCharacters.length) {
            menuCharacters.members[i].changeChar(weekShit[i]);
        }
        
		var stringThing:Array<String> = weekData.weeks[selected].songs;

		tracklist.text = 'Tracks\n';

		for (i in stringThing)
		{
			tracklist.text += "\n" + i;
		}

        tracklist.text = tracklist.text.toUpperCase();

        tracklist.screenCenter(X);
        tracklist.x -= FlxG.width * 0.35;

        #if !switch
        intendedScore = Score.getWeekScore(selected, curDiff);
        #end
    }
}