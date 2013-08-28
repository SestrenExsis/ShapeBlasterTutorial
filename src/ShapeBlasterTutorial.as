package
{
	import org.flixel.FlxGame;
	[SWF(width="640", height="480", backgroundColor="#888888")]
	
	public class ShapeBlasterTutorial extends FlxGame
	{
		public function ShapeBlasterTutorial()
		{
			super(640, 480, ScreenState, 1.0, 60, 60, true);
			forceDebugger = true;
			useSystemCursor = false;
		}
	}
}