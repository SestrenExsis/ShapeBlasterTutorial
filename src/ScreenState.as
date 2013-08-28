package
{
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		private static var entities:FlxGroup;
		
		public function ScreenState()
		{
			super();
			
			entities = new FlxGroup();
			entities.add(new PlayerShip());
			for (var i:uint = 0; i < 100; i++)
			{
				entities.add(new Bullet());
			}
			
			add(entities);
		}
		
		override public function create():void
		{
			super.create();
		}
		
		override public function update():void
		{	
			GameInput.update();
			
			super.update();
		}
		
		public static function makeBullet(PositionX:Number, PositionY:Number, VelocityX:Number, VelocityY:Number):Boolean
		{
			var bullet:Bullet = Bullet(entities.getFirstAvailable(Bullet));
			if (bullet) 
			{
				bullet.reset(PositionX, PositionY);
				bullet.velocity.x = VelocityX;
				bullet.velocity.y = VelocityY;
				return true;
			}
			else return false;
		}

	}
}