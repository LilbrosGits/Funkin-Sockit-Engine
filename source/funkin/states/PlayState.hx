package funkin.states;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.obj.*;
import funkin.system.*;
import funkin.ui.HUD;

class PlayState extends MusicBeat.MusicBeatState
{
	var playerStrums:Strumline;
	var dadStrums:Strumline;
	var player1:Character;
	var player2:Character;
	var hud:HUD;
	var health:Float = 50;
	override public function create()
	{
		player2 = new Character(100, 100, 'dad');//dad
		add(player2);

		player1 = new Character(770, 450, 'bf');//bf
		add(player1);

		playerStrums = new Strumline(0, 20, 1);
		add(playerStrums);

		dadStrums = new Strumline(0, 20, 0);
		add(dadStrums);

		hud = new HUD();
		add(hud);
		
		super.create();
	}

	override public function update(elapsed:Float)
	{
		hud.health = health;
		super.update(elapsed);
	}
}
