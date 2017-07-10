package cn.studease.model
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import cn.studease.events.MediaEvent;
	import cn.studease.media.IMediaProvider;
	import cn.studease.media.MediaProvider;
	import cn.studease.media.RTMPMediaProvider;
	import cn.studease.utils.Logger;

	public class Model extends EventDispatcher
	{
		protected var _config:Config;
		protected var _providers:Object = {};
		protected var _provider:IMediaProvider;
		
		
		public function Model(cfg:Object)
		{
			_config = new Config(cfg);
			_setupMediaProviders();
		}
		
		private function _setupMediaProviders():void {
			_setupMediaProvider('default', new MediaProvider('default'));
			_setupMediaProvider('rtmp', new RTMPMediaProvider());
			setActiveMediaProvider('default');
		}
		
		private function _setupMediaProvider(type:String, provider:IMediaProvider):void {
			if (!_providers.hasOwnProperty(type)) {
				provider.initializeMediaProvider(_config);
				_providers[type] = provider;
			}
		}
		
		public function setActiveMediaProvider(type:String):void {
			if (!_providers.hasOwnProperty(type)) {
				type = 'default';
			}
			
			if (_provider && _provider.provider != type && _provider.state != States.STOPPED) {
				_provider.removeEventListener(MediaEvent.PLAYEASE_BUFFERING, _stateHandler);
				_provider.removeEventListener(MediaEvent.PLAYEASE_PLAYING, _stateHandler);
				_provider.removeEventListener(MediaEvent.PLAYEASE_PAUSED, _stateHandler);
				_provider.removeEventListener(MediaEvent.PLAYEASE_STOPPED, _stateHandler);
				_provider.removeEventListener(MediaEvent.PLAYEASE_RENDER_ERROR, _stateHandler);
				_provider.stop();
				
				Logger.debug('Stopped provider ' + _provider.provider + '.');
			}
			
			_provider = _providers[type];
			_provider.addEventListener(MediaEvent.PLAYEASE_BUFFERING, _stateHandler);
			_provider.addEventListener(MediaEvent.PLAYEASE_PLAYING, _stateHandler);
			_provider.addEventListener(MediaEvent.PLAYEASE_PAUSED, _stateHandler);
			_provider.addEventListener(MediaEvent.PLAYEASE_STOPPED, _stateHandler);
			_provider.addEventListener(MediaEvent.PLAYEASE_RENDER_ERROR, _stateHandler);
			
			Logger.debug('Actived ' + type + ' provider.');
		}
		
		protected function _stateHandler(e:MediaEvent):void {
			var data:Object = { state: _provider.state };
			if (e.type == MediaEvent.PLAYEASE_RENDER_ERROR) {
				data.message = e.message;
			}
			
			ExternalInterface.call(''
				+ 'function() {'
					+ 'var player = playease("' + _config.id + '");'
					+ 'if (player) {'
						+ 'player.onSWFState({ state: "' + _provider.state + (e.type == MediaEvent.PLAYEASE_RENDER_ERROR ? '", message: "' + e.message + '"' : '"') + ' });'
					+ '}'
				+ '}');
		}
		
		
		public function get config():Config {
			return _config;
		}
		public function set config(cfg:Config):void {
			_config = cfg;
		}
		
		public function get media():IMediaProvider {
			return _provider;
		}
		
		public function get state():String {
			return _provider.state;
		}
	}
}