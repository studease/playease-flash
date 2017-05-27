package cn.studease.utils
{
	public class Utils
	{
		public static function getDateTimeMilliString(date:Date = null):String {
			var now:Date = date || new Date();
			return getDateTimeString(now) + "." + pad(now.milliseconds, 3);
		}
		
		public static function getDateTimeString(date:Date = null):String {
			var now:Date = date || new Date();
			return getDateString(now) + " " + getTimeString(now);
		}
		
		
		public static function getDateString(date:Date = null, separator:String = "-"):String {
			var now:Date = date || new Date();
			return now.fullYear + separator + pad(now.month + 1) + separator + pad(now.date);
		}
		
		public static function getTimeMilliString(date:Date = null):String {
			var now:Date = date || new Date();
			return getTimeString(now) + "." + pad(now.milliseconds, 3);
		}
		
		public static function getTimeString(date:Date = null, separator:String = ":"):String {
			var now:Date = date || new Date();
			return pad(now.hours) + separator + pad(now.minutes) + separator + pad(now.seconds);
		}
		
		
		public static function getTimeDisplay(seconds:int, parts:int = 2, ch:String = ":"):String {
			var hours:int = seconds / 3600;
			var left:int = seconds - hours * 3600;
			var mins:int = left / 60;
			var secs:int = left - mins * 60;
			var s:String = "";
			
			if(hours > 0 || parts >= 3) {
				s += pad(hours) + ch;
			}
			
			if(mins > 0 || parts >= 2) {
				s += pad(mins) + ch;
			}
			
			s += pad(secs);
			
			return s;
		}
		
		
		public static function pad(i:int, len:int = 2, ch:String = "0"):String {
			var p:String = "";
			var r:int = i;
			var d:int = 0;
			
			do {
				r /=  10;
				d++;
			} while (r>0);
			
			for (var j:int=0; j<len-d; j++) {
				p +=  ch;
			}
			
			return p + String(i);
		}
		
		
		public static function getProtocol(url:String):String {
			var protocol:String = 'http';
			
			var re:RegExp = new RegExp('^([a-z]+)\:\/\/', 'i');
			var arr:Array = url.match(re);
			if (arr && arr.length > 1) {
				protocol = arr[1];
			}
			
			return protocol;
		}
	}
}