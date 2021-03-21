addEvent("onAttachmentReceiveCache", true)
addEvent("onAttachmentCreate", true)
addEvent("onAttachmentUpdate", true)
addEvent("onAttachmentDestroy", true)

local isStreamedIn = isElementStreamedIn
local isOnScreen = isElementOnScreen
local setPosition = setElementPosition
local getBoneMatrix = getElementBoneMatrix
local setMatrix = setElementMatrix
local setInterior = setElementInterior
local getInterior = getElementInterior
local setDimension = setElementDimension
local getDimension = getElementDimension

local attachments = {}

-- Local functions
local function renderAttachments()
    for element, data in pairs(attachments) do
        if isStreamedIn(data.attachedTo) and isOnScreen(data.attachedTo) then
            local boneMat = getBoneMatrix(data.attachedTo, data.boneId)
            local rotMat = data.rotMat

            local bM1X, bM1Y, bM1Z = boneMat[1][1], boneMat[1][2], boneMat[1][3]
            local bM2X, bM2Y, bM2Z = boneMat[2][1], boneMat[2][2], boneMat[2][3]
            local bM3X, bM3Y, bM3Z = boneMat[3][1], boneMat[3][2], boneMat[3][3]
            local bM4X, bM4Y, bM4Z = boneMat[4][1], boneMat[4][2], boneMat[4][3]

            local rM1X, rM1Y, rM1Z = rotMat[1][1], rotMat[1][2], rotMat[1][3]
            local rM2X, rM2Y, rM2Z = rotMat[2][1], rotMat[2][2], rotMat[2][3]
            local rM3X, rM3Y, rM3Z = rotMat[3][1], rotMat[3][2], rotMat[3][3]

            local offsetX, offsetY, offsetZ = data.offsetX, data.offsetY, data.offsetZ

            if boneMat then
                setInterior(element, getInterior(data.attachedTo))
                setDimension(element, getDimension(data.attachedTo))
                setMatrix(element, {
                    {
                        bM2X * rM1Y + bM1X * rM1X + rM1Z * bM3X,
                        bM3Y * rM1Z + bM1Y * rM1X + bM2Y * rM1Y,
                        bM2Z * rM1Y + bM3Z * rM1Z + rM1X * bM1Z,
                        0
                    },
                    {
                        rM2Z * bM3X + bM2X * rM2Y + rM2X * bM1X,
                        bM3Y * rM2Z + bM2Y * rM2Y + bM1Y * rM2X,
                        rM2X * bM1Z + bM3Z * rM2Z + bM2Z * rM2Y,
                        0
                    },
                    {
                        bM2X * rM3Y + rM3Z * bM3X + rM3X * bM1X,
                        bM3Y * rM3Z + bM2Y * rM3Y + rM3X * bM1Y,
                        rM3X * bM1Z + bM3Z * rM3Z + bM2Z * rM3Y,
                        0
                    },
                    {
                        offsetZ * bM1X + offsetY * bM2X - offsetX * bM3X + bM4X,
                        offsetZ * bM1Y + offsetY * bM2Y - offsetX * bM3Y + bM4Y,
                        offsetZ * bM1Z + offsetY * bM2Z - offsetX * bM3Z + bM4Z,
                        1
                    }
                })
            end
        else
            setPosition(element, 0, 0, -1000)
        end
    end
end

local function processDestroyedElements()
    if isAttached(source) then
        detach(source)
    end
end

local function clearAttachment(element)
    if isAttached(element) then
        attachments[element] = nil
    end
end

local function toggleAttachmentEvents(bool)
    if type(bool) ~= "boolean" then
        return false
    end

    local eventName = getVersion()["sortable"] >= "1.5.8-9.20704.0" and "onClientPedsProcessed" or "onClientPreRender" -- Idea based on https://github.com/iDannz-Breno/idz-boneattach/blob/main/scripts/c.main.lua

    _G[bool and "addEventHandler" or "removeEventHandler"]("onClientElementDestroy", root, processDestroyedElements)
    _G[bool and "addEventHandler" or "removeEventHandler"](eventName, root, renderAttachments)
end

-- Global functions
function attach(element, player, boneId, offsetX, offsetY, offsetZ, rotationX, rotationY, rotationZ)
    if isAttached(element) then
        return false
    end

    if getElementType(player) ~= "player" then
        return false
    end

    if type(boneId) ~= "number" or not VALID_BONES[boneId] then
        return false
    end

    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    setElementInterior(element, interior)
    setElementDimension(element, dimension)
    setElementCollisionsEnabled(element, false)

    attachments[element] = {
        attachedTo = player,
        boneId = boneId,
        offsetX = offsetX,
        offsetY = offsetY,
        offsetZ = offsetZ,
        rotationX = rotationX,
        rotationY = rotationY,
        rotationZ = rotationZ,
        rotMat = calculateRotMat(rotationX, rotationY, rotationZ)
    }

    if table.getn(attachments) == 1 then
        toggleAttachmentEvents(true)
    end
end

function updateAttachment(element, boneId, offsetX, offsetY, offsetZ, rotationX, rotationY, rotationZ)
    if not isAttached(element) then
        return false
    end

    if type(boneId) ~= "number" or not VALID_BONES[boneId] then
        return false
    end

    local attachmentDetails = getAttachmentDetails(element)
    local attachedTo = attachmentDetails.attachedTo

    local offsetX = offsetX or attachmentDetails.offsetX
    local offsetY = offsetY or attachmentDetails.offsetY
    local offsetZ = offsetZ or attachmentDetails.offsetZ

    local rotationX = rotationX or attachmentDetails.rotationX
    local rotationY = rotationY or attachmentDetails.rotationY
    local rotationZ = rotationZ or attachmentDetails.rotationZ
    local rotMat = calculateRotMat(rotationX, rotationY, rotationZ)

    attachments[element] = {
        attachedTo = attachedTo,
        boneId = boneId or attachmentDetails.boneId,
        offsetX = offsetX,
        offsetY = offsetY,
        offsetZ = offsetZ,
        rotationX = rotationX,
        rotationY = rotationY,
        rotationZ = rotationZ,
        rotMat = rotMat
    }
end

function detach(element)
    if isAttached(element) then
        clearAttachment(element)

        if table.getn(attachments) == 0 then
            toggleAttachmentEvents(false)
        end
    end
end

function isAttached(element)
    if attachments[element] then
        return true
    end
    return false
end

function getAttachmentDetails(element)
    if isAttached(element) then
        return attachments[element]
    end
end

-- MTA Events
addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("onAttachmentRequestCache", localPlayer)
end)

-- Custom Events
addEventHandler("onAttachmentReceiveCache", localPlayer, function(cache)
    for element, data in pairs(cache) do
        attach(element, data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9])
    end
end)

addEventHandler("onAttachmentCreate", resourceRoot, function(element, ...)
    attach(element, ...)
end)

addEventHandler("onAttachmentUpdate", resourceRoot, function(element, ...)
    updateAttachment(element, ...)
end)

addEventHandler("onAttachmentDestroy", resourceRoot, function(element)
    detach(element)
end)