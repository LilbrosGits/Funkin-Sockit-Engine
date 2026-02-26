package funkin.meta.states;

import funkin.backend.inputs.PlayerSettings;
import funkin.backend.scripts.FunkinImport;
import meta.SockitState;

class GameState extends SockitState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):funkin.backend.inputs.Controls;

	inline function get_controls():funkin.backend.inputs.Controls
		return PlayerSettings.player1.controls;

	override public function loadScript() {
		FunkinImport.setImports(script);
		super.loadScript();
	}
	public function new(name:String = 'menus/MainMenu') {
		super(name);
		if (script != null) {
			script.set('super', this);
			script.set('Conductor', Conductor);
		}
	}

	override function create()
	{
		#if (!web)
		//TitleState.soundExt = '.ogg';
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		call('updateBeat', []);
	}

	private function updateCurStep():Void
	{
		curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
		call('updateStep', []);
	}

	public function stepHit():Void
	{
		call('onStep', []);
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		call('onBeat', []);
	}
}
