package
{
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/images/Pointer.png")] protected static var imgPointer:Class;

		private static var entities:FlxGroup;
		private static var cursor:FlxSprite;
		
		public function ScreenState()
		{
			super();
			
			entities = new FlxGroup();
			entities.add(new PlayerShip());
			for (var i:uint = 0; i < 25; i++)
			{
				entities.add(new Bullet());
			}
			add(entities);
			
			cursor = new FlxSprite(FlxG.mouse.x, FlxG.mouse.x);
			cursor.loadGraphic(imgPointer);
			add(cursor);
		}
		
		override public function create():void
		{
			super.create();
		}
		
		override public function update():void
		{	
			GameInput.update();
			
			super.update();
			cursor.x = FlxG.mouse.x;
			cursor.y = FlxG.mouse.y;
		}
		
		public static function makeBullet(PositionX:Number, PositionY:Number, Angle:Number, Speed:Number):Boolean
		{
			var bullet:Bullet = Bullet(entities.getFirstAvailable(Bullet));
			if (bullet) 
			{
				bullet.reset(PositionX, PositionY);
				bullet.angle = Angle;
				bullet.velocity.x = Speed * Math.cos((Angle / 180) * Math.PI);
				bullet.velocity.y = Speed * Math.sin((Angle / 180) * Math.PI);
				return true;
			}
			else return false;
		}

	}
}