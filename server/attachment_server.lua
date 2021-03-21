addEvent("onAttachmentRequestCache", true)

local attachments = {}

-- Local functions
local function clearAttachment(element)
    if isAttached(element) then
        attachments[element] = nil
    end
end

-- Global functions
function attach(element, ...)
    if isAttached(element) then
        return false
    end

    attachments[element] = {...}

    local playersOnly = getElementsByType("player")
    triggerClientEvent(playersOnly, "onAttachmentCreate", resourceRoot, element, ...)
end

function updateAttachment(element, ...)
    if not isAttached(element) then
        return false
    end

    local args = {...}
    local attachmentDetails = getAttachmentDetails(element)

    attachments[element][3] = args[1] or attachmentDetails[3]
    attachments[element][4] = args[2] or attachmentDetails[4]
    attachments[element][5] = args[3] or attachmentDetails[5]
    attachments[element][6] = args[4] or attachmentDetails[6]
    attachments[element][7] = args[5] or attachmentDetails[7]
    attachments[element][8] = args[6] or attachmentDetails[8]
    attachments[element][9] = args[7] or attachmentDetails[9]

    local playersOnly = getElementsByType("player")
    triggerClientEvent(playersOnly, "onAttachmentUpdate", resourceRoot, element, ...)
end

function detach(element)
    clearAttachment(element)

    local playersOnly = getElementsByType("player")
    triggerClientEvent(playersOnly, "onAttachmentDestroy", resourceRoot, element)
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
addEventHandler("onPlayerQuit", root, function()
    for element, data in pairs(attachments) do
        if data[2] == source then
            detach(element)
        end
    end
end)

-- Custom Events
addEventHandler("onAttachmentRequestCache", root, function()
    triggerClientEvent(client, "onAttachmentReceiveCache", client, attachments)
end)