package
{
	import com.bit101.components.CheckBox;
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
	
	/**
	 * 早期单机游戏的锁帧同步法 
	 * @author Dalton
	 * 
	 */	
	[SWF(frameRate="60", width="701", height="450", backgroundColor="#FFFFFF")]
	public class Main extends Sprite
	{
		
		private var localScene:Scene;
		private var netScene:Scene;
		private var localPlayer:Player;
		private var client:Client;
		private var netPlayer:Player;
		private var lastStateTime:int;
		private var bpsTf:TextField;
		private var delayInput:InputText;
		private var delayRangeInput:InputText;
		private var mergeSceneCb:CheckBox;
		
		// 当前等待帧
		private var keyFrame:uint = 0;
		private var waitTime:Number;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			InputManager.instance.init(stage);
			init();
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
			tf.text = '说明：此例子为客户端帧锁定算法，\n左边为本地场景，右边为延迟后的某玩家看到的网络场景。\n方向键控制方向移动';
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
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			setInterval(onTimer, 1000);
			
			// 采集当前的输入作为包发送
			var p:PlayerInputPack = new PlayerInputPack();
			p.frame = 0;
			p.input = InputManager.instance.keyStatus;
			client.send(p);
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
			
			
			// 如果当前是关键帧
			if (Global.frame == keyFrame) {
				// 查看是否有服务器的更新包，当前关键帧编号，下一关键帧编号，所有玩家的控制信息
				// 获取更新包
				var rp:PlayerInputPack;
				while (client.packets.length > 0) {
					rp = client.packets.shift();
					if (rp.frame == keyFrame) {
						break;
					}
				}
				// 如果等不到当前帧的控制数据，则返回
				if (rp && rp.frame == keyFrame) {
					var nextFrame:int = keyFrame + 5;
					// 采集当前的输入作为包发送
					var p:PlayerInputPack = new PlayerInputPack();
					p.frame = nextFrame;
					p.input = InputManager.instance.keyStatus;
					client.send(p);
					
					// 以rp.input做输入数据
					// 模拟移动本地及网络客户端
					// 每个客户端的逻辑一致
					var players:Array = [localPlayer, netPlayer];
					for each (var player:Player in players) {
						player.velocity.x = 0;
						player.velocity.y = 0;
						
						if (rp.input[Keyboard.LEFT]) {
							player.velocity.x = -player.speed;
						}
						if (rp.input[Keyboard.RIGHT]) {
							player.velocity.x = player.speed;
						}
						if (rp.input[Keyboard.UP]) {
							player.velocity.y = -player.speed;
						}
						if (rp.input[Keyboard.DOWN]) {
							player.velocity.y = player.speed;
						}
					}
					
					// 下一个关键帧
					keyFrame = nextFrame;
					waitTime = 0;
				} else {
					waitTime += Global.elapse;
					
					// 等待太久了，类似魔兽争霸的那个超时面板
					if (waitTime > 1000) {
						trace('等待不到控制包信息', keyFrame);
					}
				}
			} else {
				// 当前帧步进
				Global.frame++;
			}
			
			// 更新场景
			localScene.update();
			netScene.update();
		}
	}
}