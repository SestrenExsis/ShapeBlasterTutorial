package
{
	import org.flixel.*;
	
	public class PlayerShip extends Entity
	{
		[Embed(source="../assets/images/Player.png")] protected static var imgPlayer:Class;
		
		public var speed:Number = 480;
		public var bulletSpeed:Number = 660;
		protected var aim:FlxPoint;
		
		public static var instance:PlayerShip;

		public function PlayerShip()
		{
			super(0.5 * FlxG.width, 0.5 * FlxG.height);
			
			loadRotatedGraphic(imgPlayer, 8, -1, true, true);
			radius = 10;
			aim = new FlxPoint();
			instance = this;
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			velocity = GameInput.move;
			velocity.x *= speed;
			velocity.y *= speed;
			if (velocity.x != 0 || velocity.y != 0) angle = angleInDegrees(velocity);
			
			aim = GameInput.aim;
			if (cooldownTimer.finished && (aim.x != 0 || aim.y != 0)) shoot(aim);
		}
		
		override public function postUpdate():void
		{
			super.postUpdate();
			
			//clamp the position to be within the bounds of the screen
			if (x < 0) x = 0;
			else if (x + width > FlxG.width) x = FlxG.width - width;
			if (y < 0) y = 0;
			else if (y + height > FlxG.height) y = FlxG.height - height;
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function collidesWith(Object:FlxObject):void
		{
			if (Object is Enemy) kill();
		}
		
		public function shoot(Aim:FlxPoint):void
		{
			cooldownTimer.stop();
			cooldownTimer.start(cooldown);
			
			var RandomSpread:Number = 4.58366236 * (FlxG.random() + FlxG.random()) - 4.58366236;
			
			if (GameInput.aimWithMouse)
			{
				Aim.x -= x;
				Aim.y -= y;
				Aim.y *= -1;
			}
			
			FlxU.rotatePoint(Aim.x, Aim.y, 0, 0, RandomSpread, Aim);
			
			var Angle:Number = angleInDegrees(Aim);
			FlxU.rotatePoint(8, 25, 0, 0, Angle + 90, _point);
			var PositionX:Number = _point.x + position.x;
			var PositionY:Number = _point.y + position.y;
			ScreenState.makeBullet(PositionX, PositionY, Angle, bulletSpeed);
			
			FlxU.rotatePoint(-8, 25, 0, 0, Angle + 90, _point);
			PositionX = _point.x + position.x;
			PositionY = _point.y + position.y;
			ScreenState.makeBullet(PositionX, PositionY, Angle, bulletSpeed);
		}
		
		public static function toDegrees(AngleInRadians:Number):Number
		{
			return (AngleInRadians * Math.PI) / 180;
		}
		
		public static function angleInDegrees(Vector:FlxPoint):Number
		{
			var _angleInRadians:Number = Math.atan2(Vector.y, Vector.x);
			return (_angleInRadians / Math.PI) * 180;
		}
		
		public static function angleInRadians(Vector:FlxPoint):Number
		{
			return Math.atan2(Vector.y, Vector.x);
		}
		
		public function setAimFromPolar(Angle:Number, Magnitude:Number):void
		{
			aim.x = Magnitude * Math.cos(Angle);
			aim.y = Magnitude * Math.sin(Angle);
		}
	}
}