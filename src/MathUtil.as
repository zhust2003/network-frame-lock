package 
{
    public class MathUtil
    {
        public function MathUtil()
        {
        }
        
        public static function cosd(degrees:Number):Number {
            return Math.cos(toRadians(degrees));
        }
        
        public static function sind(degrees:Number):Number {
            return Math.sin(toRadians(degrees));
        }
        
        public static function toRadians(degrees:Number):Number {
            return degrees * Math.PI / 180;
        }
        
        public static function toDegrees(radians:Number):Number {
            return radians * 180 / Math.PI;
        }
        
        public static function clamp(v:Number, min:Number, max:Number):Number {
            return Math.min(Math.max(v, min), max);
        }
        
        public static function rand(min:int, max:int):int {
            return min + Math.floor(Math.random() * (max - min + 1));
        }
        
        public static function randf(min:Number, max:Number):Number {
            return min + Math.random() * (max - min);
        }
        
        public static function probability(v:uint):Boolean {
            return (rand(1, 100) <= v);
        }
        
        public static function getRandomElementOf(array:Array):* {
            var idx:int = rand(0, array.length - 1);
            return array[idx];
        }
		
		
		/**
		 * 三次埃尔米特样条 
		 * @param t
		 * @param p0 控制点1
		 * @param m0 切线1
		 * @param p1 控制点2
		 * @param m1 切线2
		 * @return 
		 * 
		 * http://en.wikipedia.org/wiki/Cubic_Hermite_spline
		 */		
		public function hermite(t:Number, p0:Vector2, m0:Vector2, p1:Vector2, m1:Vector2):Vector2 {
			var t2:Number = t * t;
			var t3:Number = t2 * t;
			var h1:Number = 2 * t3 - 3 * t2 + 1;
			var h2:Number = -2 * t3 + 3 * t2;
			var h3:Number = t3 - 2 * t2 + t;
			var h4:Number = t3 - t2;
			var v:Vector2 = new Vector2();
			v.x = p0.x * h1 + p1.x * h2 + m0.x * h3 + m1.x * h4;
			v.y = p0.y * h1 + p1.y * h2 + m0.y * h3 + m1.y * h4;
			return v;
		}
		
		/**
		 * 卡特莫尔-罗样条（不需要切线值，且经过所有控制点） 
		 * 最少需要4个控制点
		 * 与埃尔米特样条的结合
		 * @param t
		 * @param p0
		 * @param p1
		 * @return 
		 * 
		 */		
		public function catmullRom(t:Number, p0:Vector2, p1:Vector2, p2:Vector2, p3:Vector2):Vector2 {
			// 计算出所有切线
			// 一般切线取值为0.2
			var m1:Vector2 = tangent(p0, p2);
			var m2:Vector2 = tangent(p1, p3);
			
			return hermite(t, p1, m1, p2, m2);
		}
		
		/**
		 * 卡特莫尔-罗样条（直接公式法） 
		 * 取值0.5
		 * @param t
		 * @param p0
		 * @param p1
		 * @param p2
		 * @param p3
		 * @return 
		 * 
		 * 公式验证
		 * http://www.cs.cmu.edu/~fp/courses/graphics/asst5/catmullRom.pdf
		 */		
		public function catmullRom2(t:Number, p0:Vector2, p1:Vector2, p2:Vector2, p3:Vector2):Vector2 {
			var t2:Number = t * t;
			var t3:Number = t2 * t;
			var v:Vector2 = new Vector2();
			v.x = 0.5 * (2 * p1.x +
				(-p0.x + p2.x) * t +
				(2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 + 
				(-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3);
			v.y = 0.5 * (2 * p1.y +
				(-p0.y + p2.y) * t +
				(2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 + 
				(-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3);
			
			return v;
		}
		
		/**
		 * 二次贝塞尔曲线
		 * @param t
		 * @param p0
		 * @param p1
		 * @param p2
		 * 
		 */		
		public function quadBezier(t:Number, p0:Vector2, p1:Vector2, p2:Vector2):Vector2 {
			var v:Vector2 = new Vector2();
			var t2:Number = t * t;
			var oneMinusTSQ:Number = (1 - t) * (1 - t);
			v.x = oneMinusTSQ * p0.x + 2 * (1 - t) * t * p1.x + t2 * p2.x;
			v.y = oneMinusTSQ * p0.y + 2 * (1 - t) * t * p1.y + t2 * p2.y;
			
			return v;
		}
		
		public function tangent(p1:Vector2, p2:Vector2):Vector2 {
			return p2.sub(p1).multiply(0.5);
		}
    }
}