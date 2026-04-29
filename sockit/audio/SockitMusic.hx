package audio;

import assets.Paths;
import flixel.FlxG;
import flixel.sound.FlxSound;

using StringTools;

typedef Audio =
{
	name:String,
	assetPath:String,
	effects:Array<AudioEffect>
}

typedef Music =
{
	authors:String,
	audio:Audio,
	bpm:Float,
	loop:Bool,
}

typedef AudioEffect =
{
	time:Float,
	effect:String,
	value:Dynamic
}

class SockitMusic extends FlxSound
{
	public var audioName:String = 'nullAudio';

	public var audio:FlxSound;

	public var effects:Map<String, AudioEffect> = [];

	public function new()
	{
		super();
		audio = new FlxSound();
	}

	public function parseAudio(sound:Audio)
	{
		audioName = sound.name;
		audio.loadEmbedded(Paths.getSnd(sound.assetPath));
		// loopTime = this.endTime;
		for (i in sound.effects)
		{
			parseEffect(i);
		}
	}

	public function parseMusic(music:Music)
	{
		audioName = music.audio.name;
		if (FlxG.sound.music == null)
		{
			FlxG.sound.music = new FlxSound();
		}
		FlxG.sound.music.loadEmbedded(Paths.getSnd(music.audio.assetPath));
		// loopTime = this.endTime;
		for (i in music.audio.effects)
		{
			parseEffect(i);
		}
	}

	public function playMusic()
	{
		FlxG.sound.music.play();
	}

	public function playAudio()
	{
		audio.play();
	}

	public function pauseMusic()
	{
		FlxG.sound.music.pause();
	}

	public function pauseAudio()
	{
		audio.pause();
	}

	public function parseEffect(afct:AudioEffect)
	{
		var effect:AudioEffect = {
			time: afct.time,
			effect: (afct.effect == null) ? "volume" : afct.effect,
			value: afct.value
		}
		effects.set('${afct.time}', effect);
		trace('at ${Std.int(afct.time)}, ${effect}');
	}

	override public function update(elapsed:Float)
	{
		for (i in effects.keys())
		{
			if (FlxG.sound.music.time >= Std.parseFloat(i))
			{
				executeEffect(FlxG.sound.music.time);
			}
		}

		super.update(elapsed);
	}

	public function executeEffect(time:Float)
	{
		trace('exexcuting effect ${effects.get('$time').effect}');

		switch (effects.get('$time').effect)
		{
			case "pitch":
				FlxG.sound.music.pitch = (effects.get('$time').value);
			case "volume":
				FlxG.sound.music.volume = (effects.get('$time').value);
			case "fadeIn":
				FlxG.sound.music.fadeIn(effects.get('$time').value.split(',')[0], time, effects.get('$time').value.split(',')[1]);
		}
	}
}
