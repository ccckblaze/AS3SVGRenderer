/**
* WeakReference by Grant Skinner. June 3, 2006
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
*
* Please contact info@gskinner.com prior to distributing modified versions of this class.
*/

package com.gskinner.utils {
	import flash.utils.Dictionary;
	
	public class WeakReference {
		private var dictionary:Dictionary;
		
		public function WeakReference(p_object:Object) {
			dictionary = new Dictionary(true);
			dictionary[p_object] = null;
		}
		
		public function get():Object {
			for (var n:Object in dictionary) { return n; }
			return null;
		}
	}
}