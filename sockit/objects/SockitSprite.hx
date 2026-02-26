package objects;

import flixel.FlxG;
import animate.FlxAnimate;
import animate.FlxAnimateFrames;
import application.SockitApplication;
import assets.Paths;
// import flixel-animate.
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

typedef SpriteFile =
{
	name:String,
	version:String,
	?transform:Transform,
	?hitboxes:Array<Hitbox>,
	renderType:String,
	assetPath:String,
	anims:Array<Anim>
}

typedef Transform =
{
	pos:Array<Int>,
	?width:Int,
	?height:Int,
	?scale:Array<Float>,
	?angle:Int
}

typedef Anim =
{
	name:String,
	?xmlName:String,
	?frames:Array<Int>,
	?indices:Array<Int>,
	?frameRate:Int,
	?offsets:Array<Float>,
	?assetPath:String,
	?transform:Transform,
	?loop:Bool,
	?flipX:Bool,
	?flipY:Bool,
	?postFix:String,
	?framedata:Array<FrameData>
}

typedef Hitbox =
{
	type:String,
	size:Array<Int>,
	angle:Int,
	offset:Array<Float>
}

typedef FrameData =
{
	duration:Int,
	?transform:Transform,
	?hitboxes:Array<Hitbox>
}

class SockitSprite extends FlxAnimate
{
	public var spriteFile:SpriteFile = null;

	public var animList:Map<String, Anim> = [];

	public var hitboxGrp:FlxTypedSpriteGroup<HitboxObject>;

	public function new(x:Float, y:Float)
	{
		super(x, y, null);
		hitboxGrp = new FlxTypedSpriteGroup<HitboxObject>(x, y);
	}

	public function setSparrowAtlas(str:String)
	{
		frames = Paths.loadSparrow(str);
		// frames = FlxAnimateFrames.fromSparrow(Paths.getPath(str + '.xml'), Paths.getImg(str));
	}

	public function setImage(str:String)
	{
		loadGraphic(Paths.getImage(str));
	}

	public function setTextureAtlas(str:String)
	{
		frames = FlxAnimateFrames.fromAnimate(Paths.getPath(str));
	}

