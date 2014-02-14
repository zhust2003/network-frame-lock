package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Scene extends Sprite
	{
		public var bound:Rectangle = new Rectangle(0, 0, 300, 300);
		public var player:Player;
		public var info:TextField;
		
		public function Scene()
		{
			super();
			
			// 绘制边界
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x0);
			this.graphics.drawRect(bound.x, bound.y, bound.width, bound.height);
			
			
			
		 	info = new TextField();
			info.x = 0;
			info.y = 300;
			info.width = bound.width;
			info.autoSize = TextFieldAutoSize.CENTER;
			addChild(info);
		}
		
		public function update():void {
			player.update();
		}
	}
}