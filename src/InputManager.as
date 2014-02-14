package 
{
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	

	/**
	 * 这个类可以得到所有的输入信息，如键盘键入信息，鼠标位置信息等
	 * @author Dalton
	 */
	public class InputManager
	{
		public var keysHit:Array;
		public var keyStatus:Array;
		
        public var mousex:int;
        public var mousey:int;
        public var mouseStatus:int;
        public var mouseButtonHit:int;

		public var last:FocusEvent;
        
        public static var instance:InputManager = new InputManager();
		
		public function InputManager() 
		{
		}
        
        public function init(area:InteractiveObject):void 
        {
            keyStatus = [];
            keysHit = [];
            area.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            area.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            area.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            area.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            area.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			// 失去焦点事件处理
//            area.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
        }
		
        public function keyDownHandler(e:KeyboardEvent):void
        {
			if (keyStatus[e.keyCode] != true) {
            	keysHit[e.keyCode] = true;
			}
			keyStatus[e.keyCode] = true;
            return;
        }
		
        public function keyUpHandler(e:KeyboardEvent):void
        {
            keyStatus[e.keyCode] = false;
			
			if(!e.ctrlKey){
				keyStatus[Keyboard.CONTROL] = false;
			}
			if(!e.shiftKey){
				keyStatus[Keyboard.SHIFT] = false;
			}
            return;
        }
		
        public function mouseDownHandler(e:MouseEvent):void
        {
            mouseStatus = 1;
            mouseButtonHit = 1;
            return;
        }
		
        public function mouseUpHandler(e:MouseEvent):void
        {
            mouseStatus = 0;
            return;
        }

        public function mouseMoveHandler(e:MouseEvent):void
        {
            mousex = e.stageX;
            mousey = e.stageY;
            return;
        }

        public function focusOutHandler(e:FocusEvent):void
        {
			clear();
        }

        public function mouseX():int
        {
            return mousex;
        }

        public function mouseY():int
        {
            return mousey;
        }

        public function keyDown(key:int):int
        {
            return keyStatus[key];
        }

        public function keyDownArray(keyArray:Array):Boolean
        {
			// 复制数组
			var keyArray:Array = keyArray.slice();
			var status:Boolean = true;
			for each (var key:int in keyArray) {
				status = keyStatus[key];
				if (! status) {
					return status;
				}
			}
			return status;
        }
        
        public function clear():void {
            keyStatus = [];
            keysHit = [];
			mouseStatus = 0;
			mouseButtonHit = 0;
        }


        public function mouseDown():int
        {
            return mouseStatus;
        }


        public function keyHit(key:int, keyup:Boolean = true):int
        {
            var status:int;
            status = keysHit[key];
            if (keyup)
            {
                keysHit[key] = false;
            }
            return status;
        }

        public function mouseHit():int
        {
            var mouseHitStatus:int = mouseButtonHit;
            mouseButtonHit = 0;
            return mouseHitStatus;
        }

	}

}