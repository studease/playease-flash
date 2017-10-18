package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	import cn.studease.api.API;
	import cn.studease.controller.Controller;
	import cn.studease.model.Config;
	import cn.studease.model.Model;
	import cn.studease.utils.Logger;
	import cn.studease.view.View;

	public class Main extends Sprite implements API
	{
		protected var _model:Model;
		protected var _view:View;
		protected var _controller:Controller;
		
		protected var _setupDone:Boolean;
		
		
		public function Main()
		{
			Security.allowDomain("*");
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;
			stage.color = 0x000000;
			
			try {
				this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			} catch (err:Error) {
				_onAddedToStage();
			}
		}
		
		private function _onAddedToStage(e:Event = null):void {
			try {
				this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			} catch (err:Error) {
				/* void */
			}
			
			if (!ExternalInterface.available) {
				Logger.error('ExternalInterface not available!');
				return;
			}
			
			ExternalInterface.addCallback('setup', _setup);
			
			try {
				var id:String = this.loaderInfo.parameters.id;
				Logger.log('Param id: ' + id);
				
				ExternalInterface.call(''
					+ 'function() {'
						+ 'var player = playease("' + id + '");'
						+ 'if (player) {'
							+ 'player.onSWFLoaded();'
						+ '}'
					+ '}');
			} catch (err:Error) {
				Logger.error('Failed to call external interface "setup"!');
			}
		}
		
		private function _setup(cfg:Object):void {
			if (!_setupDone) {
				_model = new Model(cfg);
				_view = new View(this, _model);
				_controller = new Controller(this, _model, _view);
				
				this.addChild(_view.element);
				
				ExternalInterface.addCallback('xplay', play);
				ExternalInterface.addCallback('pause', pause);
				ExternalInterface.addCallback('reload', reload);
				ExternalInterface.addCallback('seek', seek);
				ExternalInterface.addCallback('xstop', stop);
				ExternalInterface.addCallback('muted', muted);
				ExternalInterface.addCallback('volume', volume);
				ExternalInterface.addCallback('resize', resize);
				
				ExternalInterface.addCallback('getRenderInfo', getRenderInfo);
				
				_setupDone = true;
				
				Logger.log('Setup flash render done!');
			}
		}
		
		
		public function get version():String {
			return _model.config.version;
		}
		
		public function get config():Config {
			return _model.config;
		}
		
		public function get state():String {
			return _model.state;
		}
		
		
		public function play(url:String = null):void {
			_controller.play(url);
		}
		
		public function pause():void {
			_controller.pause();
		}
		
		public function reload():void {
			_controller.reload();
		}
		
		public function seek(offset:Number):void {
			_controller.seek(offset);
		}
		
		public function stop():void {
			_controller.stop();
		}
		
		public function muted(bool:Boolean):void {
			_controller.muted(bool);
		}
		
		public function volume(vol:Number):void {
			_controller.volume(vol);
		}
		
		public function resize(width:Number, height:Number):void {
			_view.resize(width, height);
		}
		
		
		public function getRenderInfo():Object {
			return {
				buffered: _model.media.buffered,
				position: _model.media.position,
				duration: _model.media.duration
			};
		}
	}
}