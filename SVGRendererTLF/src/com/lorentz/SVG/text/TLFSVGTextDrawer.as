package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	import com.lorentz.SVG.utils.TextUtils;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextAlign;
	import flash.display.Sprite;
	
	public class TLFSVGTextDrawer implements ISVGTextDrawer
	{
		public var textFlow:TextFlow;
		
		public function start():void {
			textFlow = new TextFlow();
			textFlow.textAlign = TextAlign.START;
		}
				
		public function drawText(data:SVGTextToDraw, textSprite:DisplayObject = null):SVGDrawnText {			
			// Create a sprite to place the text
			var textSprite1:Sprite = new Sprite();
			
			// Create a paragraph
			var paragraphElement:ParagraphElement = new ParagraphElement();
			textFlow.addChild(paragraphElement);
			
			// Create the textSpan with the text
			var spanElementTarget:SpanElement = new SpanElement();
			spanElementTarget.text = data.text;
			spanElementTarget.fontFamily = data.fontFamily;
			spanElementTarget.fontLookup = data.useEmbeddedFonts ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
			spanElementTarget.fontSize = data.fontSize;
			spanElementTarget.color = data.color;
			spanElementTarget.fontWeight = data.fontWeight == "bold" ? FontWeight.BOLD : FontWeight.NORMAL;
			spanElementTarget.fontStyle = data.fontStyle == "italic" ? FontPosture.ITALIC : FontPosture.NORMAL;
			spanElementTarget.trackingRight = data.letterSpacing;
			paragraphElement.addChild(spanElementTarget);
			
			// Create a controller to place the text inside sprite
			var containerController:ContainerController = new ContainerController(textSprite1, Number.NaN, Number.NaN);
			containerController.verticalScrollPolicy = ScrollPolicy.OFF;
			textFlow.flowComposer.addController(containerController);
			
			// Update controllers
			textFlow.flowComposer.updateAllControllers();
			
			// Get firt textLine height, and update the controller height to show only one line
			var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(textFlow.flowComposer.numControllers - 1);
			var textLine:TextLine = textFlowLine.getTextLine();
			
			var lastAtomIndex:int = textLine.atomCount - 1;
			
			// Don't consider the size of the PARAGRAPH_SEPARATOR Atom,
			// It will always be the last atom because the current text is always the last text of the paragraph
			var char:String;
			while(true){
				char = textFlow.getCharAtPosition(textFlowLine.absoluteStart + lastAtomIndex);
				if(char.charCodeAt() == 8233 || char == "\n"){
					lastAtomIndex--;
				} else
					break;
			}
			
			var lastAtomBounds:Rectangle = textLine.getAtomBounds(lastAtomIndex);
			containerController.setCompositionSize(lastAtomBounds.right, textFlowLine.textHeight);
			
			var baseLineShift:Number = 0;
			switch(data.baselineShift.toLowerCase())
			{
				case "super" :
					baseLineShift = Math.abs(spanElementTarget.getComputedFontMetrics().superscriptOffset || TextUtils.SUPERSCRIPT_OFFSET) * data.parentFontSize;
					break;
				case "sub" :
					baseLineShift = -Math.abs(spanElementTarget.getComputedFontMetrics().subscriptOffset || TextUtils.SUBSCRIPT_OFFSET) * data.parentFontSize;
					break;
			}
			
			return new SVGDrawnText(textSprite1, lastAtomBounds.right, 0, textLine.ascent, baseLineShift);
		}
		
		public function end():void {
			textFlow.interactionManager = new SelectionManager();
			textFlow.flowComposer.updateAllControllers();
			textFlow = null;
		}
	}
}