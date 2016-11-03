package com.ar.video
{
	import com.ar.core.log.Context;
	import com.ar.core.log.Log;
	import com.ar.net.basic.BasicNetConnection;
	import com.ar.net.basic.BasicNetStream;
	import com.ar.net.basic.INetConnectionStatusHandler;
	import com.ar.net.basic.INetStreamStatusHandler;
	import com.ar.net.utils.NetStatusType;

	import flash.media.SoundTransform;
	import flash.media.Video;

	/**
	 * @author Alan Ross
	 * @version 0.1
	 */
	public final class LocalVideoPlayer implements INetConnectionStatusHandler, INetStreamStatusHandler
	{
		private var _connection:BasicNetConnection;
		private var _stream:BasicNetStream;

		private var _video:Video;
		private var _videoWidth:Number;
		private var _videoHeight:Number;
		private var _videoDuration:Number;
		private var _videoVolume:Number;
		private var _videoReady:Boolean = false;
		private var _videoPlaying:Boolean = false;
		private var _videoLooped:Boolean = true;

		/**
		 * Creates a new instance of LocalVideoPlayer.
		 */
		public function LocalVideoPlayer( videoWidth:int, videoHeight:int )
		{
			_connection = new BasicNetConnection( this, this );
			_stream = new BasicNetStream( this, this );

			//http stream. path to video is set in netStream.play
			_connection.connect( null );

			_video = new Video( videoWidth, videoHeight );
		}

		/**
		 * handle net connection status events.
		 */
		public function onNetConnectionStatusChanged( statusType:int ):void
		{
			if( ( statusType & NetStatusType.ERROR ) != 0 )
			{
				Log.error( Context.DEFAULT, this, "Connection Error, " + NetStatusType.typeToCode( statusType ) + ": " + _connection.url );
			}
			else if( statusType == NetStatusType.CONNECTION_CONNECT_SUCCESS )
			{
				_stream.open( _connection.netConnection );
			}
		}

		/**
		 * handle net stream status events.
		 */
		public function onNetStreamStatusChanged( statusType:int ):void
		{
			if( ( statusType & NetStatusType.ERROR ) != 0 )
			{
				Log.error( Context.DEFAULT, this, "Stream Error, " + NetStatusType.typeToCode( statusType ) + ": " + _stream.name );
			}

			switch( statusType )
			{
				case NetStatusType.STREAM_PLAY_START:
					_videoReady = true;
					break;
				case NetStatusType.STREAM_PLAY_STOP:
					videoPlaybackCompleted();
					break;
				case NetStatusType.STREAM_BUFFER_FULL:
					videoPlaybackStarted();
					break;
			}
		}

		/**
		 * Called by the server.
		 */
		public function onPlayStatus( info:Object ):void
		{
			// Called by the Flash Media Server. Required by some stream publishers
		}

		/**
		 * Called by the server.
		 */
		public function onMetaData( info:Object ):void
		{
			if( info.hasOwnProperty( "duration" ) && info["duration"] != null )
			{
				_videoDuration = Math.round( info.duration );
			}

			if( info.hasOwnProperty( "width" ) && info["width"] != null )
			{
				_videoWidth = _video.width = Math.round( info.width );
			}

			if( info.hasOwnProperty( "height" ) && info["height"] != null )
			{
				_videoHeight = _video.height = Math.round( info.height );
			}
		}

		/**
		 * Called by the Flash Media Server. Required by some stream publishers
		 */
		public function onCuePoint( info:Object ):void
		{
		}

		/**
		 * Called by the Flash Media Server. Required by some stream publishers
		 */
		public function onSDES( ...rest ):void
		{
		}

		/**
		 * Called by the Flash Media Server. Required by some stream publishers
		 */
		public function onBWDone( ...rest ):void
		{
		}

		/**
		 * @private
		 */
		private function videoPlaybackStarted():void
		{
			if( _videoReady && !_videoPlaying )
			{
				_video.attachNetStream( _stream.netStream );
				_videoPlaying = true;
			}
		}

		/**
		 * @private
		 */
		private function videoPlaybackCompleted():void
		{
			if( _videoLooped )
			{
				_stream.seek( 0 );
			}
			else
			{
				_videoPlaying = false;
			}
		}

		/**
		 * Play the video defined by its uri.
		 */
		public function play( uri:String ):void
		{
			if( _videoPlaying )
			{
				stop();
			}

			_stream.play( uri );
		}

		/**
		 * Stop playing the video.
		 */
		public function stop():void
		{
			if( _videoPlaying )
			{
				_videoPlaying = false;

				try
				{
					_stream.close();
				}
				catch( error:Error )
				{
				}
			}
		}

		/**
		 * The volume of the video
		 */
		public function set volume( value:Number ):void
		{
			if( _videoVolume != value )
			{
				_videoVolume = value;

				try
				{
					_stream.netStream.soundTransform = new SoundTransform( _videoVolume );
				}
				catch( e:Error )
				{
				}
			}
		}

		/**
		 * The volume of the video
		 */
		public function get volume():Number
		{
			return _videoVolume;
		}

		/**
		 * Direct access to the native video object.
		 */
		public function get video():Video
		{
			return _video;
		}

		/**
		 * Creates and returns a string representation of the LocalVideoPlayer object.
		 */
		public function toString():String
		{
			return "[LocalVideoPlayer]";
		}
	}
}