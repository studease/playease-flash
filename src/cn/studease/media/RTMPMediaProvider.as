package cn.studease.media
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoEvent;
	import flash.events.VideoEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	
	import cn.studease.events.MediaEvent;
	import cn.studease.model.Config;
	import cn.studease.model.States;
	import cn.studease.utils.Logger;

	public class RTMPMediaProvider extends MediaProvider
	{
		private var _application:String;
		private var _streamname:String;
		private var _metadata:Boolean;
		
		
		public function RTMPMediaProvider()
		{
			super('rtmp');
		}
		
		public override function initializeMediaProvider(cfg:Config):void {
			_config = cfg;
			_state = States.STOPPED;
			
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, _statusHandler);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _errorHandler);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
			_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _errorHandler);
			_connection.objectEncoding = ObjectEncoding.AMF0;
			_connection.client = this;
			
			_transformer = new SoundTransform();
			
			_offset = 0;
			_buffered = 0;
			_position = 0;
			_duration = 0;
		}
		
		private function initializeNetStream():void {
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, _statusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _errorHandler);
			_stream.bufferTime = _config.bufferTime;
			_stream.client = this;
			
			_attachNetStream(_stream);
			volume(_config.volume);
		}
		
		private function _statusHandler(e:NetStatusEvent):void {
			Logger.debug('netstatus: ' + e.info.code);
			
			switch (e.info.code) {
				case 'NetConnection.Connect.Success':
					initializeNetStream();
					play(_config.url);
					break;
				
				case 'NetConnection.Connect.Rejected':
				case 'NetConnection.Connect.Failed':
					error(e.info.code);
					break;
				
				case 'NetConnection.Connect.Closed':
					_state = States.STOPPED;
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_STOPPED));
					break;
				
				
				case 'NetStream.Buffer.Empty':
					_state = States.BUFFERING
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_BUFFERING));
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
				case 'NetStream.Play.UnpublishNotify':
					_state = States.STOPPED;
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_STOPPED));
					break;
				
				case 'NetStream.Video.DimensionChange':
					dispatchEvent(new MediaEvent(MediaEvent.PLAYEASE_DIMENSION_CHANGE, {
						width: _stage ? _stage.videoWidth : _video.videoWidth,
						height: _stage ? _stage.videoHeight : _video.videoHeight
					}));
					break;
				
				case 'NetStream.Failed':
				case 'NetStream.Play.Failed':
				case 'NetStream.Play.StreamNotFound':
				case 'NetStream.Play.FileStructureInvalid':
				case 'NetStream.Play.NoSupportedTrackFound':
				case 'NetStream.Seek.Failed':
					error(e.info.code);
					break;
			}
		}
		
		override public function play(url:String = null):void {
			Logger.log('Flash RTMP provider playing: ' + url);
			
			if (url && url != _config.url) {
				_config.url = url;
			} else if (_connection.connected && _metadata && _duration) {
				_state = States.PLAYING;
				_stream.resume();
				return;
			}
			
			if (!_connection.connected) {
				var re:RegExp = new RegExp('^(rtmp[es]?\:\/\/[a-z0-9\.\-]+(\:([0-9]*))?(\/[a-z0-9\.\-_]+)+)\/([a-z0-9\.\-_]+)$', 'i');
				var arr:Array = _config.url.match(re);
				if (arr && arr.length > 5) {
					_application = arr[1];
					_streamname = arr[5];
				} else {
					Logger.error('Failed to match RTMP URL: ' + _config.url);
					error('Bad URL format!');
					return;
				}
				
				Logger.log('Connecting to ' + _application + ' ...');
				_connection.connect(_application);
				
				return;
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
			
			Logger.log('Playing rtmp stream: ' + _streamname + '.');
			
			_state = States.BUFFERING;
			_stream.play(_streamname);
		}
		
		override public function pause():void {
			if (_stream) {
				if (_duration) {
					_stream.pause();
				} else {
					_stream.close();
				}
			}
		}
		
		override public function reload():void {
			stop();
			play(_config.url);
		}
		
		override public function seek(offset:Number):void {
			if (_duration) {
				_state = States.PLAYING;
				_offset = offset / 100;
				_stream.seek(_offset * _duration);
				_stream.resume();
			}
		}
		
		override public function stop():void {
			_state = States.STOPPED;
			_stopTimer();
			
			if (_stream && _stream.time) {
				_stream.close();
			}
			_stream = null;
			_connection.close();
			
			if (_video) {
				_video.clear();
			}
			_attachNetStream(null);
			
			_application = null;
			_metadata = false;
			
			_offset = 0;
			_buffered = 0;
			_position = 0;
			_duration = 0;
		}
	}
}