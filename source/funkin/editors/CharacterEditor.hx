package funkin.editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.obj.*;
import funkin.system.*;
import sys.FileSystem;

using StringTools;

/**
	*DEBUG MODE
 */
class CharacterEditor extends FlxState
{
    var mainBox:FlxUITabMenu;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
    var charList:Array<String> = [];
	var camFollow:FlxObject;

	override function create()
	{
		FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		var tabs = [
			{name: "Character", label: 'Character'},
			{name: "Animation", label: 'Animation'}
        ];

		mainBox = new FlxUITabMenu(null, null, tabs, null, true);

		mainBox.resize(300, 400);
		mainBox.x = FlxG.width / 2;
		mainBox.y = 20;
		add(mainBox);

        addCharUI();
        //addAnimUI();
        reloadCharacter('bf');

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

    function addCharUI() {
		var swagChar = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(getCharacterFileFromPaths(), true), function(character:String)
        {
            character = getCharacterFileFromPaths()[Std.parseInt(character)];
            reloadCharacter(character);
        });

        swagChar.selectedLabel = "bf";

        var check_flipX = new FlxUICheckBox(10, swagChar.y + 40, null, null, "Flip X (whole character)", 100);
		check_flipX.checked = false;
		check_flipX.callback = function()
		{
            char.flipX = check_flipX.checked;
		};

        var check_flipY = new FlxUICheckBox(10, check_flipX.y + 20, null, null, "Flip Y (whole character)", 100);
		check_flipY.checked = false;
		check_flipY.callback = function()
		{
            char.flipX = check_flipY.checked;
		};

        var tab_group_char = new FlxUI(null, mainBox);
		tab_group_char.name = "Character";
        tab_group_char.add(check_flipX);
        tab_group_char.add(check_flipY);
        tab_group_char.add(swagChar);
        mainBox.addGroup(tab_group_char);
		mainBox.scrollFactor.set();
    }

    function addAnimUI() {
		var swagAnim = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(char.animation.getNameList(), true), function(dummy:String)
        {
            dummy = char.animation.getNameList()[Std.parseInt(dummy)];
            char.playAnim(dummy);
        });

        swagAnim.selectedLabel = "idle";

        var check_flipX = new FlxUICheckBox(10, swagAnim.y + 40, null, null, "Flip X (whole character)", 100);
		check_flipX.checked = false;
		check_flipX.callback = function()
		{
            char.flipX = check_flipX.checked;
		};

        var check_flipY = new FlxUICheckBox(10, check_flipX.y + 20, null, null, "Flip Y (whole character)", 100);
		check_flipY.checked = false;
		check_flipY.callback = function()
		{
            char.flipX = check_flipY.checked;
		};

        var tab_group_anim = new FlxUI(null, mainBox);
		tab_group_anim.name = "Animation";
        tab_group_anim.add(check_flipX);
        tab_group_anim.add(check_flipY);
        tab_group_anim.add(swagAnim);
        mainBox.addGroup(tab_group_anim);
		mainBox.scrollFactor.set();
    }

    function reloadCharacter(newChar:String) {
        remove(char);
        char = new Character(0, 0, newChar);
        add(char);
    }

    function getCharacterFileFromPaths():Array<String> {
        for (file in FileSystem.readDirectory('assets/characters')){
            charList.push(file.replace('.json', ''));
        }

        return charList;
    }

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		super.update(elapsed);
	}
}
