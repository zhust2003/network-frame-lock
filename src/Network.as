package
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	[SWF(frameRate="60", width="701", height="450", backgroundColor="#FFFFFF")]
	public class Network extends Sprite
	{
		private var localScene:Scene;
		private var netScene:Scene;
		private var localPlayer:Player;
		private var client:Client;
		private var netPlayer:Player;
		private var lastState:PlayerStatePack;
		private var lastStateTime:int;
		private var bpsTf:TextField;
		private var delayInput:InputText;
		private var delayRangeInput:InputText;
		private var sendMethodCb:ComboBox;
		private var smoothMethodCb:ComboBox;
		private var mergeSceneCb:CheckBox;
		
		public function Network()
		{
			init();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			InputManager.instance.init(stage);
		}
		
		public function init():void {
			client = new Client();
			
			// 本地场景
			localScene = new Scene();
			localScene.x = 10;
			localScene.y = 10;
			localPlayer = new Player(localScene);
			localPlayer.position.x = 10;
			localPlayer.position.y = 7;
			localScene.player = localPlayer;
			localScene.addChild(localPlayer);
			localScene.info.text = '本地';
			addChild(localScene);
			
			// 网络场景
			netScene = new Scene();
			netScene.x = 390;
//			netScene.x = 10;
			netScene.y = 10;
			netPlayer = new Player(netScene, 0xFF0000);
			netPlayer.position.x = 10;
			netPlayer.position.y = 7;
			netScene.player = netPlayer;
			netScene.addChild(netPlayer);
			netScene.info.text = '网络';
			addChild(netScene);
			
			var tf:TextField = new TextField();
			tf.x = 10;
			tf.y = 330;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = '说明：此例子为客户端预测同步算法，\n左边为本地场景，右边为延迟后的某玩家看到的网络场景。\n方向键控制方向移动';
			addChild(tf);
			
			bpsTf = new TextField();
			bpsTf.x = 10;
			bpsTf.y = 390;
			bpsTf.autoSize = TextFieldAutoSize.LEFT;
			bpsTf.text = '';
			addChild(bpsTf);
			
			new Label(this, 500, 330, '延迟：');
			delayInput = new InputText(this, 580, 330, Global.delay.toString());
			delayInput.addEventListener(Event.CHANGE, onChangeDelay);
			
			new Label(this, 500, 350, '延迟波动：');
			delayRangeInput = new InputText(this, 580, 350, Global.range.toString());
			delayRangeInput.addEventListener(Event.CHANGE, onChangeDelayRange);
			
			mergeSceneCb = new CheckBox(this, 385, 350, '场景合并查看', onMergeScene);
			
			new Label(this, 280, 373, '更新状态方案：');
			var updateMethods:Array = [{label:'实时更新', value:0}, 
										{label:'状态更新', value:1}, 
										{label:'航位预测', value:2}];
			sendMethodCb = new ComboBox(this, 380, 370, "选择更新状态方案", updateMethods);
			sendMethodCb.addEventListener(Event.SELECT, onSelectSendMethod);
			sendMethodCb.selectedIndex = 2;
			
			new Label(this, 500, 373, '平滑方案：');
			var smoothMethods:Array = [{label:'无', value:0}, 
										{label:'指数平滑', value:1}, 
										{label:'立方平滑', value:2}];
			smoothMethodCb = new ComboBox(this, 580, 370, "选择平滑方案", smoothMethods);
			smoothMethodCb.addEventListener(Event.SELECT, onSmoothMethod);
			smoothMethodCb.selectedIndex = 1;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			setInterval(onTimer, 1000);
		}
		
		private function onMergeScene(e:Event):void
		{
			if (mergeSceneCb.selected) {
				netScene.x = 10;
				netScene.y = 10;
				netScene.alpha = 0.5;
			} else {
				netScene.x = 390;
				netScene.y = 10;
				netScene.alpha = 1;
			}
		}
		
		protected function onSmoothMethod(event:Event):void
		{
		}
		
		protected function onSelectSendMethod(event:Event):void
		{
		}
		
		protected function onChangeDelayRange(event:Event):void
		{
			Global.range = Number(delayRangeInput.text);
			fixDelayNumber();
		}
		
		protected function onChangeDelay(event:Event):void
		{
			fixDelayNumber();
		}
		
		public function fixDelayNumber():void {
			var delay:Number = Number(delayInput.text);
			
			if (delay < Global.range) {
				delay = Global.range;
				delayInput.text = delay.toString();
			}
			Global.delay = delay;
		}
		
		private function onTimer():void
		{
			bpsTf.text = '发送速度：' + Global.bytes + ' bps(bytes per second)\n' + 'FPS：' + Global.fps.toFixed(0);
			Global.bytes = 0;
		}
		
		protected function onEnterFrame(event:Event):void
		{
			var nowTime:Number = getTimer();
			Global.elapse = nowTime - Global.lastTime;
			Global.fps = 1000.0 / Global.elapse;
			Global.lastTime = nowTime;
			
			// 控制本地玩家
			// 获取输入
			var lastVelocity:Vector2 = localPlayer.velocity.clone();
			var lastAcceleration:Vector2 = localPlayer.acceleration.clone();
			
			// 一般的线性移动
			localPlayer.velocity.x = 0;
			localPlayer.velocity.y = 0;
			
			
			if (InputManager.instance.keyDown(Keyboard.LEFT)) {
				localPlayer.velocity.x = -localPlayer.speed;
			}
			if (InputManager.instance.keyDown(Keyboard.RIGHT)) {
				localPlayer.velocity.x = localPlayer.speed;
			}
			if (InputManager.instance.keyDown(Keyboard.UP)) {
				localPlayer.velocity.y = -localPlayer.speed;
			}
			if (InputManager.instance.keyDown(Keyboard.DOWN)) {
				localPlayer.velocity.y = localPlayer.speed;
			}
			
			// 世界控制
//			localPlayer.acceleration.x = 0;
//			localPlayer.acceleration.y = 0;
//			if (InputManager.instance.keyDown(Keyboard.LEFT)) {
//				localPlayer.acceleration.x = -localPlayer.power;
//			}
//			if (InputManager.instance.keyDown(Keyboard.RIGHT)) {
//				localPlayer.acceleration.x = localPlayer.power;
//			}
//			if (InputManager.instance.keyDown(Keyboard.UP)) {
//				localPlayer.acceleration.y = -localPlayer.power;
//			}
//			if (InputManager.instance.keyDown(Keyboard.DOWN)) {
//				localPlayer.acceleration.y = localPlayer.power;
//			}
			
			var update:Boolean = false;
			
			// 方案0
			// 不停发变更包
			if (sendMethodCb.selectedIndex == 0) {
				update = true;
			}
			
			
			// 方案1 
			// 当速度/加速度有变更时才更新
			if (sendMethodCb.selectedIndex == 1) {
				if (lastVelocity.x != localPlayer.velocity.x || 
					lastVelocity.y != localPlayer.velocity.y ||
					lastAcceleration.x != localPlayer.acceleration.x || 
					lastAcceleration.y != localPlayer.acceleration.y) {
					update = true;
				}
			}
			
			// 方案3
			// 当网络预测位置与本地位置的距离超过阀值时（DeadReckoning，航位预测）
			if (sendMethodCb.selectedIndex == 2) {
				var drPosition:Vector2 = new Vector2();
				if (lastState) {
					var e:Number = (getTimer() - lastStateTime) / 1000;
					// v0t + 0.5 * a * t^2;
					drPosition.addVectors(lastState.position, lastState.velocity.clone().multiply(e).add(lastState.acceleration.clone().divide(2).multiply(e * e)));
				}
				var threshold:Number = 5 * 5;
				if (localPlayer.position.distSQ(drPosition) > threshold) {
					update = true;
				}
			}

			
			// 发送网络包
			if (update) {
				var p:PlayerStatePack = new PlayerStatePack();
				p.velocity = localPlayer.velocity.clone();
				p.position = localPlayer.position.clone();
				p.acceleration = localPlayer.acceleration.clone();
				p.time = getTimer();
				client.send(p);
				lastState = p.clone();
				lastStateTime = getTimer();
			}
			
//			client.update();
			
			while (client.packets.length > 0) {
				var rp:PlayerStatePack = client.packets.shift();
			
				// 接受网络包
				// 方案1
				// 直接拉扯
				if (smoothMethodCb.selectedIndex == 0) {
					netPlayer.position.x = rp.position.x;
					netPlayer.position.y = rp.position.y;
					netPlayer.velocity = rp.velocity;
				}
				
				// 方案2
				// 简单的平滑拉扯
				// 因为是在显示坐标上做修正，所以可以做到与碰撞系统不相冲突
				if (smoothMethodCb.selectedIndex == 1) {
					netPlayer.modify.x = netPlayer.x - rp.position.x;
					netPlayer.modify.y = netPlayer.y - rp.position.y;
					//如果位置偏差实在过大，直接跳跃
					if (netPlayer.modify.lengthSQ > 50 * 50) {
						netPlayer.modify.set(0, 0);
					}
					netPlayer.position.x = rp.position.x;
					netPlayer.position.y = rp.position.y;
					netPlayer.velocity = rp.velocity.clone();
					netPlayer.acceleration = rp.acceleration.clone();
					
					// 如果停止后，在一定范围内可以不进行平滑，防止难看
				}
				
				
				// 方案3
				// 立方曲线插值
				// 发包时间到当前时间间隔
				if (smoothMethodCb.selectedIndex == 2) {
					var delta:Number = (getTimer() - rp.time) / 1000;
					// 预测点，在延迟时间5倍以后
					// 延迟越严重，预测越远
					var scheduled:Number = delta * 5;
					scheduled = Math.min(scheduled, 0.8);
					
					var pos1:Vector2 = netPlayer.position.clone();
					var pos2:Vector2 = new Vector2().addVectors(pos1, netPlayer.velocity.clone().multiply(0.1));
					var pos4:Vector2 = new Vector2().addVectors(rp.position, rp.velocity.clone().multiply(scheduled).add(rp.acceleration.clone().divide(2).multiply(scheduled * scheduled)));
					var pos3:Vector2 = new Vector2().subVectors(pos4, rp.velocity.clone().add(rp.acceleration.clone().multiply(scheduled)).multiply(0.1));
					
	//				netScene.graphics.clear();
	//				netScene.graphics.drawCircle(pos3.x, pos3.y, 3);
					
					netPlayer.smoothTick = netPlayer.smoothTime = scheduled;
					netPlayer.A = pos4.x - 3 * pos3.x + 3 * pos2.x - pos1.x;
					netPlayer.B = 3 * pos3.x - 6 * pos2.x + 3 * pos1.x;
					netPlayer.C = 3 * pos2.x -  3 * pos1.x;
					netPlayer.D = pos1.x;
					
					netPlayer.E = pos4.y - 3 * pos3.y + 3 * pos2.y - pos1.y;
					netPlayer.F = 3 * pos3.y - 6 * pos2.y + 3 * pos1.y;
					netPlayer.G = 3 * pos2.y -  3 * pos1.y;
					netPlayer.H = pos1.y;
					
					
					netPlayer.velocity = rp.velocity.clone();
					netPlayer.acceleration = rp.acceleration.clone();
				}
			}
			
			// 看清插值过程与预测过程
			if (netPlayer.smoothTick > 0) {
				netPlayer.draw(0x0000FF);
			} else {
				netPlayer.draw(0xFF0000);
			}
			
			// 更新场景
			localScene.update();
			netScene.update();
		}
	}
}