package funkin.editors;

import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import funkin.system.MusicBeat.MusicBeatState;

class StageEditor extends MusicBeatState {
    var daUIBox:FlxUITabMenu;

    override public function create() {
		var tabs = [
			{name: "Stage", label: 'Stage'}
		];

		daUIBox = new FlxUITabMenu(null, null, tabs, null, true);

		daUIBox.resize(300, 400);
		daUIBox.x = FlxG.width / 2;
		daUIBox.y = 20;
		add(daUIBox);
    }

    function addStageStuff():Void {

    }
}