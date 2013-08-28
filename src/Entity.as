package
{
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		public var radius:Number = 0;
		
		public function Entity(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			
			blend = "screen";
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
	}
}