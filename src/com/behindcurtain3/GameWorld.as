package com.behindcurtain3 
{
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Input;
	import net.flashpunk.World;
	
	/**
	 * ...
	 * @author Justin Brown
	 */
	public class GameWorld extends World 
	{
		[Embed(source = '../../../assets/ZOMBIE.ttf', embedAsCFF="false", fontFamily = 'ZombieFont')]
		private const FONT_ZOMBIE:Class
		
		// Wave variables
		protected var timeElapsed:Number;
		protected var waveTimer:Number = 30;		// Length of wave (minus wave spacer)
		protected var waveSpacer:Number = 10;		// Seconds between waves
		protected var enemiesToSpawn:Number = 10;	// Number of enemies to spawn in a wave
		protected var waveHealth:Number = 50;		// Total health of each enemy in a wave
		protected var waveSpeed:Number = 25;		// Speed of each enemy in a wave
		protected var spawnQueue:Array;
		protected var waveNum:Number = 0;			// Start on 0
		
		// Game state variables
		public var gameOver:Boolean = false;
		
		// Player
		protected var p:Player;
		
		// HUD elements
		protected var waveValue:Text;
		protected var waveLabel:Text;
		protected var clockValue:Text;
		protected var flash:Text;
		
		public function GameWorld() 
		{
			// Setup player
			p = new Player();
			add(p);
			
			// Spawn random grass
			for (var i:uint = 0; i < 5; i++)
			{
				add(new Grass(FP.rand(FP.screen.width), FP.rand(FP.screen.height)));
			}
			
			// Setup HUD
			waveLabel = new Text("Wave: ", 0, 0, 150);
			waveLabel.font = "ZombieFont";
			waveValue = new Text("1", waveLabel.x + waveLabel.width, 0);
			waveValue.font = "ZombieFont";
			clockValue = new Text(Math.ceil(timeElapsed).toString(), 0, 0);
			clockValue.font = "ZombieFont";
			clockValue.x = FP.screen.width - clockValue.width;
			
			flash = new Text("Wave Incoming");
			flash.font = "ZombieFont";
			flash.size = 16;
			
			addGraphic(waveLabel);
			addGraphic(waveValue);
			addGraphic(clockValue);
			addGraphic(flash);
			
			// Setup hearts
			for (var j:uint = 0; j < p.getHealth(); j++)
			{
				var h:Heart = new Heart(j * 16, FP.screen.height - 28);
				add(h);
			}
			
			setupNextWave();
			gameOver = false;
		}
		
		override public function update():void
		{
			// If game over, stop the clock
			if (!gameOver)
			{
				timeElapsed -= FP.elapsed;
				clockValue.text = Math.ceil(timeElapsed).toString();
				if (timeElapsed <= 10)
					clockValue.alpha = 1;
			}
			
			// Check spawnQueue
			if (spawnQueue.length > 0)
			{
				var q:Number = spawnQueue.pop();
				if (q >= timeElapsed)
				{
					this.add(new Enemy(FP.rand(FP.screen.width - 57), -57, waveHealth, waveSpeed));
				}
				else
				{
					// Push it back onto the queue
					spawnQueue.push(q);
				}
			}
			
			// Check wave timer
			if (timeElapsed < 0)
			{
				setupNextWave();
			}
			
			// Check player health for game over
			if (p.getHealth() <= 0)
			{
				gameOver = true;
				
				// Setup flash text
				flash.text = "Game Over"; 
				flash.alpha = 1;
				flash.x = FP.screen.width / 2 - flash.width / 2;
				flash.y = FP.screen.height / 2 - flash.height / 2;
				
			}
			
			super.update();
		}
		
		public function setupNextWave():void
		{
			// Increment wave counter
			waveNum++;
			waveValue.text = waveNum.toString();
			
			// Setup flash text
			flash.text = "Wave " + waveNum;
			flash.alpha = 1;
			flash.x = FP.screen.width / 2 - flash.width / 2;
			flash.y = FP.screen.height / 2 - flash.height / 2;
			clockValue.alpha =  0;
			
			// Tween for text
			var flashTween:VarTween = new VarTween();
			flashTween.tween(flash, "alpha", 0, 3, Ease.expoIn);
			addTween(flashTween, true);
			
			// Config next wave
			enemiesToSpawn += Math.ceil(enemiesToSpawn * 0.1) + 1; 	// Add 10% more each wave, always add at least 1
			waveHealth += (waveHealth * 0.5);			// Add 50% more health
			p.upgradeGun();
			
			// 25% change to increase the zombie speed
			if (Math.random() > .75)
			{
				waveSpeed = 50;
			}
			else
			{
				waveSpeed = 25;
			}
			
			spawnQueue = new Array();			
			for (var i:uint = 0; i < enemiesToSpawn; i++)
			{
				// Sets an enemy to spawn at a random time between 0 and the length of wave
				var t:Number = Math.floor(Math.random()*(1 + waveTimer - waveSpacer)) + waveSpacer;
				spawnQueue.push(t);
			}
			
			// Sort queue
			spawnQueue.sort(Array.NUMERIC);
			
			// Time elapsed = waveTimer so it counts down
			timeElapsed = waveTimer;
		}
	}

}