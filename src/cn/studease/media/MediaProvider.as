package cn.studease.media
{
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StageVideoEvent;
	import flash.events.TimerEvent;
	import flash.events.VideoEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.utils.Timer;
	
	import cn.studease.events.MediaEvent;
	import cn.studease.model.Config;
	import cn.studease.model.States;
	import cn.studease.utils.Logger;

	public class MediaProvider extends EventDispatcher implements IMediaProvider
	{
		protected var _provider:String;
		protected var _config:Config;
		protected var _stageVideoEnabled:Boolean;
		protected var _state:String;
		protected var _stage:StageVideo;
		protected var _video:Video;
		protected var _connection:NetConnection;
		protected var _stream:NetStream;
		protected var _transformer:SoundTransform;
		protected var _timer:Timer;
		
		protected var _offset:Number;
		protected var _buffered:Number;
		protected var _position:Number;
		protected var _duration:Number;
		
		
		public function MediaProvider(provider:String)
		{
			_provider = provider;
			_stageVideoEnabled = true;
		}
		
		public function initializeMediaProvider(cfg:Config):void {
			_config = cfg;
			_state = States.STOPPED;
			
			_connection = new NetConnection();
			_connection.objectEncoding = ObjectEncoding.AMF0;
			_connection.connect(null);
			
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, _statusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _errorHandler);
			_stream.bufferTime = _config.bufferTime;
			_stream.client = this;
			
			_transformer = new SoundTransform();
			volume(_config.volume);
			
			_offset = 0;
			_buffered = 0;
			_position = 0;
			_duration = 0;
		}
		
		private function _statusHandler(e:NetStatusEvent):void {
			Logger.debug('netstatus: ' + e.info.code);
			
			switch (e.info.code) {
				case 'NetStream.Buffer.Empty':
					if (_state != States.STOPPED && _state != States.ERROR) {
						_state = States.BUFFERING
						dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_BUFFERING));
					}
					break;
				
				case 'NetStream.Buffer.Full':
				case 'NetStream.Play.Start':
					_state = States.PLAYING;
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_PLAYING));
					break;
				
				case 'NetStream.Pause.Notify':
					_state = States.PAUSED;
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_PAUSED));
					break;
				
				case 'NetStream.Play.Stop':
					_state = States.STOPPED;
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_STOPPED));
					break;
				
				case 'NetStream.Video.DimensionChange':
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_DIMENSION_CHANGE, {
						width: _stage ? _stage.videoWidth : _video.videoWidth,
						height: _stage ? _stage.videoHeight : _video.videoHeight
					}));
					break;
				
				case 'NetStream.Play.Failed':
				case 'NetStream.Play.StreamNotFound':
				case 'NetStream.Play.FileStructureInvalid':
				case 'NetStream.Play.NoSupportedTrackFound':
					error(e.info.code);
					break;
			}
		}
		
		protected function _errorHandler(e:ErrorEvent):void {
			error(e.text);
		}
		
		protected function error(message:String):void {
			_state = States.ERROR;
			dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_RENDER_ERROR, { message: message }));
		}
		
		
		public function play(url:String = null):void {
			Logger.log('Flash default provider playing: ' + url);
			
			if (url && url != _config.url) {
				_config.url = url;
			} else {
				if (_state == States.PAUSED) {
					_stream.resume();
					
					_state = States.PLAYING;
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_PLAYING));
				}
				
				if (_state == States.BUFFERING || _state == States.PLAYING) {
					return;
				}
			}
			
			if (_config.hasOwnProperty('stagevideo') && _config.stagevideo == false) {
				_stageVideoEnabled = false;
			}
			if (_stageVideoEnabled && _video.stage.stageVideos.length) {
				_stage = _video.stage.stageVideos[0];
				_stage.viewPort = new Rectangle(_video.x, _video.y, _video.width, _video.height);
				
				_stage.addEventListener(StageVideoEvent.RENDER_STATE, _renderStateHandler);
			} else {
				_video.addEventListener(VideoEvent.RENDER_STATE, _renderStateHandler);
			}
			
			_attachNetStream(_stream);
			_startTimer();
			
			_state = States.BUFFERING;
			_stream.play(_config.url);
		}
		
		protected function _renderStateHandler(e:Event):void {
			Logger.debug(e.toString());
		}
		
		protected function _attachNetStream(stream:NetStream):void {
			if (_stage) {
				_stage.attachNetStream(stream);
			} else {
				_video.attachNetStream(stream);
			}
		}
		
		protected function _startTimer():void {
			if (!_timer) {
				_timer = new Timer(200);
				_timer.addEventListener(TimerEvent.TIMER, _updateTime);
			}
			_timer.start();
		}
		protected function _stopTimer():void {
			if (_timer) {
				_timer.stop();
			}
		}
		
		protected function _updateTime(e:TimerEvent):void {
			if (_buffered < 100) {
				_buffered = Math.floor((_offset / 100 + _stream.bytesLoaded / _stream.bytesTotal) * 10000) / 100;
				_buffered = Math.min(_buffered, 100);
			}
			
			_position = _stream.time;
			
			dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_STREAM_INFO, {
				buffered: _buffered,
				position: _position,
				duration: _duration
			}));
		}
		
		public function pause():void {
			_state = States.PAUSED;
			_stream.pause();
		}
		
		public function reload():void {
			_state = States.BUFFERING;
			_stream.dispose();
			play(_config.url);
		}
		
		public function seek(offset:Number):void {
			_state = States.PLAYING;
			_offset = offset / 100;
			_stream.seek(_offset * _duration);
			_stream.resume();
		}
		
		public function stop():void {
			_state = States.STOPPED;
			_stopTimer();
			
			_stream.close();
			
			if (_video) {
				_video.clear();
			}
			_attachNetStream(null);
			
			_offset = 0;
			_buffered = 0;
			_position = 0;
			_duration = 0;
			
			dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_STOPPED));
		}
		
		public function muted(bool:Boolean):void {
			_config.muted = bool;
			
			_transformer.volume = bool ? 0 : _config.volume / 100;
			if (_stream) {
				_stream.soundTransform = _transformer;
			}
		}
		
		public function volume(vol:Number):void {
			_config.volume = vol;
			
			_transformer.volume = vol / 100;
			if (_stream) {
				_stream.soundTransform = _transformer;
			}
		}
		
		
		public function onMetaData(data:Object):void {
			var str:String = 'onMetaData: {';
			
			for (var i:String in data) {
				str += '\n\t' + i + ': ' + data[i];
			}
			str += '\n}';
			
			Logger.log(str);
			
			_duration = data.duration;
			dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_METADATA, { data: data }));
		}
		
		
		public function get provider():String {
			return _provider;
		}
		
		public function get state():String {
			return _state;
		}
		
		public function get buffered():Number {
			return _buffered;
		}
		
		public function get position():Number {
			return _position;
		}
		
		public function get duration():Number {
			return _duration;
		}
		
		public function set video(v:Video):void {
			_video = v;
		}
		public function get video():Video {
			return _video;
		}
		
		
		public function resize(width:Number, height:Number):void {
			if (_stage) {
				_stage.viewPort = new Rectangle(_video.x, _video.y, _video.width, _video.height);
			}
			
			Logger.debug('resized to (' + _video.x + ', ' + _video.y + ', ' + _video.width + ', ' + _video.height + ')');
		}
	}
}