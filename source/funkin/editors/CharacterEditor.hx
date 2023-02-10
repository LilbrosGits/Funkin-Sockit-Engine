package funkin.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import funkin.editors.*;
import funkin.obj.Character;
import funkin.system.*;
import funkin.system.MusicBeat.MusicBeatState;
import sys.FileSystem;

using StringTools;

class CharacterEditor extends MusicBeatState {
    var tempChar:String = '{
        "singAnims": ["singLEFT", "singDOWN", "singUP", "singRIGHT"],
        "defaultAnim": "idle",
        "spriteSheet": "characters/DADDY_DEAREST",
        "animations": {
            "prefixAnim": [
                {
                    "name": "idle",
                    "xmlName": "Dad idle dance",
                    "offsets": [0, 0],
                    "fr": 24,
                    "loop": false
                },
                {
                    "name": "singLEFT",
                    "xmlName": "Dad Sing Note LEFT",
                    "offsets": [0, 0],
                    "fr": 24,
                    "loop": false
                },
                {
                    "name": "singDOWN",
                    "xmlName": "Dad Sing Note DOWN",
                    "offsets": [0, 0],
                    "fr": 24,
                    "loop": false
                },
                {
                    "name": "singUP",
                    "xmlName": "Dad Sing Note UP",
                    "offsets": [0, 0],
                    "fr": 24,
                    "loop": false
                },
                {
                    "name": "singRIGHT",
                    "xmlName": "Dad Sing Note RIGHT",
                    "offsets": [0, 0],
                    "fr": 24,
                    "loop": false
                }
            ]
        }
    }';
    var mainBox:FlxUITabMenu;
    var char:Character;
    var charList:Array<String> = [];

    override public function create() {
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

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new funkin.states.PlayState());
        }

        if (FlxG.keys.justPressed.F1) {
            FlxG.switchState(new CharacterJSONEditor());
        }
        super.update(elapsed);
    }
}