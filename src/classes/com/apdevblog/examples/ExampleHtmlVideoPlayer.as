package com.apdevblog.examples 
{
	import com.apdevblog.events.video.VideoControlsEvent;
	import com.apdevblog.examples.style.CustomStyleExample;
	import com.apdevblog.ui.video.ApdevVideoPlayer;
	import com.apdevblog.ui.video.ApdevVideoState;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.fscommand;

	/**
	 * Example file of the ApdevVideoPlayer (embed wrapper).
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.examples
	 * @author     Philipp Kyeck / phil[at]apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * @version    SVN: $Id$
	 */
	[SWF(backgroundColor="#ffffff", frameRate="30", width="320", height="240")]
	public class ExampleHtmlVideoPlayer extends Sprite 
	{
		public static const PLAYLIST_DELIM:String = "|";
		//
		private var _playlist:Array;
		private var _hasPlayist:Boolean;
		private var _currentVideo:int;
		private var _repeat:Boolean;
		private var _videoUrl:String;
		private var _videoPlayer:ApdevVideoPlayer;

		/**
		 * adding onEnterFrame listener and setting stage attributes.
		 */
		public function ExampleHtmlVideoPlayer()
		{
			// hide menu
			fscommand("showmenu", "false");

			// adjust stage's scalemode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		/**
		 * adding ApdevVideoPlayer to stage and resizing it to full size.
		 */
		private function _init():void
		{
			// get flashvars-parameters
			_videoUrl = loaderInfo.parameters["v"];
			
			// playlist + repeat variables			
			_hasPlayist = false;
			_currentVideo = 0;
			_playlist = [];
			_repeat = loaderInfo.parameters["repeat"] == "true";
			
			// check for playlist
			if(_videoUrl != null && 
				_videoUrl.indexOf(ExampleHtmlVideoPlayer.PLAYLIST_DELIM) != -1)
			{
				_hasPlayist = true;
				_playlist = _videoUrl.split(ExampleHtmlVideoPlayer.PLAYLIST_DELIM);
				
				_videoUrl = _playlist[_currentVideo];
			}
			
			// create own style
			var style:CustomStyleExample = new CustomStyleExample();
			// flag to tell the player to ignore style passed via flashvars
			style.ignoreFlashvars = false;
			// pass flashvars to be parsed for style information
			style.feedFlashvars(loaderInfo.parameters);

			// create videoplayer
			_videoPlayer = new ApdevVideoPlayer(stage.stageWidth, stage.stageHeight, style);

			// add eventlistener
			_videoPlayer.addEventListener(VideoControlsEvent.STATE_UPDATE, onStateUpdate, false, 0, true);

			// add videoplayer to stage
			addChild(_videoPlayer);
			
			// position the videoplayer's controls at the bottom of the video
			_videoPlayer.controlsOverVideo = true;
			
			// controls should not fade out (when not in fullscreen mode)
			_videoPlayer.controlsAutoHide = true;
			
			// set video's autoplay to false
			_videoPlayer.autoPlay = loaderInfo.parameters["autoplay"] == "true";
			
			// load preview image
			if(!_videoPlayer.autoPlay)
			{
				_videoPlayer.videostill = loaderInfo.parameters["img"];
			}
			
			// load video
			_videoPlayer.load(_videoUrl);
		}
		
		/**
		 * plays next video in playlist.
		 */
		private function _playNext():void
		{
			++_currentVideo;
			if(_currentVideo > _playlist.length-1)
			{
				if(_repeat)
				{
					if(_playlist.length > 0)
					{
						_currentVideo = 0;
					}
					else
					{
						_videoPlayer.play();
						return;
					}
				}
				else
				{
					return;
				}
			}
			
			_videoUrl = _playlist[_currentVideo];
			_videoPlayer.load(_videoUrl);
		}

		/**
		 * enter-frame event handler
		 */
		private function onEnterFrame(event:Event):void
		{
			if(loaderInfo.bytesLoaded == loaderInfo.bytesTotal && stage != null) 
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_init();
				// add stage resize listener
				stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
			}
		}
		
		/**
		 * event handler called when stage changes size
		 */		
		private function onStageResize(event:Event):void
		{
			if(_videoPlayer != null)
			{
				_videoPlayer.resize(stage.stageWidth, stage.stageHeight);
			}
		}
		
		/**
		 * state update event handler
		 */		
		private function onStateUpdate(event:VideoControlsEvent):void
		{
			if(event.data == ApdevVideoState.VIDEO_STATE_STOPPED)
			{
				_playNext();
			}
		}
	}
}
