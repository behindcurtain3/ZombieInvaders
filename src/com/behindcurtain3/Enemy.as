package com.behindcurtain3 
{
	import flash.display.BitmapData;
	import flash.events.IMEEvent;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.utils.Ease;
	
	/**
	 * ...
	 * @author Justin Brown
	 */
	public class Enemy extends Entity 
	{
		[Embed(source = '../../../assets/zombie.png')]
		private const ZOMBIE:Class;
		
		[Embed(source = '../../../assets/zombie_death.mp3')]
		private const SFX_DEATH:Class;
		
		private const PARTICLE_COUNT:Number = 50;
		private var sfxDeath:Sfx = new Sfx(SFX_DEATH);
		
		protected var health:Number;
		protected var speed:Number;
		protected var spriteMap:Spritemap;
		protected var particleEmitter:Emitter;
				
		public function Enemy(_x:Number, _y:Number, _h:Number = 100, _s:Number = 25) 
		{
			// Set position
			x = _x;
			y = _y;
			
			// Setup gfx
			spriteMap = new Spritemap(ZOMBIE, 46, 49);
			spriteMap.add("walk", [7,13], 4, true);
			spriteMap.play("walk");
			
			// 50% change to be flipped
			if (Math.random() > 0.5)
			{
				spriteMap.flipped = true;
			}
			
			layer = 10;
			
			// Setup for collisions
			type = "zombie";
			setHitbox(34, 28, -6, 0);
			
			// Setup emitters
			particleEmitter = new Emitter(new BitmapData(1, 1, false, 0xFF0000), 1, 1);
			particleEmitter.newType("death", [0]);
			particleEmitter.relative = false;
			particleEmitter.setMotion("death", 0, 35, 2, 360, -32, -1.5, Ease.quartOut);
			particleEmitter.setAlpha("death", 1, 0.5);
			
			graphic = new Graphiclist(spriteMap, particleEmitter);
			
			// Setup stats
			health = _h;
			speed = _s;
		}
		
		override public function update():void
		{
			y += speed * FP.elapsed;
			
			if (y >= FP.height)
			{
				var p:Player = this.world.classFirst(Player) as Player;
				if (p != null)
				{
					p.hit();
				}
				this.world.remove(this);
			}
			
			var b:Bullet = collide("bullet", x, y) as Bullet;	
			if (b)
			{
				// Subtract health
				health -= b.Damage();
				
				if (health <= 0)
				{
					// Enemy is dead
					collidable = false;
					spriteMap.visible = false;
				
					for (var i:uint = 0; i < PARTICLE_COUNT; i++)
					{
						particleEmitter.emit("death", x + 30, y + 30);
					}
				}
				else
				{
					// Play hit sound
					sfxDeath.play();
				}
				
				// Destroy the bullet
				b.destroy();
			}
			
			if (!collidable && particleEmitter.particleCount == 0)
			{
				if(this.world != null)
					this.world.remove(this);
			}
				
			super.update();
		}
		
	}

}