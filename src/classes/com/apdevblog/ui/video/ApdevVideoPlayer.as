/**
 * Copyright (c) 2009 apdevblog.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.apdevblog.ui.video
{
	import com.apdevblog.ui.video.controls.IconPlay;
	import com.apdevblog.events.video.VideoControlsEvent;
	import com.apdevblog.model.vo.VideoMetadataVo;
	import com.apdevblog.utils.Draw;

	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * Custom actionscript-only videoplayer.
	 * 
	 * <p>VideoPlayer with controls for play/pause, volume,
	 * fullscreen and staturbar.</p>
	 * 
	 * <p>Player can display every format Flashplayer 9 supports, e.g. flv 
	 * (sorenson, on2), mov (h.264), mp4.</p>
	 * 
	 * @example <listing>
	 * import com.apdevblog.ui.video.ApdevVideoPlayer;
	 *  
	 * var video:ApdevVideoPlayer = new ApdevVideoPlayer(320, 240);
	 * video.controlsOverVideo = false;
	 * video.controlsAutoHide = false;
	 * video.videostill = "videostill.jpg";
	 * video.autoPlay = false;
	 * addChild(video);
	 * video.load("video01.mp4");
	 * </listing> 
	 *
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.ui.video
	 * @author     Philipp Kyeck / phil[at]apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * @version    SVN: $Id$
	 * 
	 * @see com.apdevblog.ui.video.ApdevVideoControls ApdevVideoControls
	 */
	public class ApdevVideoPlayer extends Sprite 
	{
		// because of the video controls the player should not be smaller than 140px 
		public static const MIN_WIDTH:int = 140;
		//
		public static const DEFAULT_CONTROLS_FADE_OUT_TIME:int = 2000;
		//
		// VIEW
		private var _videoBg:Sprite;
		private var _video:Video;
		//
		// MODEL
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _loadTimer:Timer;
		private var _positionTimer:Timer;
		//
		private var _videoUrl:String;
		private var _offset:Number;
		private var _timeOffset:Number;
		private var _scrubbingIndex:int;
		private var _stateBeforeScrubbing:String;
		private var _autoPlay:Boolean;
		private var _loaded:Boolean;
		private var _trackIndex:Number;
		private var _videoState:String;
		private var _videoMetaData:VideoMetadataVo;
		private var _videoControls:ApdevVideoControls;
		//
		private var _volume:Number;
		private var _videoPlayerWidth:int;
		private var _videoPlayerHeight:int;
		private var _controlsOverVideo:Boolean;
		private var _controlsAutoHide:Boolean;
		private var _lastControlsAutoHide:Boolean;
		//
		private var _fullscreenTakeover:Boolean;
		private var _lastFullscreenTakeover:Boolean;
		private var _lastStageAlign:String;
		private var _lastX:Number;
		private var _lastY:Number;
		private var _lastParent:DisplayObjectContainer;
		private var _lastLevel:int;
		//
		private var _fadeOutTimer:Timer;
		private var _fadeOutTime:int;
		//
		private var _previewUrlOrRequest:*;
		private var _imageOverlay:Loader;
		private var _image:Sprite;
		private var _imageOverlayIcon:IconPlay;
		private var _loadBeforePlay:Boolean;

		/**
		 * creates a new ApdevVideoPlayer with specified dimensions.
		 * 
		 * @param width 	width of the videoplayer's video	@default 140 
		 * @param height 	height of the videoplayer's video
		 */
		public function ApdevVideoPlayer(width:int, height:int)
		{
			_init(width, height);
		}
		
		/**
		 * stops videoplayback and clears screen.
		 */
		public function clear():void
		{
			pause();
			_video.clear();
			_ns.close();
			_video.attachNetStream(null);
			_video.visible = false;
			
			videoState = ApdevVideoState.VIDEO_STATE_EMPTY;
		}
		
		/**
		 * loads videofile and starts playback (if autoplay is set to true).
		 * 
		 * @param videoUrl	url to videofile
		 */
		public function load(videoUrl:String):void
		{
			if(videoUrl == null)
			{
				trace("load() >>> videoUrl not set!");
				return;
			}
			
			videoMetaData = null;
			_videoUrl = videoUrl;
			
			if(_autoPlay || _loadBeforePlay)
			{
				_ns.play(videoUrl);
				
				_video.attachNetStream(_ns);
				_video.visible = true;
	
				_loaded = true;
							
				_loadTimer.start();
				_positionTimer.start();
				
				// hide image
				_image.visible = false;
			}
		}
		
		/**
		 * pauses video playback.
		 */
		public function pause():void
		{
			if(!_loaded)
			{
				return;
			}
			
			_ns.pause();
			_positionTimer.reset();
			
			videoState = ApdevVideoState.VIDEO_STATE_PAUSED;
		}
		
		/**
		 * starts video playback.
		 */
		public function play():void
		{
			if(!_loaded)
			{
				_loadBeforePlay = true;
				load(_videoUrl);
				return;
			}
			
			// hide image
			_image.visible = false;
			
			_ns.resume();
			_positionTimer.start();
			
			videoState = ApdevVideoState.VIDEO_STATE_PLAYING;
		}
		
		/**
		 * seeks to specified position in video.
		 * 
		 * @param seekPercent	percent to jump to in video
		 * @param scrubbing		if user is scrubbing on timeline
		 */
		public function seek(seekPercent:Number, scrubbing:Boolean=false):void 
		{
			if(seekPercent < 0)
			{
				// no negative pos allowed
				seekPercent = 0;
			}
			
			// don't allow seeking over loaded video
			if(seekPercent > _ns.bytesLoaded/_ns.bytesTotal)
			{
				seekPercent = _ns.bytesLoaded/_ns.bytesTotal;
			}
			
			if(!scrubbing)
			{
				_scrubbingIndex = 0;
			}
			else
			{
				++_scrubbingIndex;
			}
			
			if(_scrubbingIndex == 1)
			{
				_stateBeforeScrubbing = videoState;
				if(videoState == ApdevVideoState.VIDEO_STATE_PLAYING || 
					videoState == ApdevVideoState.VIDEO_STATE_STOPPED)
				{
					pause();
				}
			}
			
			_ns.seek(seekPercent * videoMetaData.duration);
			
			_videoControls.updatePlaying(seekPercent);
			
			if(!scrubbing)
			{
				if(_stateBeforeScrubbing == ApdevVideoState.VIDEO_STATE_PLAYING || 
					_stateBeforeScrubbing == ApdevVideoState.VIDEO_STATE_STOPPED)
				{
					play();
				}
			}
		}
		
		/**
		 * called automatically when video's metadata is loaded.
		 * 
		 * @param data	video's metadata
		 */
		public function onMetaData(data:Object):void
		{
			if(videoMetaData == null)
			{				
				videoMetaData = new VideoMetadataVo(data);
				if(!isNaN(videoMetaData.width) && !isNaN(videoMetaData.height))
				{
					_resizeVideo(videoMetaData.width, videoMetaData.height);
				}
			}
		}
		
		/**
		 * draws initial videoplayer components.
		 */
		private function _draw():void
		{
			_videoBg = new Sprite();
			_videoBg.addChild(Draw.gradientRect(videoPlayerWidth, videoPlayerHeight, 90, 0x393324, 0x000000, 1, 1));
			addChild(_videoBg);
			
			_video = new Video(videoPlayerWidth, videoPlayerHeight);
			_video.smoothing = true;
			addChild(_video);
			
			_videoControls = new ApdevVideoControls(videoPlayerWidth);
			controlsOverVideo = false;
			addChild(_videoControls);
			
			_image = new Sprite();
			_image.buttonMode = true;
			_image.visible = false;
			addChild(_image);
			
			_imageOverlay = new Loader();
			_image.addChild(_imageOverlay);
			
			_imageOverlayIcon = new IconPlay();
			_imageOverlayIcon.x = Math.round(videoPlayerWidth*0.5);
			_imageOverlayIcon.y = Math.round(videoPlayerHeight*0.5);
			_image.addChild(_imageOverlayIcon);
			
			var imageMask:Shape = Draw.rect(videoPlayerWidth, videoPlayerHeight, 0xFF0000, 1);
			addChild(imageMask);
			
			_imageOverlay.mask = imageMask;
		}
		
		/**
		 * initializes all important attributes and event listeners.
		 */
		private function _init(width:int, height:int):void
		{
			_trackIndex = 0;
			_offset = 0;
			_timeOffset = 0;
			_scrubbingIndex = 0;
			_autoPlay = false;
			_loadBeforePlay = false;
			_lastFullscreenTakeover = _fullscreenTakeover = false;
			
			if(width < ApdevVideoPlayer.MIN_WIDTH)
			{
				var videoRatio:Number = width / height;
				_videoPlayerWidth = ApdevVideoPlayer.MIN_WIDTH;
				_videoPlayerHeight = ApdevVideoPlayer.MIN_WIDTH / videoRatio;
			}
			else
			{
				_videoPlayerWidth = width;
				_videoPlayerHeight = height;
			}
			
			_draw();
			
			// debug :: volume = 0;
			videoState = ApdevVideoState.VIDEO_STATE_EMPTY;
			
			_loadTimer = new Timer(500);
			_loadTimer.addEventListener(TimerEvent.TIMER, onLoadTimerTick, false, 0, true);
			
			_positionTimer = new Timer(100);
			_positionTimer.addEventListener(TimerEvent.TIMER, onPositionTimerTick, false, 0, true);
			
			// fade out timer
			fadeOutTime = ApdevVideoPlayer.DEFAULT_CONTROLS_FADE_OUT_TIME;
			_fadeOutTimer = new Timer(fadeOutTime, 1);
			_fadeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onFadeOutTimerComplete, false, 0, true);
			
			_nc = new NetConnection();
			_nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true);
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError, false, 0, true);
			_nc.connect(null);
			
			addEventListener(VideoControlsEvent.SEEK, onSeek, false, 0, true);
			addEventListener(VideoControlsEvent.SCRUB, onSeek, false, 0, true);
			addEventListener(VideoControlsEvent.TOGGLE_PLAY_PAUSE, onTogglePlay, false, 0, true);
			addEventListener(VideoControlsEvent.SET_VOLUME, onChangeVolume, false, 0, true);
			addEventListener(VideoControlsEvent.ENTER_FULLSCREEN, onChangeDisplaystate, false, 0, true);
			
			// to start the video w/ click on videoplayer
			_videoBg.buttonMode = true;
			_videoBg.doubleClickEnabled = true;
			_videoBg.addEventListener(MouseEvent.CLICK, onClickVideo, false, 0, true);
			
			// 
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			
			// 
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			
			// image overlay
			_image.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverImage, false, 0, true);
			_image.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutImage, false, 0, true);
			_image.addEventListener(MouseEvent.CLICK, onClickVideo, false, 0, true);
			_imageOverlay.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded, false, 0, true);
		}
		
		/**
		 * initializes netstream.
		 */
		private function _initStream():void
		{
			_ns = new NetStream(_nc);
			_ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_ns.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);
			_ns.bufferTime = 5;
			_ns.client = this;
		}
		
		/**
		 * resizes video.
		 */
		private function _resizeVideo(width:Number, height:Number):void
		{
			var videoRatio:Number = videoMetaData.width / videoMetaData.height;
			var playerRatio:Number = width / height;
			
			if(videoRatio > playerRatio)
			{
				_video.width = width;
				_video.height = width / videoRatio;
			}
			else
			{
				_video.width = height * videoRatio;
				_video.height = height;
			}

			_video.x = Math.round((width - _video.width) * 0.5);
			_video.y = Math.round((height - _video.height) * 0.5);
		}
		
		/**
		 * toggles fullscreen view.
		 */
		private function _toggleFullscreen():void
		{
			if(videoMetaData == null)
			{
				return;
			}
			
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				_lastFullscreenTakeover = fullscreenTakeover; 
				fullscreenTakeover = true;
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		/**
		 * toggles video playback.
		 */
		private function _togglePlayPause():void
		{
			if(videoState == ApdevVideoState.VIDEO_STATE_PLAYING)
			{
				pause();
			}
			else if(videoState == ApdevVideoState.VIDEO_STATE_PAUSED ||
					videoState == ApdevVideoState.VIDEO_STATE_EMPTY)
			{
				play();
			}
			else if(videoState == ApdevVideoState.VIDEO_STATE_STOPPED)
			{
				seek(0);
				play();
			}
		}
		
		/**
		 * toggles videocontrol's visibility.
		 */
		private function _toggleVideoControls(show:Boolean):void
		{
			_videoControls.visible = show;
		}

		/**
		 * event handler - called when videoplayer is added to stage
		 * (only called once after initialisation).
		 */
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onDisplayStageChanged, false, 0, true);
		}
		
		/**
		 * event handler - called when video's volume changed.
		 */
		private function onChangeVolume(event:VideoControlsEvent):void
		{
			volume = event.data as Number;
		}
		
		/**
		 * event handler - called when user clicks on video.
		 */
		private function onClickVideo(event:MouseEvent):void
		{
			_togglePlayPause();
		}
		
		/**
		 * event handler - called when displaystate changes.
		 */
		private function onDisplayStageChanged(event:FullScreenEvent):void
		{
			if(!fullscreenTakeover)
			{
				return;
			}
			
			_videoControls.updateDisplayState(stage.displayState);
			
			if(event.fullScreen)
			{
				_lastStageAlign = stage.align; 
				stage.align = StageAlign.TOP_LEFT;
				
				_lastX = x;
				_lastY = y;
				
				x = 0;
				y = 0;
				
				var currentStage:Stage = stage;
				
				_lastParent = parent;
				_lastLevel = parent.getChildIndex(this);
				parent.removeChild(this);
				currentStage.addChild(this);
				
				_videoBg.width = stage.stageWidth;
				_videoBg.height = stage.stageHeight;
				
				_resizeVideo(stage.stageWidth, stage.stageHeight);
				
				// adjust controls
				_lastControlsAutoHide = controlsAutoHide;
				controlsAutoHide = true;
				
				_videoControls.x = Math.round( (stage.stageWidth - _videoControls.width) * 0.5);
				_videoControls.y = Math.round( stage.stageHeight - _videoControls.height - 100);
				
				// auto fade out controls
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			}
			else
			{
				_videoBg.width = _videoPlayerWidth;
				_videoBg.height = _videoPlayerHeight;
				
				_resizeVideo(videoPlayerWidth, videoPlayerHeight);
				
				stage.align = _lastStageAlign;

				x = _lastX;
				y = _lastY;
				
				stage.removeChild(this);
				_lastParent.addChildAt(this, _lastLevel);
				
				fullscreenTakeover = _lastFullscreenTakeover;
				
				// adjust controls
				controlsAutoHide = _lastControlsAutoHide;
				
				_videoControls.x = 0;
				if(controlsOverVideo)
				{
					_videoControls.y = videoPlayerHeight - _videoControls.height; 
				}
				else
				{
					_videoControls.y = videoPlayerHeight; 
				}
				
				// remove auto fade out
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_fadeOutTimer.reset();
				_toggleVideoControls(true);
			}
		}
		
		/**
		 * event handler - called when user clicks fullscreen toggle button.
		 */
		private function onChangeDisplaystate(event:VideoControlsEvent):void
		{
			_toggleFullscreen();
		}
		
		/**
		 * event handler - called when fade-out-timer is complete.
		 */
		private function onFadeOutTimerComplete(event:TimerEvent):void
		{
			_toggleVideoControls(false);
		}
		
		/**
		 * event handler - called when image is loaded.
		 */
		private function onImageLoaded(event:Event):void
		{
			var imageRatio:Number = _imageOverlay.width / _imageOverlay.height;
			var playerRatio:Number = _video.width / _video.height;
			var fraction:Number;
			
			if(imageRatio > playerRatio)
			{
				_imageOverlay.width = _video.width;
				_imageOverlay.height = _video.width / imageRatio;
				
				if(_imageOverlay.height < _video.height)
				{
					fraction = _video.height / _imageOverlay.height;
					_imageOverlay.width *= fraction;
					_imageOverlay.height *= fraction;
				}
			}
			else
			{
				_imageOverlay.width = _video.height * imageRatio;
				_imageOverlay.height = _video.height;

				if(_imageOverlay.width < _video.width)
				{
					fraction = _video.width / _imageOverlay.width;
					_imageOverlay.width *= fraction;
					_imageOverlay.height *= fraction;
				}
			}
			
			_imageOverlay.x = Math.round( (_video.width - _imageOverlay.width) * 0.5 );
			_imageOverlay.y = Math.round( (_video.height - _imageOverlay.height) * 0.5 ); 
		}
		
		/**
		 * event handler - called when mouse leaves image.
		 */
		private function onMouseOutImage(event:MouseEvent):void
		{
			_imageOverlayIcon.alpha = 0.3;			
		}

		/**
		 * event handler - called when mouse rolls over image.
		 */
		private function onMouseOverImage(event:MouseEvent):void
		{
			_imageOverlayIcon.alpha = 0.5;
		}

		/**
		 * event handler - called when mouse moves.
		 */
		private function onMouseMove(event:MouseEvent):void
		{
			_toggleVideoControls(true);
			
			_fadeOutTimer.reset();
			_fadeOutTimer.start();
		}

		/**
		 * event handler - called when mouse leaves videoplayer.
		 */
		private function onMouseOut(event:MouseEvent):void
		{
			if(_controlsAutoHide)
			{
				_toggleVideoControls(false);
			}
		}

		/**
		 * event handler - called when mouse rolls over videoplayer.
		 */
		private function onMouseOver(event:MouseEvent):void
		{
			if(_controlsAutoHide)
			{
				_toggleVideoControls(true);
			}
		}
		
		/**
		 * event handler - called when video play state changes.
		 */
		private function onTogglePlay(event:VideoControlsEvent):void
		{
			_togglePlayPause();
		}
		
		/**
		 * event handler - called when user seeks to a new position.
		 */
		private function onSeek(event:VideoControlsEvent):void
		{
			seek(event.data as Number, event.type == VideoControlsEvent.SCRUB);
		}

		/**
		 * event handler - called when asynchronous error occurs.
		 */
		private function onAsyncError(event:ErrorEvent):void
		{
			trace("onAsyncError() >>> " + event.text);
		}

		/**
		 * event handler - called when error occurs.
		 */
		private function onError(event:ErrorEvent):void
		{
			trace("onError() >>> " + event.text);			
		}
		
		/**
		 * event handler - called when load timer ticks
		 * (updates loading status).
		 */
		private function onLoadTimerTick(event:TimerEvent):void
		{
			if(_ns != null)
			{
				//log.debug("onLoadTimerTick() " + _ns.bytesLoaded + "/" + _ns.bytesTotal);
				_videoControls.updateLoading(_ns.bytesLoaded/_ns.bytesTotal);
				
				if(_ns.bytesLoaded >= _ns.bytesTotal)
				{
					_loadTimer.reset();
				}
			}
		}
		
		/**
		 * event handler - called when net-status changes.
		 */
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch(event.info["code"])
			{
				case "NetStream.Play.Start":
					if(videoState != ApdevVideoState.VIDEO_STATE_PAUSED)
					{
						videoState = ApdevVideoState.VIDEO_STATE_PLAYING;
					}
				break;

				case "NetStream.Play.Stop":
					videoState = ApdevVideoState.VIDEO_STATE_STOPPED;
				break;
				
				case "NetConnection.Connect.Success":
					_initStream();
				break;
				
				case "NetConnection.Connect.Failed":
					trace(event.info["code"]);
				break;
			}
		}
		
		/**
		 * event handler - called when position timer ticks
		 * (updates playing status).
		 */
		private function onPositionTimerTick(event:TimerEvent):void
		{
			if(videoMetaData == null)
			{
				return;
			}
			
			_videoControls.updatePlaying(_ns.time / videoMetaData.duration);
			
			if(videoState == ApdevVideoState.VIDEO_STATE_STOPPED)
			{
				_positionTimer.reset();
			}
		}
		
		/**
		 * video's metadata.
		 */
		public function get videoMetaData():VideoMetadataVo
		{
			return _videoMetaData;
		}

		public function set videoMetaData(meta:VideoMetadataVo):void
		{
			_videoMetaData = meta;
			
			if(meta != null)
			{
				_videoControls.meta = meta;
			}
		}
		
		/**
		 * video's current state.
		 */
		public function get videoState():String
		{
			return _videoState;
		}

		public function set videoState(state:String):void
		{
			_videoState = state;
			
			if(_ns != null)
			{
				_videoControls.state = state;
			}
		}
		
		/**
		 * video's current volume.
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(volume:Number):void
		{
			_volume = volume;
			SoundMixer.soundTransform = new SoundTransform(volume); 
			
			_videoControls.volume = volume;
		}
		
		/**
		 * videoplayer's current width.
		 */
		public function get videoPlayerWidth():int
		{
			return _videoPlayerWidth;
		}
		
		public function set videoPlayerWidth(videoPlayerWidth:int):void
		{
			_videoPlayerWidth = videoPlayerWidth;
		}
		
		/**
		 * videoplayer's current height.
		 */
		public function get videoPlayerHeight():int
		{
			return _videoPlayerHeight;
		}
		
		public function set videoPlayerHeight(videoPlayerHeight:int):void
		{
			_videoPlayerHeight = videoPlayerHeight;
		}
		
		/**
		 * flag that sets the position of the videoplayer's controls
		 * (laying over or at the bottom of the video).  
		 */
		public function get controlsOverVideo():Boolean
		{
			return _controlsOverVideo;
		}
		
		public function set controlsOverVideo(controlsOverVideo:Boolean):void
		{
			_controlsOverVideo = controlsOverVideo;
			
			if(_controlsOverVideo)
			{
				_videoControls.y = videoPlayerHeight - _videoControls.height; 
			}
			else
			{
				_videoControls.y = videoPlayerHeight; 
			}
		}
		
		/**
		 * start video directly or wait for a call of the play method.  
		 */
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
		
		public function set autoPlay(autoPlay:Boolean):void
		{
			_autoPlay = autoPlay;
		}
		
		/**
		 * flag that hides the video's controls automatically.
		 */
		public function get controlsAutoHide():Boolean
		{
			return _controlsAutoHide;
		}
		
		public function set controlsAutoHide(controlsAutoHide:Boolean):void
		{
			_controlsAutoHide = controlsAutoHide;
			
			if(_controlsAutoHide)
			{
				_toggleVideoControls(false); 
			}
			else
			{
				_toggleVideoControls(true); 
			}
		}
		
		/**
		 * flag whether or not the videoplayer shows in fullscreen when the
		 * displaystate changes to DisplayState.FULLSCREEN.
		 */
		public function get fullscreenTakeover():Boolean
		{
			return _fullscreenTakeover;
		}
		
		public function set fullscreenTakeover(fullscreenTakeover:Boolean):void
		{
			_fullscreenTakeover = fullscreenTakeover;
		}
		
		/**
		 * time in milliseconds that the controls take to fade out.
		 */
		public function get fadeOutTime():int
		{
			return _fadeOutTime;
		}
		
		public function set fadeOutTime(fadeOutTime:int):void
		{
			_fadeOutTime = fadeOutTime;
		}
		
		/**
		 * set the previewimage's url (or URLRequest)
		 * (shows before video is playing).
		 */
		public function get videostill():*
		{
			return _previewUrlOrRequest;
		}
		
		public function set videostill(previewUrlOrRequest:*):void
		{
			_previewUrlOrRequest = previewUrlOrRequest;
			
			if(_previewUrlOrRequest is URLRequest)
			{
				_imageOverlay.load(_previewUrlOrRequest);
			}
			else if(_previewUrlOrRequest is String)
			{
				var req:URLRequest = new URLRequest(_previewUrlOrRequest);
				_imageOverlay.load(req);
			}
			
			if(videoState == ApdevVideoState.VIDEO_STATE_EMPTY)
			{
				_image.visible = true;
			}
		}
	}
}
