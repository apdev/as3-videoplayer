# Apdev ActionScript 3.0 VideoPlayer #
Easy to use open-source ActionScript 3.0 VideoPlayer able to playback all flash-compatible video-formats like FLV (on2, sorenson) or even MOV (h.264) and can be integrated in every flash project you're currently working on.

The example videoplayer is only 11.5KB in size - compared to about 70-80KB if you'd be using the built-in FLVPlayback component.

### Updates ###

**VERSION 1.0.1:**
We added a wrapper for embedding the videoplayer into a HTML page - check out the example here: <a href='http://apdevblog.com/examples/apdev_videoplayer/html.html'>Embed Apdev VideoPlayer into HTML</a>

**VERSION 1.0.2:**
there's now also a <a href='http://apdevblog.com/examples/apdev_videoplayer/html_skinned.html'>skinned version</a> of the HTML-VideoPlayer.
Take a look at the <a href='http://apdevblog.com/examples/apdev_videoplayer/docs/com/apdevblog/ui/video/style/ApdevVideoPlayerDefaultStyle.html'>ApdevVideoPlayerDefaultStyle.as</a> to get an overview over the customizable attributes of the Apdev VideoPlayer.
You can set them in ActionScript or just pass them from HTML via flashvars.

**VERSION 1.0.3:**
implemented simple playlist support and a repeat parameter for the playlist.
added a new function to the videoplayer API (resize(width, height)) which resizes the whole player - we're using this one for the full-browser videoplayer you can find here: <a href='http://apdevblog.com/examples/apdev_videoplayer/htmlvideo_fullbrowser.html'>Apdev VideoPlayer full-browser version</a>

## Code documentation ##
<a href='http://apdevblog.com/examples/apdev_videoplayer/docs/'>Apdev VideoPlayer code documentation</a>


## Screenshot of example player ##
Standard Apdev VideoPlayer normal colorset

<img src='http://apdevblog.com/examples/apdev_videoplayer/screenshot.jpg' />

customized VideoPlayer with "apdev" colorset (could be any colors you want)

<img src='http://apdevblog.com/examples/apdev_videoplayer/screenshot_skinned.jpg' />

## Code example (ActionScript) ##

```
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

// ...
/**
 * event listener - called when videoplayer's state changes.
 */
private function onStateUpdate(event:VideoControlsEvent):void
{
	trace("onStateUpdate() >>> " + event.data);
}
```

## Code example (HTML version - using SWFObject) ##

```

// ...

<script type="text/javascript" src="js/swfobject.js"></script>
<script type="text/javascript">
    // <![CDATA[

    var width=380;
    var height=240;
	
    var flashVersion = "9.0.115";

    var movie = "htmlvideo.swf";

    var movieName = "flashMovie";
    var bgColor = "#ffffff";

    var express = "expressinstall.swf";
    
    var replaceDiv = "flashcontent";

    var flashvars = {};
    flashvars.v = "video01.mp4";
    flashvars.img = "videostill.jpg";
    flashvars.playIcon = "#ff0000";
    flashvars.controlsBg = "#ff00ff";
    flashvars.controlsBgAlpha = 1.0;

    var params = {};
    params.bgcolor = bgColor;
    params.menu = "false";
    params.scale = "noscale";
    params.allowFullScreen = "true";
    params.allowScriptAccess = "always";

    var attributes = {};
    attributes.id = movieName;

    swfobject.embedSWF(movie, replaceDiv, width, height, flashVersion, express, flashvars, params, attributes);

  // ]]>
</script>

// ...

<div id="flashdiv">
    <div id="flashcontent">
      alternativ content
    </div>
</div>

// ...

```