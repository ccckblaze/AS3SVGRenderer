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
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	public class SVGAnimateMotion extends SVGAnimate {	
		private var _invalidPathFlag:Boolean = false;
		private var _path:Vector.<SVGPathCommand>;
		
		public function SVGAnimateMotion(){
			super("animatemotion");
		}
		
		public function get svgPath():String {
			return getAttribute("path") as String;
		}
		public function set svgPath(value:String):void {
			setAttribute("path", value);
		}
		
		public function get path():Vector.<SVGPathCommand> {
			return _path;
		}
		public function set path(value:Vector.<SVGPathCommand>):void {
			_path = value;
		}
		
		override protected function onAttributeChanged(attributeName:String, oldValue:Object, newValue:Object):void {
			super.onAttributeChanged(attributeName, oldValue, newValue);
			
			switch(attributeName){
				case "path" :
					_invalidPathFlag = true;
					path = SVGParserCommon.parsePathData(svgPath); 
					invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_invalidPathFlag)
			{
				_invalidPathFlag = false;
				path = SVGParserCommon.parsePathData(svgPath); 
			}
		}
		
		override protected function render():void {
			super.render();
			
			var pos_x:Number = 0;
			var pos_y:Number = 0;
			
			// Add the motion path to a Vector
			var paths:Vector.<MotionPath> = new Vector.<MotionPath>();
			for each(var pathCommand:SVGPathCommand in _path){
				switch(pathCommand.type){
					case "M" :
					case "m" :
						//moveTo(pathCommand as SVGMoveToCommand);
						var moveCmd:SVGMoveToCommand = pathCommand as SVGMoveToCommand;
						if(moveCmd){
							pos_x = moveCmd.x;
							pos_y = moveCmd.y;
						}
						break;
					case "L" :
					case "l" :
						//lineTo(pathCommand as SVGLineToCommand);
						var lineCmd:SVGLineToCommand = pathCommand as SVGLineToCommand;
						if(lineCmd){
							// Create the motion path
							var smp_x:SimpleMotionPath = new SimpleMotionPath();
							smp_x.property = "x";
							smp_x.valueFrom = pos_x;
							smp_x.valueTo = lineCmd.x;
							
							var smp_y:SimpleMotionPath = new SimpleMotionPath();
							smp_y.property = "y";
							smp_y.valueFrom = pos_y;
							smp_y.valueTo = lineCmd.y;
							
							paths.push( smp_x, smp_y );
						}
						break;
					case "H" :
					case "h" :
						//lineToHorizontal(pathCommand as SVGLineToHorizontalCommand);
						break;
					case "V" :
					case "v" :
						//lineToVertical(pathCommand as SVGLineToVerticalCommand);
						break;
					case "Q" :
					case "q" :
						//curveToQuadratic(pathCommand as SVGCurveToQuadraticCommand);
						break;
					case "T" :
					case "t" :
						//curveToQuadraticSmooth(pathCommand as SVGCurveToQuadraticSmoothCommand);
						break;					
					case "C" :
					case "c" :
						//curveToCubic(pathCommand as SVGCurveToCubicCommand);
						break;
					case "S" :
					case "s" :
						//curveToCubicSmooth(pathCommand as SVGCurveToCubicSmoothCommand);
						break;
					case "A" :
					case "a" :
						//arcTo(pathCommand as SVGArcToCommand);
						break;
					
					case "Z" :
					case "z" :
						//closePath();
						break;
				}
			}
			
			// Create the animation
			var animate:Animate = new Animate(this.parentElement);
			animate.easer = null;
			animate.target = this.parentElement;
			//animate.disableLayout = true;
						
			animate.duration = dur;
			animate.repeatCount = (svgRepeatCount == "indefinite"? 0 : Number(svgRepeatCount));
			animate.motionPaths = paths;
			animate.end();
			animate.play();
		}
		
		override public function clone():Object {
			var c:SVGAnimateMotion = super.clone() as SVGAnimateMotion;
			
			var pathCopy:Vector.<SVGPathCommand> = new Vector.<SVGPathCommand>();
			for each(var command:SVGPathCommand in path){
				pathCopy.push(command.clone());
			}
			c.path = pathCopy;
			
			return c;
		}
	}
}

