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
package com.apdevblog.ui.video.controls 
{
	import flash.net.URLRequest;

	import com.apdevblog.events.video.VideoControlsEvent;
	import com.apdevblog.utils.Draw;

	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * Image overlay - can e.g. display a screenshot of the video.
	 * Only shown when video playback is set to autoplay = false. 
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.ui.video.controls
	 * @author     Philipp Kyeck / phil[at]apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * @version    SVN: $Id$
	 */
	public class ImageOverlay extends Sprite 
	{
		private var _imageLoader:Loader;
		private var _imageOverlayIcon:IconPlay;
		private var _videoPlayerWidth:Number;
		private var _videoPlayerHeight:Number;
		
		/**
		 * creates image overlay.
		 * 
		 * @param w		width of the videoplayer
		 * @param h		height of the videoplayer
		 */
		public function ImageOverlay(w:Number, h:Number)
		{
			_init(w, h);
		}
		
		/**
		 * loads image and displays it on stage.
		 * 
		 * @param req	URLRequest which image is to be loaded 
		 */
		public function load(req:URLRequest):void
		{
			if(req == null)
			{
				return;
			}
			_imageLoader.load(req);
		}
		
		/**
		 * draws all relevant elements on stage.
		 */
		private function _draw():void
		{
			_imageLoader = new Loader();
			addChild(_imageLoader);
			
			_imageOverlayIcon = new IconPlay();
			_imageOverlayIcon.x = Math.round(_videoPlayerWidth*0.5);
			_imageOverlayIcon.y = Math.round(_videoPlayerHeight*0.5);
			addChild(_imageOverlayIcon);
			
			var imageMask:Shape = Draw.rect(_videoPlayerWidth, _videoPlayerHeight, 0xFF0000, 1);
			addChild(imageMask);
			
			mask = imageMask;
		}
		
		/**
		 * initializes component.
		 */
		private function _init(w:Number, h:Number):void
		{
			_videoPlayerWidth = w;
			_videoPlayerHeight = h;
			
			buttonMode = true;
			
			_draw();
			
			// image overlay
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverImage, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutImage, false, 0, true);
			addEventListener(MouseEvent.CLICK, onClickImageOverlay, false, 0, true);
			//
			_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded, false, 0, true);
		}
		
		/**
		 * event handler - called when overlay is clicked.
		 */
		private function onClickImageOverlay(event:MouseEvent):void
		{
			dispatchEvent(new VideoControlsEvent(VideoControlsEvent.TOGGLE_PLAY_PAUSE, true, true));
		}

		/**
		 * event handler - called when image is loaded.
		 */
		private function onImageLoaded(event:Event):void
		{
			var imageRatio:Number = _imageLoader.width / _imageLoader.height;
			var w:Number = _videoPlayerWidth;	// _video.width
			var h:Number = _videoPlayerHeight;	// _video.height
			var playerRatio:Number = w / h;
			var fraction:Number;
			
			if(imageRatio > playerRatio)
			{
				_imageLoader.width = w;
				_imageLoader.height = w / imageRatio;
				
				if(_imageLoader.height < h)
				{
					fraction = h / _imageLoader.height;
					_imageLoader.width *= fraction;
					_imageLoader.height *= fraction;
				}
			}
			else
			{
				_imageLoader.width = h * imageRatio;
				_imageLoader.height = h;

				if(_imageLoader.width < w)
				{
					fraction = w / _imageLoader.width;
					_imageLoader.width *= fraction;
					_imageLoader.height *= fraction;
				}
			}
			
			_imageLoader.x = Math.round( (w - _imageLoader.width) * 0.5 );
			_imageLoader.y = Math.round( (h - _imageLoader.height) * 0.5 ); 
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
	}
}
