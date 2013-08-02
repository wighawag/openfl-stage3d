/****
* 
****/

package flash.display3D;
#if (flash || display)
@:final extern class IndexBuffer3D {
	function dispose() : Void;
	function uploadFromByteArray(data : flash.utils.ByteArray, byteArrayOffset : Int, startOffset : Int, count : Int) : Void;
	function uploadFromVector(data : flash.Vector<UInt>, startOffset : Int, count : Int) : Void;
}
#else
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Int16Array;
import flash.utils.ByteArray;
import flash.Vector;

class IndexBuffer3D 
{
   public var glBuffer:GLBuffer;
   public var numIndices:Int;

   public function new(glBuffer:GLBuffer, numIndices:Int) 
   {
      this.glBuffer = glBuffer;
      this.numIndices = numIndices;
   }

   public function uploadFromByteArray(byteArray:ByteArray, byteArrayOffset:Int, startOffset:Int, count:Int):Void 
   {
       var bytesPerIndex = 2;
      GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, glBuffer);
      var indices = new Int16Array(byteArray,byteArrayOffset + startOffset* bytesPerIndex, count* bytesPerIndex);
      GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, GL.STATIC_DRAW);
   }

   public function uploadFromVector(data:Vector<Int>, startOffset:Int, count:Int):Void 
   {
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, glBuffer);
        GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(data, startOffset, count), GL.STATIC_DRAW);
   }

    public function dispose():Void 
    {
        GL.deleteBuffer(glBuffer);
    }
}

#end