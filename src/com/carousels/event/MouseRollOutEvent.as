package com.carousels.event
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	public class MouseRollOutEvent extends MouseEvent
	{
		private var _data:Object;

		public static const MOUSE_ROLL_OUT:String = "MouseRollOut";
		
		public function MouseRollOutEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, inData:Object=null)
		{
			super(type, bubbles, cancelable);
			_data = inData;
		}
		
		/**
		 * Data
		 */
		public function get data():Object
		{
			return _data;
		}
		
		public function set data( value:Object ):void
		{
			_data = value;
		}
		
	}
}