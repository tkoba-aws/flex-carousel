package media
{
	import mx.controls.Image;

	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	[Style(name="borderAlpha", type="Number", format="Length", inherit="no")]

	public class CustomImage extends Image
	{
		private var _message:String;
		private var _screenname:String;
		private var _category:String;
		private var _userid:String;
		private var _username:String;
		private var _url:String;
		private var _borderOn:Boolean;
		
		public function CustomImage(borderOn:Boolean=false)
		{
			super();
			_borderOn = borderOn;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			if(_borderOn){
				x+=(getStyle('borderThickness')/2);
				y+=(getStyle('borderThickness')/2);
				graphics.lineStyle(getStyle('borderThickness'),getStyle('borderColor'),getStyle('borderAlpha'),false);
				graphics.drawRect(-(getStyle('borderThickness')/2),-(getStyle('borderThickness')/2)-1,this.width+getStyle('borderThickness'),this.height+getStyle('borderThickness')+1);
			}
			super.updateDisplayList(w,h);
		}
		
		public function set screenname(name:String):void{ _screenname = name; }
		
		public function get screenname():String{ return _screenname }
		
		public function set userid(id:String):void{ _userid = id; }
		
		public function get userid():String{ return _userid }
		
		public function set username(name:String):void{ _username = name }
		
		public function get username():String{ return _username }
		
		public function set category(id:String):void{ _category = id }
		
		public function get category():String{ return _category }
		
		public function set message(message:String):void{ _message = message }
		
		public function get message():String{ return _message }
		
		public function set url(url:String):void{ _url = url }
		
		public function get url():String{ return _url }
	}
}