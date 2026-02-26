package assets;

import flixel.FlxG;
import haxe.Constraints.Function;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
#if sys
import sys.FileSystem as FileSys;
#end

/**
 * This is The FileSystem Class !!
 * 
 * it lets u do stuff with folders nd files nd shit lmfao
 * 
 * only for windows currently (ion know how to make mods work with html5 yet or anything else dat would need it)
 */
class FileSystem
{
	public var _file:FileReference;

	public static function readDir(dir:String):Array<String>
	{
		#if sys
		return FileSys.readDirectory(Paths.getPath(dir));
		#else
		trace('not on html whatttttt');
		return [];
		#end
	}

	public static function exists(dir:String)
	{
		#if sys
		if (FileSys.exists(Paths.getPath(dir)))
			return true;
		else
			return false;
		#else
		trace('not u on html whatttttt');
		#end
	}

	public static function isDir(dir:String)
	{
		#if sys
		if (FileSys.isDirectory(Paths.getPath(dir)))
			return true;
		else
			return false;
		#else
		trace('not u on html whatttttt');
		#end
	}

	private function saveFile(content:Dynamic, ext:String)
	{
		if (content != null)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(content, "file" + ext);
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	public function loadFile(ext:String)
	{
		var jsonFilter:FileFilter = new FileFilter(ext.toUpperCase(), ext);
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadError:Bool = false;
	public static var loadedFile:String = '';

	private function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			loadedFile = fullPath;
		}
		loadError = true;
		_file = null;
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}
}
