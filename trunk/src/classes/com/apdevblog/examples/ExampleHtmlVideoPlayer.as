package com.apdevblog.examples 
{
	import flash.display.StageAlign;
	import com.apdevblog.ui.video.ApdevVideoPlayer;

	import flash.display.Sprite;
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
			var vUrl:String = loaderInfo.parameters["v"];
			var vScreen:String = loaderInfo.parameters["img"];
			
			// create videoplayer
			var video:ApdevVideoPlayer = new ApdevVideoPlayer(stage.stageWidth, stage.stageHeight);
			
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
