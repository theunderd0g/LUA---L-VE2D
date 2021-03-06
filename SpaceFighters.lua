player ={x=255 ,y=500, speed = 400 ,img =nil,health=100,power=nil}
enemy  ={x=255 ,y=50, speed = 400 ,img =nil,health=100,power=nil}
--bullets
playerBullets ={}
enemyBullets  ={}
bulletimg     =nil
playerCanShoot = true
enemyCanShoot = true
ShootTimerMax = 0.3
playerTimer = ShootTimerMax
enemyTimer = ShootTimerMax
bspeed=500
--power ups
activePower = {xpos = nil,ypos = nil,active=false,name = nil,img=nil}
powerups = {'hp'}
powerNo = 1
powerTimer = 3
hpimg=nil
maxPowerTimer = 10
--accidents
accidenttimermax = 3.0
time=0
accidenttimer = accidenttimermax

screenwidth=nil
paused =false
screenheight=nil
-- pauseimage= bulletimg
largeFont = nil

function love.load()

	hpimg        =love.graphics.newImage('assets/2.png')
	enemy.img    =love.graphics.newImage('assets/l0_Plane3.png')
	player.img   =love.graphics.newImage('assets/l0_Plane2.png')
	bulletimg    =love.graphics.newImage('assets/images/rocket_flame/rocket_1_0012.png')
	screenwidth  =love.graphics.getWidth()
	screenheight =love.graphics.getHeight()
	largeFont    =love.graphics.newFont(50)
	math.randomseed(os.time())
end
function love.draw()
	-- love.graphics.clear(40,45,52,225)
	love.graphics.print('Hold Enter to show controls.',10,5)
	if paused then
		love.graphics.printf("Controls\n WASD --> Move Enemy\n arrows --> move player\nSpace --> enemy Shoot\nCtrl --> player shoot\n ESC -->Quit",125,screenheight/2,500,"center")
	end
	love.graphics.print('Enemy '..enemy.health,10,25)
	love.graphics.print('Player '..player.health,10,45)
	love.graphics.draw(player.img,player.x,player.y)
	love.graphics.draw(enemy.img,enemy.x,enemy.y)
	for i,bullet in ipairs(playerBullets) do
		love.graphics.draw(bulletimg, bullet.x, bullet.y)
	end
	for i,bullet in ipairs(enemyBullets) do
		love.graphics.draw(bulletimg,bullet.x,bullet.y)
	end
	if activePower.active then 
		love.graphics.draw(activePower.img,activePower.xpos,activePower.ypos)
	end
end
function love.update(dt)
	checkloss()
	markCollision(dt)
	shootingtempo(dt)
	moveBullets(dt)
	powerup(dt)
	if activePower.active then
		movePoewr(dt)
	end
	-- createEneimes(dt)
	-- moveEneimes(dt)
	-- fireMaking(dt)
	if love.keyboard.isDown('return') then
		paused = true
	else
		paused=false 
	end
	if not paused then
		if love.keyboard.isDown('escape') then
			love.event.push('quit')
			
		end
		if love.keyboard.isDown('left')  and valid(player,'l') then
				player.x = player.x - dt*player.speed
		
		elseif love.keyboard.isDown('right') and valid(player,'r')  then		
				player.x = player.x + dt*player.speed
		
		elseif love.keyboard.isDown('down') and valid(player,'d') then
				player.y=player.y+dt*player.speed
		elseif love.keyboard.isDown('up') and valid(player,'u') then
				player.y=player.y-dt*player.speed
		end
		if love.keyboard.isDown('rctrl') then
			if playerCanShoot then
			bullet = {y=player.y,x=player.x+player.img:getWidth()/2-7,img=bulletimg,speed=bspeed}
			table.insert(playerBullets,bullet)
			playerCanShoot=false
			playerTimer=ShootTimerMax		
			end
		end
		if love.keyboard.isDown('a')  and valid(enemy,'l') then
				enemy.x = enemy.x - dt*enemy.speed
		
		elseif love.keyboard.isDown('d') and valid(enemy,'r')  then		
				enemy.x = enemy.x + dt*enemy.speed
		
		elseif love.keyboard.isDown('s') and valid(enemy,'d') then
				enemy.y=enemy.y+dt*enemy.speed
		elseif love.keyboard.isDown('w') and valid(enemy,'u') then
				enemy.y=enemy.y-dt*enemy.speed
		end
		if love.keyboard.isDown('space') then
			if enemyCanShoot then
			bullet = {y=enemy.y+10,x=enemy.x+enemy.img:getWidth()/2-4,img=bulletimg,speed=bspeed}
			table.insert(enemyBullets,bullet)
			enemyCanShoot =	 false
			enemyTimer    =  ShootTimerMax		
			end
		end
	end
