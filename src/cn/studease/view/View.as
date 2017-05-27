package cn.studease.view
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.media.Video;
	
	import cn.studease.api.API;
	import cn.studease.events.MediaEvent;
	import cn.studease.model.Model;
	import cn.studease.utils.Logger;

	public class View extends EventDispatcher
	{
		protected var _api:API;
		protected var _model:Model;
		protected var _video:Video;
		
		
		public function View(api:API, model:Model)
		{
			_api = api;
			_model = model;
			
			_video = new Video(model.config.width, model.config.height);
			_model.media.video = _video;
			
			_model.media.addEventListener(MediaEvent.PLAYEASE_METADATA, _onMetaData);
			_model.media.addEventListener(MediaEvent.PLAYEASE_DIMENSION_CHANGE, _onDimensionChange);
		}
		
		private function _onMetaData(e:MediaEvent):void {
			_model.config.ratio = e.data.width / e.data.height;
		}
		
		private function _onDimensionChange(e:MediaEvent):void {
			resize(_video.stage.stageWidth, _video.stage.stageHeight);
		}
		
		
		public function resize(width:Number, height:Number):void {
			Logger.debug('resizing to: ' + width + ', ' + height);
			
			if (width / height >= _model.config.ratio) {
				_video.width = height * _model.config.ratio;
				_video.height = height;
			} else {
				_video.width = width;
				_video.height = width / _model.config.ratio;
			}
			
			_video.x = (width - _video.width) / 2;
			_video.y = (height - _video.height) / 2;
			
			if (_model.media) {
				_model.media.resize(width, height);
			}
		}
		
		
		public function get element():DisplayObject {
			return _video;
		}
	}
}