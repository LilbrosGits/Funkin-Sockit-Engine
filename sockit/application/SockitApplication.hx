package application;

import lime.app.Application;

typedef App =
{
	name:String,
	version:String,
	resolution:Int
}

class SockitApplication
{
	public static var name:String = 'SockitApp V.$version';
	public static var version:String = "0.0.0";
	public static var resolution:Int = 2;

	public static function parseApplicationFile(app:App)
	{
		name = app.name;
		version = app.version;
		Application.current.window.title = name;
		Application.current.meta.set('version', version);
		setResolution(app.resolution);
	}

	public static function setResolution(res:Int)
	{
		switch (res)
		{
			case 0:
				Application.current.window.width = 256;
				Application.current.window.height = 144;
			case 1:
				Application.current.window.width = 256;
				Application.current.window.height = 240;
			case 2:
				Application.current.window.width = 640;
				Application.current.window.height = 480;
			case 3:
				Application.current.window.width = 1280;
				Application.current.window.height = 720;
			case 4:
				Application.current.window.width = 1980;
				Application.current.window.height = 1080;
			case 5:
				Application.current.window.width = 2560;
				Application.current.window.height = 1440;
		}
	}

	public static function setWarning(title:String, error:String)
	{
		Application.current.window.alert(error, title);
	}
}
