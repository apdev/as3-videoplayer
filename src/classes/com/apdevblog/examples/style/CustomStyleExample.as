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
package com.apdevblog.examples.style 
{
	import com.apdevblog.ui.video.style.ApdevVideoPlayerDefaultStyle;

	/**
	 * Custom style-sheet for a custom VideoPlayer.
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.examples.style
	 * @author     phil / philipp[at]beta-interactive.de
	 * @copyright  2009 beta_interactive
	 * @version    SVN: $Id$
	 */
	public class CustomStyleExample extends ApdevVideoPlayerDefaultStyle 
	{
		/**
		 * constructor.
		 */
		public function CustomStyleExample()
		{
			// player
			bgGradient1 = 0x333333;
			bgGradient2 = 0x000000;
			//
			controlsBgAlpha = 1.0;
			//
			btnGradient1 = 0x333333;
			btnGradient2 = 0x000000;
			btnIcon = 0x66ff00;
			btnRollOverGlowAlpha = 0.2;
			//
			timerUp = 0x66ff00;
			timerDown = 0x999999;
			//
			barBg = 0x333333;
			barBgAlpha = 0.5;
			barLoading = 0x333333;
			barPlaying = 0x66ff00;
			//
			playIcon = 0x000000;
			//
			controlsPaddingLeft = 3;
			controlsPaddingRight = 3;
		}
	}
}
