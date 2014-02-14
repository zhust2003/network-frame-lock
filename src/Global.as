package
{
	import flash.utils.getTimer;

	public class Global
	{
		public static var elapse:Number = 0;
		public static var lastTime:Number = getTimer();
		public static var bytes:Number = 0;
		
		public static var delay:Number = 50;
		public static var range:Number = 5;
		public static var fps:int;
		
		public static var frame:int = 0;
		
		public function Global()
		{
		}
	}
}