	public function loadSpriteFile(sprite:SpriteFile)
	{
		switch (sprite.version) // for version handling cs ik sm shit getting changed
		{
			case "0.0.0": // if your on the CURRENT version it does this vro <3
				if (sprite != null)
				{
					spriteFile = {
						name: sprite.name,
						transform: sprite.transform,
						hitboxes: sprite.hitboxes,
						version: sprite.version,
						renderType: sprite.renderType,
						assetPath: sprite.assetPath,
						anims: sprite.anims
					};
				}
				// PARSING SPRITE BASED ON RENDER TYPE
				switch (spriteFile.renderType)
				{
					case "multisparrow": // multisparrow allows for you to use more than one asset per animation
						setSparrowAtlas(spriteFile.assetPath); // dont worry dis is da default asset path
						for (anim in spriteFile.anims)
						{
							animList.set(anim.name, anim);

							/*// set animation by prefix or indices if you have them
								if (anim.xmlName != null && anim.assetPath == null)
								{
									// set animations by indices
										if (anim.indices != null || anim.indices != [] || anim.indices.length >= 0)
										{
											// this gets kinda messy but it kinda works i hope...
											animation.addByIndices(anim.name, anim.xmlName, (anim.indices != null) ? anim.indices : [],
												(anim.postFix != null) ? anim.postFix : '', (anim.frameRate != null) ? anim.frameRate : 24,
												(anim.loop != null) ? anim.loop : false, (anim.flipX != null) ? anim.flipX : false,
												(anim.flipY != null) ? anim.flipY : false);
										} // if not then it should just get a prefix
										else if (anim.indices != null || anim.indices == [])
										{ 
									// this is less messy?
									animation.addByPrefix(anim.name, anim.xmlName, (anim.frameRate != null) ? anim.frameRate : 24,
										(anim.loop != null) ? anim.loop : false, (anim.flipX != null) ? anim.flipX : false,
										(anim.flipY != null) ? anim.flipY : false);
									}
							}*/
						}
					case "sparrow":
						setSparrowAtlas(spriteFile.assetPath); // dont worry dis is da default asset path
						for (anim in spriteFile.anims)
						{
							animList.set(anim.name, anim);

							// set animation by prefix or indices if you have them
							/*if (anim.xmlName != null)
								animation.addByPrefix(anim.name, anim.xmlName, (anim.frameRate != null) ? anim.frameRate : 24,
									(anim.loop != null) ? anim.loop : false, (anim.flipX != null) ? anim.flipX : false,
									(anim.flipY != null) ? anim.flipY : false); */
						}
					// finally done with that animation shit!!!!
					case "image": // just allows you to make an image
						loadGraphic(Paths.getImage(spriteFile.assetPath), spriteFile.anims != null ? true : false, spriteFile.transform.width,
							spriteFile.transform.height);
						for (anim in spriteFile.anims)
						{
							/*animList.set(anim.name, anim);
								animation.add(anim.name, anim.frames, (anim.frameRate != null) ? anim.frameRate : 24, (anim.loop != null) ? anim.loop : false,
									(anim.flipX != null) ? anim.flipX : false, (anim.flipY != null) ? anim.flipY : false); */
						}
					case "multiimage": // just allows you to make an image
						loadGraphic(Paths.getImage(spriteFile.assetPath), spriteFile.anims != null ? true : false, spriteFile.transform.width,
							spriteFile.transform.height);
						for (anim in spriteFile.anims)
						{
							animList.set(anim.name, anim);
							/*if (animList.get(anim.name).assetPath == null)
								{
									animation.add(anim.name, anim.frames, (anim.frameRate != null) ? anim.frameRate : 24, (anim.loop != null) ? anim.loop : false,
										(anim.flipX != null) ? anim.flipX : false, (anim.flipY != null) ? anim.flipY : false);
							}*/
						}
					case 'textureatlas' | 'tatlas' | 'texture':
						setTextureAtlas(spriteFile.assetPath); // dont worry dis is da default asset path
						for (anim in spriteFile.anims)
						{
							animList.set(anim.name, anim);

							// set animation by prefix or indices if you have them
							/*if (anim.xmlName != null)
								animation.addByPrefix(anim.name, anim.xmlName, (anim.frameRate != null) ? anim.frameRate : 24,
									(anim.loop != null) ? anim.loop : false, (anim.flipX != null) ? anim.flipX : false,
									(anim.flipY != null) ? anim.flipY : false); */
						}
					default: // no render type ig
						SockitApplication.setWarning('JSON Rendering Error', 'No Specified Render Type');
				}
				// now parse da transform if it exists
				if (spriteFile.transform != null)
				{
					loadTransform(spriteFile.transform);
				}
		}
	}

	public function addAnimation(animName:String, anim:Anim)
	{
		animList.set(anim.name, anim);
	}

