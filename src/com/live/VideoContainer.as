package com.live
{
	import flash.display.Sprite;
	import flash.media.Video;
	
	import mx.core.UIComponent;
	
	
	public class VideoContainer extends UIComponent
	{
    	
        private var _border:Sprite;
        private var _video:Video;
        private var _bg:Sprite;
    
    	private var _width:uint = 240;
    	private var _height:uint = 150;
    	
        
		public function VideoContainer()
		{
			super();
			/*
			* background color
			*/
			_bg = new Sprite();
			_bg.graphics.beginFill(0x000000, 1.0);
			_bg.graphics.drawRect(0,0,_width,_height);
			_bg.graphics.endFill();
			addChild(_bg);
			/*
			* video object
			*/
			_video = new Video( _width, _height );
			_video.smoothing = true;
			addChild(_video);
			/*
			* border color
			*/
			_border = new Sprite();
			_border.graphics.lineStyle(0, 0x000000);
			_border.graphics.drawRect(0,0,_width,_height);
			addChild(_border);

		}

        public function set video(video:Video):void
        {
            if (_video != null)
            {
                removeChild(_video);
            }

			_video = video;

           	if (_video != null)
            {
	            _video.width = width;
                _video.height = height;
                addChild(_video);
            }
        }
        
        public function get video():Video
        {
        	return _video;
        }
        
        
        override protected function measure():void
		{
			super.measure();
		}
		
        
        override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			_bg.width = _border.width = _video.width = unscaledWidth;
            _bg.height = _border.height = _video.height = unscaledHeight;

		}
	
	}
}