package cn.studease.model
{
	import cn.studease.utils.Logger;

	public dynamic class Config
	{
		private static const _version:String = '1.0.00';
		private static var _logger:String = Logger.LOG;
		
		private var _id:String = 'player';
		private var _url:String = '/vod/sample.flv';
		
		private var _width:Number = 640;
		private var _height:Number = 360;
		private var _ratio:Number = 16 / 9;
		private var _bufferTime:Number = 1;
		private var _muted:Boolean = false;
		private var _volume:int = 80;
		
		
		public function Config(cfg:Object)
		{
			for (var i:String in cfg) {
				if (this.hasOwnProperty(i)) {
					this[i] = cfg[i];
				}
			}
			
			_ratio = this.width / this.height;
			
			if (cfg.debug === true) {
				_logger = Logger.DEBUG;
			}
		}
		
		public function get version():String {
			return _version;
		}
		public static function get VERSION():String {
			return _version;
		}
		
		public static function get LOGGER():String {
			return _logger;
		}
		
		public function set id(x:String):void {
			_id = x;
		}
		public function get id():String {
			return _id;
		}
		
		public function set url(x:String):void {
			_url = x;
		}
		public function get url():String {
			return _url;
		}
		
		public function set width(x:Number):void {
			_width = x;
		}
		public function get width():Number {
			return _width;
		}
		
		public function set height(x:Number):void {
			_height = x;
		}
		public function get height():Number {
			return _height;
		}
		
		public function set ratio(x:Number):void {
			_ratio = x;
		}
		public function get ratio():Number {
			return _ratio;
		}
		
		public function set bufferTime(x:Number):void {
			_bufferTime = x;
		}
		public function get bufferTime():Number {
			return _bufferTime;
		}
		
		public function set muted(x:Boolean):void {
			_muted = x;
		}
		public function get muted():Boolean {
			return _muted;
		}
		
		public function set volume(x:int):void {
			_volume = x;
		}
		public function get volume():int {
			return _volume;
		}
	}
}