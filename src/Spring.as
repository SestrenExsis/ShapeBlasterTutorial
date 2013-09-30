package
{
	import org.flixel.*;
	import PointMass;
	
	public class Spring
	{
		public var end1:PointMass;
		public var end2:PointMass;
		public var targetLength:Number;
		public var stiffness:Number;
		public var damping:Number;
		
		public function Spring(End1:PointMass, End2:PointMass, Stiffness:Number, Damping:Number)
		{
			end1 = End1;
			end2 = End2;
			stiffness = Stiffness;
			damping = Damping;
			targetLength = 0.95 * FlxU.getDistance(end1.position, end2.position);
		}
		
		public function update():void
		{
			var _x:Number = end1.position.x - end2.position.x;
			var _y:Number = end1.position.y - end2.position.y;
			
			var _length:Number = Math.sqrt(_x * _x + _y * _y)
			// these springs can only pull, not push
			if (_length <= targetLength)
				return;
			
			_x = (_x / _length) * (_length - targetLength);
			_y = (_y / _length) * (_length - targetLength);
			var _dvX:Number = end2.velocity.x - end1.velocity.x;
			var _dvY:Number = end2.velocity.y - end1.velocity.y;
			var _forceX:Number = stiffness * _x - _dvX * damping;
			var _forceY:Number = stiffness * _y - _dvY * damping;
			
			end1.ApplyForce(-_forceX, -_forceY);
			end2.ApplyForce(_forceX, _forceY);
		}
	}
}