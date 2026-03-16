package meta;

import assets.Cache;
import assets.FileSystem;
import assets.Paths;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSubState;
import scripts.SockitScript;

class SockitSubState extends FlxSubState
{
	public static var stateName:String = 'State';

	public var script:SockitScript;

	public function new(stateName:String = 'data/scripts/menus/MainMenu') // the state name is used in debug !!
	{
		if (stateName != null)
			SockitState.stateName = stateName;
		else
			stateName = SockitState.stateName;

		trace(Paths.getPath('$stateName.hxc'));

		if (FileSystem.exists('$stateName.hxc'))
		{
			trace('has script');
			script = new SockitScript('$stateName');
			loadScript();
			script.execute();
		}
		else
		{
			script = null;
			trace('no script');
		}

		preLoad();
		super();
		onLoad();
	}

	public function loadScript() {
		script.set('switchState', switchState);
		script.set('add', add);
		script.set('remove', remove);
	}

	override public function destroy()
	{
		super.destroy();
	}

	override public function create()
	{
		onCreate();
		super.create();
		onCreatePost();
	}

	override public function update(elapsed:Float)
	{
		onUpdate(elapsed);
		super.update(elapsed);
		onUpdatePost(elapsed);

		if (FlxG.keys.justPressed.F5)
		{
			Cache.clearStoredMemory();
			Cache.clearUnusedMemory();
			FlxG.resetState();
		}
	}

	public function preLoad()
	{
		call('preLoad', []);
	}

	public function onLoad()
	{
		call('onLoad', []);
	}

	public function onCreate()
	{
		call('onCreate', []);
	}

	public function onCreatePost()
	{
		call('onCreatePost', []);
	}

	public function onUpdate(elapsed:Float)
	{
		call('onUpdate', [elapsed]);
	}

	public function onUpdatePost(elapsed:Float)
	{
		call('onUpdatePost', [elapsed]);
	}
	public function call(func:String, arg:Array<Dynamic>) {
		if (script != null && script.exists(func))
			script.call(func, arg);
	}

	public function switchState(stateName:String)
	{
		flixel.FlxG.switchState(new SockitState(stateName));
	}
}
