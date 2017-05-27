package cn.studease.events
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import cn.studease.model.Config;

	public dynamic class MediaEvent extends Event
	{
		public static const PLAYEASE_BUFFERING:String = 'playeaseBuffering';
		public static const PLAYEASE_PLAYING:String = 'playeasePlaying';
		public static const PLAYEASE_PAUSED:String = 'playeasePaused';
		public static const PLAYEASE_RELOADING:String = 'playeaseReloading';
		public static const PLAYEASE_SEEKING:String = 'playeaseSeeking';
		public static const PLAYEASE_STOPPED:String = 'playeaseStopped';
		
		public static const PLAYEASE_RENDER_ERROR:String = 'playeaseRenderError';
		
		public static const PLAYEASE_METADATA:String = 'playeaseMetaData';
		public static const PLAYEASE_DIMENSION_CHANGE:String = 'playeaseDimensionChange';
		public static const PLAYEASE_STREAM_INFO:String = 'playeaseStreamInfo';
		
		
		public var id:String;
		public var version:String;
		
		private var _data:Object;
		
		
		public function MediaEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			
			id = getQualifiedClassName(this.target);
			version = Config.VERSION;
			
			_data = data;
			
			for (var i:String in data) {
				if (this.hasOwnProperty(i) == false) {
					this[i] = data[i];
				}
			}
		}
		
		override public function clone():Event {
			return new MediaEvent(type, _data);
		}
		
		public override function toString():String {
			return '[MediaEvent type="' + type + '" id="' + id + '" version="' + version + '" data=' + _data.toString() + ']';
		}
	}
}