package com.carousels
{
	import flash.display.Sprite;
	
	public class Photo3D extends Sprite
	{
		private var userN:String;
		private var screenN:String;
		
		public function Photo3D()
		{
			super()
		}

		public function set username(name:String):void{
			userN = name;
		}
		
		public function get username():String{
			return userN;
		}

		public function set screenname(name:String):void{
			screenN = name;
		}
		
		public function get screenname():String{
			return screenN;
		}

	}
}