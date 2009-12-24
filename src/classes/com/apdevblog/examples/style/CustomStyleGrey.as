package com.apdevblog.examples.style 
{
	import com.apdevblog.ui.video.style.ApdevVideoPlayerDefaultStyle;

	/**
	 * Custom style-sheet for a Apdev VideoPlayer (grey).
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.examples.style
	 * @author     phil / phil [ at ] apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * @version    SVN: $Id$
	 */
	public class CustomStyleGrey extends ApdevVideoPlayerDefaultStyle 
	{
		public function CustomStyleGrey()
		{
			// player
			bgGradient1 = 0x333333;
			bgGradient2 = 0x000000;
			//
			controlsBgAlpha = 1.0;
			//
			btnGradient1 = 0x333333;
			btnGradient2 = 0x000000;
			btnIcon = 0xCCCCCC;
			btnRollOverGlowAlpha = 0.2;
			//
			timerUp = 0xCCCCCC;
			timerDown = 0x999999;
			//
			barBg = 0x333333;
			barBgAlpha = 0.5;
			barLoading = 0x333333;
			barPlaying = 0xCCCCCC;
			//
			playIcon = 0x000000;
			//
			controlsPaddingLeft = 3;
			controlsPaddingRight = 3;
		}
	}
}
