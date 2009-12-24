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
package com.apdevblog.examples 
{
	import com.apdevblog.events.video.VideoControlsEvent;
	import com.apdevblog.examples.style.CustomStyleGrey;
	import com.apdevblog.ui.video.ApdevVideoPlayer;
	import com.apdevblog.ui.video.ApdevVideoState;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.fscommand;

	/**
	 * Example of skinned HTML VideoPlayer.
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.examples
	 * @author     phil / philipp[at]beta-interactive.de
	 * @copyright  2009 beta_interactive
	 * @version    SVN: $Id$
	 */
	public class ExampleHtmlVideoPlayerSkinned extends Sprite 
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
		public function ExampleHtmlVideoPlayerSkinned()
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
			var vScreen:String = loaderInfo.parameters["img"];
			
			// create own style
			var style:CustomStyleGrey = new CustomStyleGrey();
			// flag to tell the player to ignore style passed via flashvars
			style.ignoreFlashvars = false;
			// pass flashvars to be parsed for style information
			style.feedFlashvars(loaderInfo.parameters);
			
			// playlist + repeat variables			
			_hasPlayist = false;
			_currentVideo = 0;
			_playlist = [];
			_repeat = loaderInfo.parameters["repeat"] == "true";
			
			// check for playlist
			if(_videoUrl.indexOf(ExampleHtmlVideoPlayer.PLAYLIST_DELIM) != -1)
			{
				_hasPlayist = true;
				_playlist = _videoUrl.split(ExampleHtmlVideoPlayer.PLAYLIST_DELIM);
				
				_videoUrl = _playlist[_currentVideo];
			}
			
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
				_videoPlayer.videostill = vScreen;
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
		 * onEnterFrame event handler
		 */
		private function onEnterFrame(event:Event):void
		{
			if(loaderInfo.bytesLoaded == loaderInfo.bytesTotal) 
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_init();
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
