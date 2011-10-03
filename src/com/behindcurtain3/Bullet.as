package com.behindcurtain3 
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	
	/**
	 * ...
	 * @author Justin Brown
	 */
	public class Bullet extends Entity 
	{
		
		private var speed:Number;
		private var dmg:Number;
		
		public function Bullet(_x:Number, _y:Number, damage:Number = 50) 
		{
			x = _x;
			y = _y;
			graphic = new Image(new BitmapData(1, 1));
			setHitbox(1,1);
			type = "bullet"
			
			speed = 500;
			dmg = damage;
		}
		
		override public function update():void
		{
			y -= speed * FP.elapsed;
			
			if (y < 0)
			{
				if(this.world != null)
					this.world.remove(this);
			}
			
			super.update();
		}
		
		public function destroy():void
		{
			if(this.world != null)
				this.world.remove(this);
		}
		
		public function Damage():Number
		{
			return dmg;
		}
	}

}