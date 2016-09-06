package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;

	public class TextFieldSVGTextDrawer implements ISVGTextDrawer
	{
		public function start():void
		{
		}
		
		public function drawText(data:SVGTextToDraw, textSprite:DisplayObject = null):SVGDrawnText
		{
			var textField:TextField = null;
			if(textSprite is TextField){
				textField = textSprite as TextField;
			}
			else{
				textField = new TextField;
			}
			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = data.text;
			textField.embedFonts = data.useEmbeddedFonts;

			var textFormat:TextFormat = new TextFormat();
			textFormat.font = data.fontFamily;
			textFormat.size = data.fontSize;
			textFormat.bold = data.fontWeight == "bold";
			textFormat.italic = data.fontStyle == "italic";
			textFormat.color = data.color;
			textFormat.letterSpacing = data.letterSpacing;
			textField.setTextFormat(textFormat);
			textField.mouseEnabled = false;
			
			var lineMetrics:TextLineMetrics = textField.getLineMetrics(0);
			
			var startY:Number = lineMetrics.ascent + 2;
			switch(data.dominantBaseline){
				case "central":
					startY -= (lineMetrics.height - lineMetrics.descent) / 2;
					break;
				// TODO: FIXME
			}
			
			return new SVGDrawnText(textField, textField.textWidth, 2, startY);
		}
		
		public function end():void
		{	
		}		
	}
}