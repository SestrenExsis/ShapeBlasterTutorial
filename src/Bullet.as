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
			radius = hitboxRadius = 10;
			width = height = 28;
			offset.y = 0.5 * (28 - 9);
			kill();
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			angle = angleInDegrees(velocity)
			if (!onScreen()) kill();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			cooldownTimer.stop();
			alpha = 1;
			acceleration.x = acceleration.y = 0;
			angularVelocity = 0;
			super.reset(X - 0.5 * width, Y - 0.5 * height);
		}
		
		override public function collidesWith(Object:Entity, Distance:Number):void
		{
			
		}
	}
}