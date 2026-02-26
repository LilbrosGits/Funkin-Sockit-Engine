package funkin.obj.characters;

import assets.Cache;
import assets.Paths;
import objects.SockitSprite;

class Character extends SockitSprite
{
	public var isPlayer:Bool = false;
	public function new()
	{
		super(0, 0);
	}

	public function loadCharacterFile(folder:String)
	{
		var file:SpriteFile = null;
		file = Paths.getJson('data/characters/$folder/char');
		reloadCharacter(file);
	}

	public function reloadCharacter(spr:SpriteFile)
	{
		loadSpriteFile(spr);
	}

	public function dance() {
		if (!animList.exists('danceRight'))
			playAnim('idle');
		else {
			if (animList.exists('danceRight') && animation.curAnim != null && animation.curAnim.name == 'danceLeft')
				playAnim('danceRight');
			else
				playAnim('danceLeft');
		}
	}
}
