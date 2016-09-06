package com.lorentz.SVG.display {
	import com.lorentz.SVG.data.path.SVGArcToCommand;
	import com.lorentz.SVG.data.path.SVGCurveToCubicCommand;
	import com.lorentz.SVG.data.path.SVGCurveToCubicSmoothCommand;
	import com.lorentz.SVG.data.path.SVGCurveToQuadraticCommand;
	import com.lorentz.SVG.data.path.SVGCurveToQuadraticSmoothCommand;
	import com.lorentz.SVG.data.path.SVGLineToCommand;
	import com.lorentz.SVG.data.path.SVGLineToHorizontalCommand;
	import com.lorentz.SVG.data.path.SVGLineToVerticalCommand;
	import com.lorentz.SVG.data.path.SVGMoveToCommand;
	import com.lorentz.SVG.data.path.SVGPathCommand;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGGraphicsElement;
	import com.lorentz.SVG.parser.SVGParserCommon;
	
	import mx.controls.DateField;
	
	import spark.effects.Animate;
	import spark.effects.Fade;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	public class SVGAnimate extends SVGGraphicsElement {	
		private var _invalidPathFlag:Boolean = false;
		
		private var _dur:Number;
		
		public function SVGAnimate(tagName:String = "animate"){
			super(tagName);
		}
		
		public function get svgAttributeName():String {
			return getAttribute("attributeName") as String;
		}
		public function set svgAttributeName(value:String):void {
			setAttribute("attributeName", value);
		}
		
		public function get svgBegin():String {
			return getAttribute("begin") as String;
		}
		public function set svgBegin(value:String):void {
			setAttribute("begin", value);
		}
		
		public function get svgFrom():String {
			return getAttribute("from") as String;
		}
		public function set svgFrom(value:String):void {
			setAttribute("from", value);
		}
		
		public function get svgTo():String {
			return getAttribute("to") as String;
		}
		public function set svgTo(value:String):void {
			setAttribute("to", value);
		}
		
		public function get svgDur():String {
			return getAttribute("dur") as String;
		}
		public function set svgDur(value:String):void {
			setAttribute("dur", value);
		}
		
		public function get dur():Number {
			return _dur;
		}
		public function set dur(value:Number):void {
			_dur = value;
			invalidateRender();
		}
		
		public function get svgRepeatCount():String {
			return getAttribute("repeatCount") as String;
		}
		public function set svgRepeatCount(value:String):void {
			setAttribute("repeatCount", value);
		}
		
		override protected function onAttributeChanged(attributeName:String, oldValue:Object, newValue:Object):void {
			super.onAttributeChanged(attributeName, oldValue, newValue);
			
			switch(attributeName){
				case "attributeName" :
					_invalidPathFlag = true;
					invalidateProperties();
					break;
				case "begin" :
					_invalidPathFlag = true;
					invalidateProperties();
					break;
				case "from" :
					_invalidPathFlag = true;
					invalidateProperties();
					break;
				case "to" :
					_invalidPathFlag = true;
					invalidateProperties();
					break;
				case "dur" :
					_invalidPathFlag = true;
					dur = SVGParserCommon.parseDuration(svgDur);
					invalidateProperties();
					break;
				case "repeatCount" :
					_invalidPathFlag = true;
					invalidateProperties();
					break;
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_invalidPathFlag)
			{
				_invalidPathFlag = false;
			}
		}
		
		override protected function render():void {
			super.render();
			
			switch(svgAttributeName){
				case "opacity" :
					var fade:Fade = new Fade(this.parentElement);
					fade.alphaFrom = Number(svgBegin);
					fade.alphaTo = Number(svgTo);
					fade.duration = dur;
					fade.repeatCount = (svgRepeatCount == "indefinite"? 0 : Number(svgRepeatCount));
					fade.end();
					fade.play();
					break;
			}
		}
		
		override public function clone():Object {
			var c:SVGAnimate = super.clone() as SVGAnimate;
			
//			c.svgAttributeName = svgAttributeName;
//			c.svgBegin = svgBegin;
//			c.svgFrom = svgFrom;
//			c.svgTo = svgTo;
//			c.svgDur = svgDur;
//			c.svgRepeatCount = svgRepeatCount;
			
			return c;
		}
	}
}

