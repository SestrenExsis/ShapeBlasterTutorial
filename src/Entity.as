package
{
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		protected var _type:uint;
		public var radius:Number = 0;
		public var hitboxRadius:Number = 0;
		public var moveSpeed:Number = 0;
		public var moveAcceleration:Number = 0;
		protected var cooldownTimer:FlxTimer;
		protected var _position:FlxPoint;
		protected var hitEdgeOfScreen:Boolean = false;
		public var cooldown:Number = 0.075;
		
		public function Entity(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			_position = new FlxPoint();
			
			blend = "screen";
			cooldownTimer = new FlxTimer();
			cooldownTimer.finished = true;
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		public function collidesWith(Object:Entity, Distance:Number):void
		{
			
		}
		
		public function clampToScreen():Boolean
		{
			var _wasClamped:Boolean = false;
			//clamp the position to be within the bounds of the screen
			if (x < 0) 
			{
				x = 0;
				_wasClamped = true;
			}
			else if (x + 2 * hitboxRadius > FlxG.width) 
			{
				x = FlxG.width - 2 * hitboxRadius;
				_wasClamped = true;
			}
			if (y < 0) 
			{
				y = 0;
				_wasClamped = true;
			}
			else if (y + 2 * hitboxRadius > FlxG.height) 
			{
				y = FlxG.height - 2 * hitboxRadius;
				_wasClamped = true;
			}
			return _wasClamped;
		}
		
		public function get position():FlxPoint
		{
			_position.x = x + radius;
			_position.y = y + radius;
			
			return _position;
		}
		
		public function set position(Value:FlxPoint):void
		{
			x = Value.x - radius;
			y = Value.y - radius;
			
			_position.x = Value.x;
			_position.y = Value.y;
		}
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(Value:uint):void
		{
			_type = Value;
		}
		
		public static function toRadians(AngleInDegrees:Number):Number
		{
			return ((90 + AngleInDegrees) * Math.PI) / 180;
		}
		
		public static function toDegrees(AngleInRadians:Number):Number
		{
			return (AngleInRadians * 180) / Math.PI;
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
		
		public static function interpolate(Value1:Number, Value2:Number, WeightOfValue2:Number):Number
		{
			return (Value1 + (Value2 - Value1) * WeightOfValue2);
		}
		
		public static function interpolateRGB(ColorA:uint, ColorB:uint, WeightOfColorB:Number):uint
		{
			var _r:int = interpolate(0xff & (ColorA >> 16), 0xff & (ColorB >> 16), WeightOfColorB);
			var _g:int = interpolate(0xff & (ColorA >> 8), 0xff & (ColorB >> 8), WeightOfColorB);
			var _b:int = interpolate(0xff & ColorA, 0xff & ColorB, WeightOfColorB);
			
			return (_r << 16) | (_g << 8) | _b;
		}
		
		/**
		 * Modified from http://www.therealjoshua.com/code/flex/calico/src/com/flashfactory/calico/utils/ColorMathUtil.as
		 * Converts Hue, Saturation, Value to RRGGBB format
		 * @Hue Angle between 0-360
		 * @Saturation Number between 0 and 1
		 * @Value Number between 0 and 1
		 */
		public static function HSVtoRGB(Hue:Number, Saturation:Number, Value:Number):uint
		{
			var hi:int = Math.floor(Hue/60) % 6;
			var f:Number = Hue/60 - Math.floor(Hue/60);
			var p:Number = (Value * (1 - Saturation));
			var q:Number = (Value * (1 - f * Saturation));
			var t:Number = (Value * (1 - (1 - f) * Saturation));
			
			var r:Number;
			var g:Number;
			var b:Number;
			switch(hi)
			{
				case 0: r = Value;	g = t;		b = p;		break;
				case 1: r = q; 		g = Value;	b = p;		break;
				case 2: r = p;		g = Value;	b = t;		break;
				case 3: r = p;		g = q;		b = Value;	break;
				case 4: r = t;		g = p;		b = Value;	break;
				case 5: r = Value;	g = p;		b = q;		break;
			}
			
			return Math.round(r * 255) << 16 | Math.round(g * 255) << 8 | Math.round(b * 255);
		}
	}
}