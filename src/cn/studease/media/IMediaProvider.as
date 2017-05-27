package cn.studease.media
{
	import flash.events.IEventDispatcher;
	import flash.media.Video;
	
	import cn.studease.model.Config;

	public interface IMediaProvider extends IEventDispatcher
	{
		function initializeMediaProvider(cfg:Config):void;
		
		function play(url:String = null):void;
		function pause():void;
		function load():void;
		function seek(offset:Number):void;
		function stop():void;
		function muted(bool:Boolean):void;
		function volume(vol:Number):void;
		
		function resize(width:Number, height:Number):void;
		
		function get provider():String;
		function get state():String;
		
		function get buffered():Number;
		function get position():Number;
		function get duration():Number;
		
		function set video(v:Video):void;
		function get video():Video;
	}
}