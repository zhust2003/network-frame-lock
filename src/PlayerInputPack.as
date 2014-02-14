package
{
	public class PlayerInputPack
	{
		public var frame:int = 0;
		public var input:Array;
		
		public function PlayerInputPack()
		{
		}
		
		public function get totalBytes():int {
			return 8;
		}
	}
}