package
{
	import org.flixel.*;
	import flash.geom.Rectangle;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.Point;
	
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/images/Pointer.png")] protected static var imgPointer:Class;

		private static var entities:FlxGroup;
		private static var cursor:FlxSprite;
		private var _fx:FlxSprite;
		private var blur:BlurFilter;
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			entities = new FlxGroup();
			entities.add(new PlayerShip());
			for (var i:uint = 0; i < 50; i++) entities.add(new Bullet());
			for (i = 0; i < 10; i++) entities.add(new Enemy());
			add(entities);
			
			cursor = new FlxSprite(FlxG.mouse.x, FlxG.mouse.x);
			cursor.loadGraphic(imgPointer);
			add(cursor);
			
			_fx = new FlxSprite();
			_fx.makeGraphic(FlxG.width, FlxG.height, 0, true);
			_fx.antialiasing = true;	//Set AA to true for maximum blurry
			_fx.blend = "screen";		//Set blend mode to "screen" to make the blurred copy transparent and brightening
			
			blur = new BlurFilter();
			blur.blurX = 8; 
			blur.blurY = 8; 
			blur.quality = BitmapFilterQuality.HIGH;
		}
		
		override public function update():void
		{	
			GameInput.update();
			
			super.update();
			cursor.x = FlxG.mouse.x;
			cursor.y = FlxG.mouse.y;
		}
		
		override public function draw():void
		{
			super.draw();
			
			_fx.stamp(FlxG.camera.screen);
			FlxG.camera.screen.pixels.applyFilter(FlxG.camera.screen.pixels, new Rectangle(0,0,FlxG.width,FlxG.height), new Point(0,0), blur);
			_fx.draw();
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