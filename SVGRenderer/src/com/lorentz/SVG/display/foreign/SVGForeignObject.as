package com.lorentz.SVG.display.foreign {
	import com.lorentz.SVG.display.SVGImage;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGForeignObject extends SVGContainer {	
		public function SVGForeignObject(){
			super("foreignobject");
		}
		
		private var _svgWidth:String;
		public function get svgWidth():String {
			return _svgWidth;
		}
		public function set svgWidth(value:String):void {
			if(_svgWidth != value){
				_svgWidth = value;
			}
		}
		
		private var _svgHeight:String;
		public function get svgHeight():String {
			return _svgHeight;
		}
		public function set svgHeight(value:String):void {
			if(_svgHeight != value){
				_svgHeight = value;
			}
		}
		
		override public function clone():Object {
			var c:SVGForeignObject = super.clone() as SVGForeignObject;
			c.svgWidth = svgWidth;
			c.svgHeight = svgHeight;
			return c;
		}
	}
}