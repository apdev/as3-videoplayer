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
	import com.apdevblog.examples.style.CustomStyleExample;
	import com.apdevblog.ui.video.ApdevVideoPlayer;

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
			var vUrl:String = loaderInfo.parameters["v"];
			var vScreen:String = loaderInfo.parameters["img"];
			
			// create own style
			var style:CustomStyleExample = new CustomStyleExample();
			// flag to tell the player to ignore style passed via flashvars
			style.ignoreFlashvars = false;
			// pass flashvars to be parsed for style information
			style.feedFlashvars(loaderInfo.parameters);
			
			// create videoplayer
			var video:ApdevVideoPlayer = new ApdevVideoPlayer(stage.stageWidth, stage.stageHeight, style);
			
			// add videoplayer to stage
			addChild(video);
			
			// position the videoplayer's controls at the bottom of the video
			video.controlsOverVideo = true;
			
			// controls should not fade out (when not in fullscreen mode)
			video.controlsAutoHide = true;
			
			// load preview image
			video.videostill = vScreen;
			
			// set video's autoplay to false
			video.autoPlay = false;
			
			// load video
			video.load(vUrl);
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
	}
}
