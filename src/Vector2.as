package 
{
	/**
	 * 简单的2d向量类 
	 * @author Dalton
	 * 
	 */	
	public class Vector2
	{
		public var x:Number;
		public var y:Number;
		
		public function Vector2(x:Number = 0, y:Number = 0)
		{
			this.x = x;
			this.y = y;
		}
		
		public function set(x:Number, y:Number):Vector2 {
			this.x = x;
			this.y = y;
			
			return this;
		}
		
		public function copy(v:Vector2):Vector2 {
			this.x = v.x;
			this.y = v.y;
			
			return this;
		}
		
		public function add(v:Vector2):Vector2 {
			this.x += v.x;
			this.y += v.y;
			
			return this;
		}
		
		public function addVectors(a:Vector2, b:Vector2):Vector2 {
			this.x = a.x + b.x;
			this.y = a.y + b.y;
			
			return this;
		}
		
		public function sub(v:Vector2):Vector2 {
			this.x -= v.x;
			this.y -= v.y;
			
			return this;
		}
		
		public function subVectors(a:Vector2, b:Vector2):Vector2 {
			this.x = a.x - b.x;
			this.y = a.y - b.y;
			
			return this;
		}
		
		public function dot(v:Vector2):Number {
			return this.x * v.x + this.y * v.y;
		}
		
		public function multiply(s:Number):Vector2 {
			this.x *= s;
			this.y *= s;
			
			return this;
		}
		
		public function divide(s:Number):Vector2 {
			this.x /= s;
			this.y /= s;
			
			return this;
		}
		
		public function normalize():Vector2 {
			return divide(length);
		}
		
		public function get lengthSQ():Number {
			return this.x * this.x + this.y * this.y;
		}
		
		public function isZero():Boolean {
			return this.x == 0 && this.y == 0;
		}
		
		public function set angle(value:Number):void {
			var len:Number = length;
			x = Math.cos(value) * len;
			y = Math.sin(value) * len;
		}
		
		public function get angle():Number {
			return Math.atan2(y, x);
		}
		
		public function get length():Number {
			return Math.sqrt(lengthSQ);
		}
		
		public function set length(value:Number):void {
			var a:Number = angle;
			x = Math.cos(a) * value;
			y = Math.sin(a) * value;
		}
		
		public function distSQ(v:Vector2):Number {
			var dx:Number = v.x - x;
			var dy:Number = v.y - y;
			return dx * dx + dy * dy;
		}
		
		public function dist(v:Vector2):Number {
			return Math.sqrt(distSQ(v));
		}
		
		public function clone():Vector2 {
			return new Vector2(x, y);
		}
		
		
		public function toString():String
		{
			return "[Vector2 (x:" + x + ", y:" + y + ")]";
		}
	}
}