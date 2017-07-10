package cn.studease.api
{
	import flash.events.IEventDispatcher;
	
	import cn.studease.model.Config;

	public interface API extends IEventDispatcher
	{
		function get version():String;
		function get config():Config;
		function get state():String;
		
		function play(url:String = null):void;
		function pause():void;
		function reload():void;
		function seek(offset:Number):void;
		function stop():void;
		function muted(bool:Boolean):void;
		function volume(vol:Number):void;
		function resize(width:Number, height:Number):void;
		
		function getRenderInfo():Object;
	}
}