package
{
	import org.flixel.*;
	
	public class Bullet extends Entity
	{
		[Embed(source="../assets/images/Bullet.png")] protected static var imgBullet:Class;

		public function Bullet(X:Number = -1000, Y:Number = -1000)
		{
			super(X, Y);
			
			loadRotatedGraphic(imgBullet, 360, -1, true, true);
			kill();
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			if (!onScreen()) kill();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function collidesWith(Object:FlxObject):void
		{
			if (Object is Enemy) kill();
		}
	}
}