package
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class Player extends Sprite
	{
		private var r:int = 10;
		public var speed:Number = 150;
		public var power:Number = 100;
		public var velocity:Vector2;
		public var position:Vector2;
		public var acceleration:Vector2;
		public var modify:Vector2;
		private var smoothFactor:Number = 0.075;
		public var bound:Rectangle;
		public var scene:Scene;
		public var back:Boolean = false;
		
		// 立方平滑
		public var smoothTick:Number;
		public var smoothTime:Number;
		public var A:Number;
		public var B:Number;
		public var C:Number;
		public var D:Number;
		public var E:Number;
		public var F:Number;
		public var G:Number;
		public var H:Number;
		
		public function Player(scene:Scene, c:uint = 0x0)
		{
			draw(c);
			
			this.scene = scene;
			bound = new Rectangle(-r, -r, 2 * r, 2 * r);
			velocity = new Vector2();
			position = new Vector2();
			acceleration = new Vector2();
			modify = new Vector2();
		}
		
		public function draw(c:uint):void {
			this.graphics.clear();
			this.graphics.lineStyle(1, c);
			this.graphics.moveTo(-r, -r);
			this.graphics.lineTo(-r, r);
			this.graphics.lineTo(r, 0);
			this.graphics.lineTo(-r, -r);
			this.graphics.moveTo(r, 0);
			this.graphics.lineTo(-r, 0);
		}
		
		public function update():void {
			if (smoothTick > 0) {
				smoothTick -= Global.elapse / 1000;
				var dt:Number = 1 - smoothTick / smoothTime;
				position.x = A * dt * dt * dt + B * dt * dt + C * dt + D;
				position.y = E * dt * dt * dt + F * dt * dt + G * dt + H;
			} else {
				if (! acceleration.isZero()) {
					velocity.x += acceleration.x * Global.elapse / 1000;
					velocity.y += acceleration.y * Global.elapse / 1000;
				}
				if (! velocity.isZero()) {
					position.x += velocity.x * Global.elapse / 1000;
					position.y += velocity.y * Global.elapse / 1000;
				}
			}
				
			// 限制边界
			boundBehavior();
			
			// 修正值平滑
			modify.x *= (1 - smoothFactor);
			modify.y *= (1 - smoothFactor);
			
			// 显示位置
			x = position.x + modify.x;
			y = position.y + modify.y;
			
			// 更新角度
			if (velocity.lengthSQ > 0.00001) {
				rotation = MathUtil.toDegrees(velocity.angle);
			}
		}
		
		public function boundBehavior():void {
			if (position.x + bound.right > scene.bound.width) {
				position.x = scene.bound.width - bound.right;
			}
			if (position.x + bound.left < 0) {
				position.x = -bound.left;
			}
			if (position.y + bound.bottom > scene.bound.height) {
				position.y = scene.bound.height - bound.bottom;
			}
			if (position.y + bound.top < 0) {
				position.y = -bound.top;
			}
		}
	}
}