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
	import com.apdevblog.ui.video.ApdevVideoPlayer;

	import flash.display.Sprite;
	import flash.display.StageScaleMode;

	/**
	 * Example file for the ApdevVideoPlayer.
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.examples 
	 * @author     Philipp Kyeck / philipp[at]apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * @version    SVN: $Id$
	 * 
	 * @see com.apdevblog.ui.video.ApdevVideoPlayer ApdevVideoPlayer
	 */
	[SWF(backgroundColor="#000000", frameRate="30", width="550", height="400")]
	public class ExampleVideoPlayer extends Sprite 
	{
		/**
		 * adding ApdevVideoPlayer to stage ...
		 */
		public function ExampleVideoPlayer()
		{
			// adjust stage's scalemode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// create videoplayer
			var video:ApdevVideoPlayer = new ApdevVideoPlayer(320, 240);
			
			// position videoplayer on stage
			video.x = 25;
			video.y = 25;
			// add videoplayer to stage
			addChild(video);
			
			// add eventlistener
			video.addEventListener(VideoControlsEvent.STATE_UPDATE, onStateUpdate, false, 0, true);
			
			// position the videoplayer's controls at the bottom of the video
			video.controlsOverVideo = false;
			// controls should not fade out (when not in fullscreen mode)
			video.controlsAutoHide = false;
			// load preview image
			video.videostill = "videostill.jpg";
			// set video's autoplay to false
			video.autoPlay = false;
			// load video
			video.load("video01.mp4");
		}
		
		/**
		 * event listener - called when videoplayer's state changes.
		 */
		private function onStateUpdate(event:VideoControlsEvent):void
		{
			trace("onStateUpdate() >>> " + event.data);
		}
	}
}