	public function loadTransform(trans:Transform)
	{
		if (trans.pos != null)
		{
			x = trans.pos[0];
			y = trans.pos[1];
		}
		if (trans.width != null)
		{
			width = (trans.scale != null) ? trans.width * trans.scale[0] : trans.width;
		}

		if (trans.height != null)
		{
			width = (trans.scale != null) ? trans.height * trans.scale[1] : trans.height;
		}

		if (trans.scale != null)
		{
			scale.set(trans.scale[0], trans.scale[1]);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function playAnim(name:String, force:Bool = false)
	{
		if (animList.exists(name))
		{
			offset.set(animList.get(name).offsets[0], animList.get(name).offsets[1]);
			switch (spriteFile.renderType)
			{
				case 'multisparrow':
					if (animList.get(name).transform != null)
					{
						loadTransform(animList.get(name).transform);
					}
					if (animList.get(name).assetPath != null && animList.get(name).assetPath != '')
					{
						setSparrowAtlas(animList.get(name).assetPath);
					}
					if (!animation.exists(name))
					{
						animation.addByPrefix(animList.get(name).name, animList.get(name).xmlName,
							(animList.get(name).frameRate != null) ? animList.get(name).frameRate : 24,
							(animList.get(name).loop != null) ? animList.get(name).loop : false,
							(animList.get(name).flipX != null) ? animList.get(name).flipX : false,
							(animList.get(name).flipY != null) ? animList.get(name).flipY : false);
					}

					animation.play(name, force);

				case 'sparrow':
					if (!animation.exists(name))
					{
						animation.addByPrefix(animList.get(name).name, animList.get(name).xmlName,
							(animList.get(name).frameRate != null) ? animList.get(name).frameRate : 24,
							(animList.get(name).loop != null) ? animList.get(name).loop : false,
							(animList.get(name).flipX != null) ? animList.get(name).flipX : false,
							(animList.get(name).flipY != null) ? animList.get(name).flipY : false);
					}
					animation.play(name, force);
				case 'multiimage':
					if (animList.get(name).transform != null)
					{
						loadTransform(animList.get(name).transform);
					}
					loadGraphic(Paths.getImage(animList.get(name).assetPath), spriteFile.anims != null ? true : false,
						animList.get(name).transform != null ? animList.get(name).transform.width : spriteFile.transform.width,
						animList.get(name).transform != null ? animList.get(name).transform.height : spriteFile.transform.height);
					if (!animation.exists(name))
					{
						animation.add(animList.get(name).name, animList.get(name).frames,
							(animList.get(name).frameRate != null) ? animList.get(name).frameRate : 24,
							(animList.get(name).loop != null) ? animList.get(name).loop : false,
							(animList.get(name).flipX != null) ? animList.get(name).flipX : false,
							(animList.get(name).flipY != null) ? animList.get(name).flipY : false);
					}

					animation.play(name, force);
				case 'textureatlas' | 'tatlas' | 'texture':
					if (animList.get(name).transform != null)
					{
						loadTransform(animList.get(name).transform);
					}
					if (!animation.exists(name))
					{
						anim.addBySymbol(animList.get(name).name, animList.get(name).xmlName,
							(animList.get(name).frameRate != null) ? animList.get(name).frameRate : 24,
							(animList.get(name).loop != null) ? animList.get(name).loop : false,
							(animList.get(name).flipX != null) ? animList.get(name).flipX : false,
							(animList.get(name).flipY != null) ? animList.get(name).flipY : false);
					}
					if (anim != null)
						anim.play(name, force);
				default:
					animation.play(name, force);
			}
		}
		else
		{
			for (i in spriteFile.anims)
			{
				addAnimation(i.name, i);
				if (i.name == name)
					offset.set(i.offsets[0], i.offsets[1]);
				if (i.name == name && i.framedata != null)
					animList.get(name).framedata = i.framedata;
				playAnim(i.name);
			}
		}
	}

	public function updateAssetPath()
	{
		if (spriteFile != null)
		{
			switch (spriteFile.renderType)
			{
				case 'sparrow':
					if (assets.FileSystem.exists(spriteFile.assetPath + '.png') &&  assets.FileSystem.exists(spriteFile.assetPath + '.xml'))
						setSparrowAtlas(spriteFile.assetPath);
					if (spriteFile.transform != null)
					{
						loadTransform(spriteFile.transform);
					}
				case 'image':
					if (sys.FileSystem.exists(Paths.getImage(spriteFile.assetPath)))
						loadGraphic(Paths.getImage(spriteFile.assetPath));
					if (spriteFile.transform != null)
					{
						loadTransform(spriteFile.transform);
					}
				case 'textureatlas' | 'tatlas' | 'texture':
					if (sys.FileSystem.exists(Paths.getPath(spriteFile.assetPath)))
						setTextureAtlas(spriteFile.assetPath);
					if (spriteFile.transform != null)
					{
						loadTransform(spriteFile.transform);
					}
			}
		}
	}

	override public function updateAnimation(elapsed:Float)
	{
		super.updateAnimation(elapsed);
		if (animation.curAnim != null && anim.curAnim != null)
		{
			if (animList.get(anim.curAnim.name).framedata != null)
			{
				for (data in animList.get(anim.curAnim.name).framedata)
				{
					if (anim.curAnim.curFrame <= data.duration)
					{
						parseFrameData(data);
					}
				}
			}
		}
	}

	override public function destroy()
	{
		spriteFile = null;
		anim = null;
		super.destroy();
	}

	public function parseFrameData(data:FrameData)
	{
		if (data.hitboxes != null)
		{
			while (hitboxGrp.members.length > 0)
			{
				hitboxGrp.remove(hitboxGrp.members[0], true);
			}
			for (box in data.hitboxes)
			{
				var hitbox:HitboxObject = new HitboxObject(box.size[0], box.size[1], box.offset[0], box.offset[1], box.type);
				hitboxGrp.add(hitbox);
			}
		}
	}
}
