package cn.studease.controller
{
	import flash.events.EventDispatcher;
	import flash.media.Video;
	
	import cn.studease.api.API;
	import cn.studease.model.Model;
	import cn.studease.utils.Utils;
	import cn.studease.view.View;

	public class Controller extends EventDispatcher
	{
		protected var _api:API;
		protected var _model:Model;
		protected var _view:View;
		
		public function Controller(api:API, model:Model, view:View)
		{
			_api = api;
			_model = model;
			_view = view;
		}
		
		public function play(url:String = null):void {
			var protocol:String = Utils.getProtocol(url);
			if (protocol == 'rtmp' || protocol == 'rtmpe' || protocol == 'rtmps') {
				_model.setActiveMediaProvider('rtmp');
			} else {
				_model.setActiveMediaProvider('default');
			}
			
			_model.media.video = _view.element as Video;
			
			_model.media.play(url);
		}
		
		public function pause():void {
			_model.media.pause();
		}
		
		public function reload():void {
			_model.media.reload();
		}
		
		public function seek(offset:Number):void {
			_model.media.seek(offset);
		}
		
		public function stop():void {
			_model.media.stop();
		}
		
		public function muted(bool:Boolean):void {
			_model.media.muted(bool);
		}
		
		public function volume(vol:Number):void {
			_model.media.volume(vol);
		}
	}
}