end
function shootingtempo(dt)
	
	playerTimer   = playerTimer-(1*dt)
	enemyTimer    = enemyTimer -(1*dt)
	accidenttimer = accidenttimer - (1*dt)
	if(playerTimer<=0) then
		playerCanShoot = true
	end
	if enemyTimer <=0 then
		enemyCanShoot = true
	end
end

function moveBullets(dt)
	for i,bullet in ipairs(playerBullets) do
		bullet.y=bullet.y-bullet.speed*dt
		if(bullet.y<10) then
			table.remove(playerBullets,i)
		end
	end
	for i,bullet in ipairs(enemyBullets) do
		bullet.y = bullet.y + bullet.speed*dt
		if(bullet.y > screenheight) then
			table.remove(enemyBullets,i)
		end
	end
end

function valid(obj,dir)
	px=obj.x
	py=obj.y
	pimgh=obj.img:getHeight()
	pimgw=obj.img:getWidth()
	
	if(dir=='r') then
		return (px+pimgw<screenwidth)
	elseif(dir=='l') then
		return (px>0)
	elseif(dir=='d') then
		return py+pimgh<screenheight
	else
		return py>0
	end	
end


-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function fireMaking(dt)
	for i,col in ipairs(fire) do
		if col.tim>time-3*dt then
			col.img=fadeFire
		elseif col.tim >time - 5*dt then
			table.remove(fire,i)
		end
	end
end
function markCollision(dt)
	px=player.x
	py=player.y
	ph=player.img:getHeight()
	pw=player.img:getWidth()
	ex=enemy.x
	ey=enemy.y
	marg=10
	eh=enemy.img:getHeight()
	ew=enemy.img:getWidth() 
	bh=bulletimg:getHeight()
	bw=bulletimg:getWidth()
	for i,bullet in ipairs(enemyBullets) do
		if CheckCollision(bullet.x,bullet.y,bw,bh,px,py,pw,ph) then
			player.health = player.health - 10
			table.remove(enemyBullets,i)			
		end
	end
	for i,bullet in ipairs(playerBullets) do
		if CheckCollision(bullet.x,bullet.y,bw,bh,ex,ey,ew,eh) then
			enemy.health = enemy.health - 10
			table.remove(playerBullets,i)			
		end
	end
	if CheckCollision(px,py,pw,ph,ex,ey,ew,eh) and accidenttimer<0 then
		player.health = player.health - 30
		enemy.health  = enemy.health  - 30
		accidenttimer = accidenttimermax
	end
	if activePower.active then
		h = activePower.img:getHeight()
		w = activePower.img:getWidth()
		if CheckCollision(px,py,pw,ph,activePower.xpos,activePower.ypos,w,h) then
			player.health      = math.min(player.health+50,100)
			activePower.active = false
		elseif CheckCollision(ex,ey,ew,eh,activePower.xpos,activePower.ypos,w,h) then
			enemy.health       = math.min(enemy.health+50,100)
			activePower.active = false
		end
	end	
end
function checkloss()
	if(player.health<=0) then
		love.window.showMessageBox('End game','Enemy win','info' , true)
		love.event.quit('restart')
		-- love.event.quit()
	end
	if enemy.health<=0 then
		love.window.showMessageBox('End game','player win','info' , true)
		love.event.quit( 'restart' )
		-- love.event.quit()
	end	
end 
function powerup(dt)
	powerTimer =  powerTimer - 1*dt
	if(powerTimer <0  ) then
		activePower.ypos   = math.random(0,500)
		activePower.name   = math.random(0,powerNo)
		activePower.active = true
		activePower.img    = hpimg
		powerTimer         = maxPowerTimer
		activePower.xpos   = -5


	end
end
function movePoewr(dt)
	activePower.xpos  = activePower.xpos + bspeed*dt
	if(activePower.xpos> screenwidth) then 
		activePower.active  = false
	end
end
function showHelp()
	love.graphics.print("Paused",255,50)
end
