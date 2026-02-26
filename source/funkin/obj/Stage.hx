package funkin.obj;

import assets.Cache;
import assets.Paths;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import scripts.SockitScript;
import scripts.SockitScriptGroup;

class Stage extends FlxTypedGroup<FlxBasic>
{
	public var stageName:String = 'stage';
	public var script:SockitScriptGroup;

	public function new(stageName:String = 'stage')
	{
		super();
		stageName = this.stageName;
		script = new SockitScriptGroup('stages/$stageName');
		script.set('add', add);
		script.set('remove', remove);
	}

	public function loadStage()
	{
		script.execute();
		preLoad();
		onLoad();

		// bc ye
		onCreate();
		onCreatePost();
	}

	override public function destroy()
	{
		script.call('destroy', []);
		super.destroy();
	}

	override public function update(elapsed:Float)
	{
		onUpdate(elapsed);
		super.update(elapsed);
		onUpdatePost(elapsed);
	}

	public function preLoad()
	{
		script.call('preLoad', []);
	}

	public function onLoad()
	{
		script.call('onLoad', []);
	}

	public function onCreate()
	{
		script.call('onCreate', []);
	}

	public function onCreatePost()
	{
		script.call('onCreatePost', []);
	}

	public function onUpdate(elapsed:Float)
	{
		script.call('onUpdate', [elapsed]);
	}

	public function onUpdatePost(elapsed:Float)
	{
		script.call('onUpdatePost', [elapsed]);
	}
}
