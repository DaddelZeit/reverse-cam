--[[
MIT License

Copyright (c) 2025 DaddelZeit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local M = {}

local geExt = "zeit_carReverseCam"
local node = 0
local target
local geLuaStr = ""
local electricsName = "reverseCam"

local directionVector = vec3()
local posOffset = vec3()
local pos = vec3()
local rot = quat()

local res = {512, 256}
local fov = 70
local clip = {0.1, 100}

local function onPlayersChanged()
    obj:queueGameEngineLua([[
        extensions.]]..geExt..[[.setFocusCar(]]..objectId..[[)
    ]])
end

local function updateGFX(dt)
    electrics.values[electricsName] = 0
    if electrics.values.reverse == 1 and playerInfo.anyPlayerSeated and target then
        pos:set(obj:getPositionXYZ())
        rot:set(obj:getRotation())
        pos = pos + obj:getNodePosition(node) + posOffset:rotated(rot) + obj:getVelocity()*dt

        obj:queueGameEngineLua(string.format(geLuaStr,
            pos,
            quatFromDir(directionVector:rotated(rot), obj:getDirectionVectorUp()),
            res[1],
            res[2],
            fov,
            clip[1],
            clip[2]
        ))

        electrics.values[electricsName] = 1
    end
end

local function init(jbeamData)
    geExt = jbeamData.geExt or geExt
    electricsName = jbeamData.electricsName or electricsName
    node = beamstate.nodeNameMap[jbeamData.camNode or 0]
    target = jbeamData.texTargetName

    if jbeamData.posOffset then
        posOffset:set(jbeamData.posOffset.x, jbeamData.posOffset.y, jbeamData.posOffset.z)
    end

    directionVector = vec3(0,1,0)
    if jbeamData.rotOffset then
        directionVector = (directionVector + vec3(jbeamData.rotOffset)):normalized()
    end

    res = jbeamData.res or res
    fov = jbeamData.fov or fov
    clip = jbeamData.clip or clip

    if not target then
        return
    end

    obj:queueGameEngineLua([[
        extensions.load(]]..geExt..[[)
    ]])

    geLuaStr = geExt..".renderCam('"..target.."', %s, %s, %d, %d, %d, %s, %s)"
    if electricsName then electrics.values[electricsName] = 0 end
    onPlayersChanged()
end

M.updateGFX = updateGFX
M.onPlayersChanged = onPlayersChanged
M.init = init

return M