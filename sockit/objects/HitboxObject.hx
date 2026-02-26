package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class HitboxObject extends FlxSprite
{
	public var type:String = 'default';

	public function new(w, h, x, y, t)
	{
		super(x, y);
		updateBox(w, h, x, y, t);
	}

	public function updateBox(w, h, x, y, t)
	{
		this.x = x;
		this.y = y;
		makeGraphic(w, h, FlxColor.BLUE);

		switchType(t);

		#if debug
		alpha = 0.6;
		#else
		alpha = 0;
		#end
	}

	public function switchType(type:String)
	{
		this.type = type;
		switch (type)
		{
			case 'default':
				allowCollisions = ANY;
			case 'attack':
				allowCollisions = NONE;
				color = FlxColor.RED;
			default:
				allowCollisions = NONE;
		}
	}
}
