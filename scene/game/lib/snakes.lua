------------------------------------------------------------------------------------------------
-- The Snake module.
--
-- @module  snake
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Apr-2018
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 MODULE DECLARATION	                                      --						
-- ------------------------------------------------------------------------------------------ --

local M = {}

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES	                                          --						
-- ------------------------------------------------------------------------------------------ --

local composer = require 'composer' 

-- ------------------------------------------------------------------------------------------ --
--                                 LOCALISED VARIABLES                                        --	
-- ------------------------------------------------------------------------------------------ --

local mSin   = math.sin
local mCos   = math.cos
local mRad   = math.rad
local mSqrt  = math.sqrt
local mFloor = math.floor

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --	
-- ------------------------------------------------------------------------------------------ --

-- Code from https://gist.github.com/Lerg/8791431
local function clamp( value, low, high )

    if low and value <= low then

        return low

    elseif high and value >= high then

        return high

    end

    return value

end

local function distance( x1, y1, x2, y2 )

	return mSqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) )

end

-- ------------------------------------------------------------------------------------------ --
--                                 LOCAL VARIABLES                                        --	
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --	
-- ------------------------------------------------------------------------------------------ --

------------------------------------------------------------------------------------------------
-- Constructor function of Snake module.
--
--- @param options The table with all options for the ship.
--
-- - `x`:		 		the center x position of the ship
-- - `y`: 		 		the center y position of the ship
-- - `xSpeed`:   		
-- - `rotationByFrame`: the rotation angle by frame
-- - `radius`: 			the radius of the smallest circle containing the ship (triangle)
--
-- @return The snake group.
------------------------------------------------------------------------------------------------
function M.new( options )

	-- Get the current scene group
	local parent = display.currentStage
	local _T 	 = display.screenOriginY
	local _B 	 = display.viewableContentHeight - display.screenOriginY
	local _L 	 = display.screenOriginX
	local _R 	 = display.viewableContentWidth - display.screenOriginX

	-- Default options for group
	options               = options         or {}
	local x               = options.x       or 0
	local y               = options.y       or 0
	local xSpeed          = options.xSpeed  or 1
	local ySpeed          = options.ySpeed  or 0
	local scl             = options.scl     or 30

	local group  = display.newGroup()
	local head   = display.newRect( group, x + 0.5 * scl, y + 0.5 * scl, scl - 2, scl - 2 )
	group.tail   = { head }
	group.xSpeed = xSpeed
	group.ySpeed = ySpeed
	group.scl    = scl

	function group:update()

		local tail = self.tail
		local head = tail[#tail]

		if not self.isGrow then

			for i=1, #tail-1 do

				tail[i].x = tail[i + 1].x
				tail[i].y = tail[i + 1].y

			end	

		else
		
			self.isGrow = false

			local newHead = display.newRect( self, head.x, head.y, scl - 2, scl -2 )
			head = newHead
			tail[#tail + 1]	= newHead

		end
		
		head:translate( self.xSpeed * self.scl, self.ySpeed * self.scl )	
		head.x = clamp( head.x, _L + self.scl * 0.5, _L + ( mFloor( ( _R - _L ) / self.scl ) - 0.5 ) * self.scl )
		head.y = clamp( head.y, _T + self.scl * 0.5, _T + ( mFloor( ( _R - _L ) / self.scl ) - 0.5 ) * self.scl )

	end	

	function group:eat( food )

		local head = self.tail[1]

		if distance( head.x, head.y , food.x, food.y ) < 1 then

			self.isGrow = true

			return true

		else return false end	

	end	

	function group:death()

		local tail = self.tail
		local head = tail[#tail]

		for i=1, #tail -1 do

			if distance( tail[i].x, tail[i].y, head.x, head.y ) < 1 then

				for j=#tail - 1, 1, -1 do

					local child = table.remove( tail, j )
					child:removeSelf()

				end	

				break

			end	

		end	

	end	

	function group:dir( x, y )

		self.xSpeed = x
		self.ySpeed = y

	end	

	-- Keyboard control
	local lastEvent = {}
	local function key( event )

		local phase = event.phase
		local name = event.keyName

		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys

		if phase == 'down' then

			if 'right' == name then

				group:dir( 1, 0 )

			elseif 'left' == name then

				group:dir( -1, 0 )

			elseif 'up' == name then

				group:dir( 0, -1 )

			elseif 'down' == name then

				group:dir( 0, 1 )

			end

		elseif phase == 'up' then end

		lastEvent = event

	end

	function group:finalize()

		-- On remove, cleanup group, or call directly for non-visual
		Runtime:removeEventListener( 'key', key )

	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	group:addEventListener( 'finalize' )

	-- Add our key/joystick listeners
	Runtime:addEventListener( 'key', key )	

	parent:insert( group )

	return group
	
end	

return M