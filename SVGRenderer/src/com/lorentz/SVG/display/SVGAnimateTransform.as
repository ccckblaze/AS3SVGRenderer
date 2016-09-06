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
	
	import flash.display.Sprite;
	
	import mx.controls.DateField;
	import mx.effects.Rotate;
	
	import spark.components.Group;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	public class SVGAnimateTransform extends SVGAnimate {	
		
		public function SVGAnimateTransform(){
			super("animatetransform");
		}
		
		public function get svgType():String {
			return getAttribute("type") as String;
		}
		public function set svgType(value:String):void {
			setAttribute("type", value);
		}
		
		override protected function onAttributeChanged(attributeName:String, oldValue:Object, newValue:Object):void {
			super.onAttributeChanged(attributeName, oldValue, newValue);
			
			switch(attributeName){
				case "type" :
					invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
		}
		
		override protected function render():void {
			super.render();
			
			switch(svgType){
				case "rotate":
					// Create the animation					
					var animate:Rotate = new Rotate(this.parentElement);
					animate.angleFrom = Number(SVGParserCommon.splitNumericArgs(svgFrom)[0]);
					animate.angleTo = Number(SVGParserCommon.splitNumericArgs(svgTo)[0]);
					animate.originX = Number(SVGParserCommon.splitNumericArgs(svgFrom)[1]); // TODO: FIX svgTo originX
					animate.originY = Number(SVGParserCommon.splitNumericArgs(svgFrom)[2]); // TODO: FIX svgTo originY
					animate.duration = dur;
					animate.repeatCount = (svgRepeatCount == "indefinite"? 0 : Number(svgRepeatCount));
					animate.end();
					animate.play();

					break;
			}
			
		}
		
		override public function clone():Object {
			var c:SVGAnimateTransform = super.clone() as SVGAnimateTransform;
			
			//			var pathCopy:Vector.<SVGPathCommand> = new Vector.<SVGPathCommand>();
			//			for each(var command:SVGPathCommand in path){
			//				pathCopy.push(command.clone());
			//			}
			//			c.path = pathCopy;
			
			return c;
		}
	}
}

