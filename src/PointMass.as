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
		
		public function applyForce(ForceX:Number, ForceY:Number):void
		{
			acceleration.x += ForceX * inverseMass;
			acceleration.y += ForceY * inverseMass;
		}
		
		public function increaseDamping(Factor:Number):void
		{
			damping *= Factor;
		}
		
		public function update():void
		{
			velocity.x += acceleration.x;
			velocity.y += acceleration.y;
			position.x += velocity.x * FlxG.elapsed;
			position.y += velocity.y * FlxG.elapsed;
			acceleration.x = 0;
			acceleration.y = 0;
			if ((velocity.x * velocity.x + velocity.y * velocity.y) < (0.001 * 0.001))
			{
				velocity.x = 0;
				velocity.y = 0;
			}
			velocity.x *= damping;
			velocity.y *= damping;
			damping = 0.98;
		}
		
		/**
		 * Internal function for updating the position and speed of this object.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independenct motion.
		 */
		private function updateMotion():void
		{
			var delta:Number;
			var velocityDelta:Number;
			
			velocityDelta = (FlxU.computeVelocity(velocity.x, acceleration.x, Math.abs(damping * velocity.x)) - velocity.x)/2;
			velocity.x += velocityDelta;
			delta = velocity.x*FlxG.elapsed;
			velocity.x += velocityDelta;
			position.x += delta;
			
			velocityDelta = (FlxU.computeVelocity(velocity.y,acceleration.y, Math.abs(damping * velocity.y)) - velocity.y)/2;
			velocity.y += velocityDelta;
			delta = velocity.y*FlxG.elapsed;
			velocity.y += velocityDelta;
			position.y += delta;
		}
	}
}