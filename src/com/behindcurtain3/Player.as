package com.behindcurtain3 
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Ease;
	
	/**
	 * ...
	 * @author Justin Brown
	 */
	public class Player extends Entity
	{		
		[Embed(source = '../../../assets/character.png')]
		private const GFX_PLAYER:Class;
		
		[Embed(source = '../../../assets/Fire.mp3')]
		private const SFX_FIRE:Class;
		
		private const PARTICLE_COUNT:Number = 150;
		
		private var speed:Number;
		private var health:Number;
		private var shoot:Sfx = new Sfx(SFX_FIRE);
		private var gfx:Image;
		private var spriteMap:Spritemap;
		private var particleEmitter:Emitter;
		private var gunDamage:Number; 
		
		public function Player()
		{			
			// Set position
			y = FP.screen.height - height - 75;
			x = FP.screen.width / 2 - 21;
			
			// Setup collisions
			type = "player";
			setHitbox(39, 39);
			
			// Setup emitters
			particleEmitter = new Emitter(new BitmapData(2, 2, false, 0xFF0000), 2, 2);
			particleEmitter.newType("death", [0]);
			particleEmitter.relative = false;
			particleEmitter.setMotion("death", 330, 50, 2, 250, -20, -1.5, Ease.quartOut);
			particleEmitter.setAlpha("death", 1, 0.5);
			
			// Setup gfx
			spriteMap = new Spritemap(GFX_PLAYER, 39, 39);
			spriteMap.add("stand", [13], 0, true);
			spriteMap.add("shoot", [14,13], 4, false);
			spriteMap.play("stand");
			graphic = new Graphiclist(spriteMap, particleEmitter);
			layer = 1;
			
			// Setup stats
			health = 5;
			speed = 350;
			gunDamage = 80;
			
			// Input
			Input.define("shoot", Key.SPACE);
			Input.define("left", Key.A, Key.LEFT);
			Input.define("right", Key.D, Key.RIGHT);
		}
		
		override public function update():void
		{
			if (Input.check("left"))
				x -= speed * FP.elapsed;
			if (Input.check("right"))
				x += speed * FP.elapsed;
				
			if (x < 0)
				x = 0;
			if (x > FP.screen.width - width)
				x = FP.screen.width - width;
				
			if (Input.pressed("shoot") && collidable) 
			{
				if (this.world != null)
				{
					this.world.add(new Bullet(x + width / 2, y, gunDamage));
				}
				spriteMap.play("shoot", true);
				shoot.play();
			}
			
			if (health <= 0 && collidable)
			{
				// Player has died
				collidable = false;
				spriteMap.visible = false;
				
				for (var i:uint = 0; i < PARTICLE_COUNT; i++)
				{
					particleEmitter.emit("death", x + width/2, y + height/2);
				}
			}
			
			if (!collidable && particleEmitter.particleCount == 0)
			{
				if(this.world != null)
					this.world.remove(this);
			}
				
			super.update();
		}
		
		public function hit():void
		{
			health--;
			
			if (this.world != null)
			{
				var hearts:Array = new Array();
				this.world.getClass(Heart, hearts);
				if (hearts.length > 0)
				{
					this.world.remove(hearts[0]);
				}
			}
		}
		
		public function getHealth():Number
		{
			return health;
		}
		
		public function upgradeGun():void
		{
			// Increase by 25% per upgrade
			gunDamage += (gunDamage * 0.25);
		}
	}

}