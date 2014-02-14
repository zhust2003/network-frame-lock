package
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * 虚拟客户端 
	 * @author Dalton
	 * 
	 */	
	public class Client
	{
		// 模拟收到的网络包
		public var packets:Vector.<PlayerInputPack>;
		
		public function Client()
		{
			packets = new Vector.<PlayerInputPack>();
		}
		
		public function send(p:PlayerInputPack):void {
			// 延迟加入队列
			var delayTime:int = MathUtil.rand(Global.delay - Global.range, Global.delay + Global.range);
			Global.bytes += p.totalBytes;
			
			setTimeout(sendNow(p), delayTime);
		}
		
		private function sendNow(p:PlayerInputPack):Function
		{
			return function():void {
				packets.push(p);
			}
		}
	}
}