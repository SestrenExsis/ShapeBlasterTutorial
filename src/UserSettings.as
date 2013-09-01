package
{
	import org.flixel.*;
	
	public class UserSettings
	{
		private static var _save:FlxSave; //The FlxSave instance
		private static var _loaded:Boolean = false; //Did bind() work? Do we have a valid SharedObject?
		private static var _highScore:uint = 0;
		private static var _tempHighScore:uint;

		public static function get highScore():int
		{
			if (_loaded) return _save.data.highScore;
			else return _highScore;
		}
		
		public static function set highScore(value:int):void
		{
			if (_loaded) _save.data.highScore = value;
			else _tempHighScore = value;
		}

		public static function load():void
		{
			_save = new FlxSave();
			_loaded = _save.bind("ShapeBlasterSaveFile");
			
			if (_loaded)
			{
				//if (_save.data.levels == null) _save.data.levels = 0;
				if (_save.data.highScore == null) 
				{
					FlxG.log("loading default high score of 0 ...");
					_save.data.highScore = 0;
					PlayerShip.highScore = 0;
				}
				else 
				{
					FlxG.log("loading previous high score ...");
					_save.data.highScore = UserSettings.highScore;
					PlayerShip.highScore = UserSettings.highScore;
				}
			}
		}
		
		public static function save():void
		{
			_save.flush();
		}
	}
}