package
{
	import org.flixel.*;
	
	public class PointMass
	{
		public var position:FlxPoint;
		public var velocity:FlxPoint;
		public var acceleration:FlxPoint;
		public var inverseMass:Number;
		public var damping:Number;
		
		public function PointMass(X:Number, Y:Number, InverseMass:Number)
		{
			position = new FlxPoint(X, Y);
			velocity = new FlxPoint();
			acceleration = new FlxPoint();
			damping = 0.98;
			inverseMass = InverseMass;
		}
		
		public function ApplyForce(ForceX:Number, ForceY:Number):void
		{
			acceleration.x += ForceX * inverseMass;
			acceleration.y += ForceY * inverseMass;
		}
		
		public function IncreaseDamping(Factor:Number):void
		{
			damping *= Factor;
		}
		
		public function update():void
		{
			velocity.x += acceleration.x;
			velocity.y += acceleration.y;
			position.x += velocity.x;
			position.y += velocity.y;
			if (velocity.x * velocity.x + velocity.y * velocity.y < 0.001 * 0.001)
			{
				velocity.x = 0;
				velocity.y = 0;
			}
			velocity.x *= damping;
			velocity.y *= damping;
			damping = 0.98;
		}
	}
}