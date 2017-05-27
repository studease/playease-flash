package cn.studease.utils
{
	import flash.external.ExternalInterface;
	
	import cn.studease.model.Config;
	import cn.studease.utils.Utils;

	public class Logger
	{
		public static const DEBUG:String = 'DEBUG';
		public static const LOG:String = 'L O G';
		public static const ERROR:String = 'ERROR';
		
		private static const _level:int = 0;
		
		
		public static function log(text:String):void {
			_format(text, LOG);
		}
		
		public static function debug(text:String, level:int = 0):void {
			if (level < _level) {
				return;
			}
			
			_format(text, DEBUG);
		}
		
		public static function error(text:String):void {
			_format(text, ERROR);
		}
		
		private static function _format(text:String, type:String):void {
			var str:String = "[" + Utils.getDateTimeString() + " " + type + "] " + text;
			
			if (Config.LOGGER == DEBUG) {
				trace(str);
			}
			
			if (!ExternalInterface.available) {
				return;
			}
			
			if (Config.LOGGER == DEBUG || Config.LOGGER == LOG && type == LOG || Config.LOGGER == ERROR && type == ERROR) {
				ExternalInterface.call('console.log', str);
			}
		}
	}
}