------------------------------------------------------------------------------------------------
-- The Game module.
--
-- @module  game
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Apr-2018
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES                                             --                
-- ------------------------------------------------------------------------------------------ --
 
local composer  = require 'composer' 
local snakes    = require 'scene.game.lib.snakes' 

-- ------------------------------------------------------------------------------------------ --
--                                 MODULE DECLARATION                                       --                 
-- ------------------------------------------------------------------------------------------ --

local scene = composer.newScene()

-- ------------------------------------------------------------------------------------------ --
--                                 LOCALISED VARIABLES                                        --   
-- ------------------------------------------------------------------------------------------ --

local mFloor  = math.floor
local mRandom = math.random
local fps     = display.fps

local _T = display.screenOriginY
local _B = display.viewableContentHeight - display.screenOriginY
local _L = display.screenOriginX
local _R = display.viewableContentWidth - display.screenOriginX

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --   
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --   
-- ------------------------------------------------------------------------------------------ --

local snake, food
local frames = 0
local frameRate = 5

local function isValid( frames )

   return ( frames % ( mFloor ( fps / frameRate ) ) ) == 0 

end

local function pickLocation()

   local row = mRandom( 1, ( _R - _L ) % snake.scl )
   local col = mRandom( 1, ( _B - _T ) % snake.scl )

   food = display.newRect( scene.view, _L + ( row - 0.5 ) * snake.scl,  _T + ( col - 0.5 ) * snake.scl, snake.scl - 2, snake.scl - 2 )
   food:setFillColor( mRandom(), mRandom(), mRandom() )

end  

function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Create new snake 
   snake = snakes.new()
   -- Create new food
   pickLocation()

end

-- In every frame we update position of snake 
local function enterFrame( event )

   frames = frames + 1
   if frames > fps then frames = 1 end

   if isValid( frames ) then 
      
      snake:update()
      snake:death()

      if snake:eat( food ) then

         food:removeSelf()
         pickLocation()

      end   

   end   

end 
 
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == 'will' then

      -- Add listener
      Runtime:addEventListener( 'enterFrame', enterFrame )

   elseif phase == 'did' then

   end

end
 
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == 'will' then

   elseif phase == 'did' then

      -- Remove listener
      Runtime:removeEventListener( 'enterFrame', enterFrame )

   end
   
end

function scene:destroy( event )
 
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene