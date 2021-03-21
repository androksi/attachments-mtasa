local screenX, screenY = guiGetScreenSize()
local wndWidth, wndHeight = 340, 365
local wndX, wndY = screenX - (wndWidth + 10), screenY / 2 - wndHeight / 2

local ui = {windows = {}, buttons = {}, labels = {}, editboxes = {}, scrollbars = {}}
local preview = {
    state = false,
    object = nil
}

-- Local functions
local function toggleCursor(key, keyState)
    if not preview.state then
        return false
    end

    if keyState == "down" then
        showCursor(false)
        guiSetAlpha(ui.windows.general, 0.2)
    else
        showCursor(true)
        guiSetAlpha(ui.windows.general, 0.8)
    end
end

local function previewChanged(scroll)
    if not preview.state then
        return false
    end

    local model = tonumber(guiGetText(ui.editboxes.model)) or 1337
    local boneId = tonumber(guiGetText(ui.editboxes.boneId)) or 0
    local scale = tonumber(guiGetText(ui.editboxes.scale)) or 1

    local offsetX = tonumber(guiGetText(ui.editboxes.offsetX)) or 0
    local offsetY = tonumber(guiGetText(ui.editboxes.offsetY)) or 0
    local offsetZ = tonumber(guiGetText(ui.editboxes.offsetZ)) or 0

    local rotationX = (guiScrollBarGetScrollPosition(ui.scrollbars.rotationX) * 360) / 100
    local rotationY = (guiScrollBarGetScrollPosition(ui.scrollbars.rotationY) * 360) / 100
    local rotationZ = (guiScrollBarGetScrollPosition(ui.scrollbars.rotationZ) * 360) / 100

    if eventName == "onClientGUIChanged" then
        if source == ui.editboxes.model then
            setElementModel(preview.object, model)
        elseif source == ui.editboxes.boneId and VALID_BONES[boneId] then
            updateAttachment(preview.object, boneId)
        elseif source == ui.editboxes.scale then
            setObjectScale(preview.object, scale)
        elseif source == ui.editboxes.offsetX then
            updateAttachment(preview.object, boneId, offsetX, offsetY, offsetZ)
        elseif source == ui.editboxes.offsetY then
            updateAttachment(preview.object, boneId, offsetX, offsetY, offsetZ)
        elseif source == ui.editboxes.offsetZ then
            updateAttachment(preview.object, boneId, offsetX, offsetY, offsetZ)
        end
    elseif eventName == "onClientGUIScroll" then
        updateAttachment(preview.object, boneId, _, _, _, rotationY, rotationX, rotationZ)
    end

    local str = table.concat(
        {
            boneId,
            offsetX, offsetY, offsetZ,
            rotationX, rotationY, rotationZ
        }, ", ")
    guiSetText(ui.editboxes.output, str)
end

local function createPreviewWindow()
    if preview.state then
        return false
    end

    showCursor(true)
    guiSetInputMode("no_binds_when_editing")

    ui.windows.general = guiCreateWindow(wndX, wndY, wndWidth, wndHeight, "Attachment Preview", false)
    guiWindowSetSizable(ui.windows.general, false)

    ui.labels.model = guiCreateLabel(10, 30, 50, 30, "Model:", false, ui.windows.general)
    ui.editboxes.model = guiCreateEdit(60, 30, 100, 30, "1337", false, ui.windows.general)

    ui.labels.boneId = guiCreateLabel(10, 70, 50, 30, "Bone ID:", false, ui.windows.general)
    ui.editboxes.boneId = guiCreateEdit(60, 70, 100, 30, "1", false, ui.windows.general)

    ui.labels.scale = guiCreateLabel(10, 110, 50, 30, "Scale:", false, ui.windows.general)
    ui.editboxes.scale = guiCreateEdit(60, 110, 100, 30, "1", false, ui.windows.general)

    ui.labels.offsetX = guiCreateLabel(170, 30, 50, 30, "Offset X:", false, ui.windows.general)
    ui.editboxes.offsetX = guiCreateEdit(230, 30, 100, 30, "0", false, ui.windows.general)

    ui.labels.offsetY = guiCreateLabel(170, 70, 50, 30, "Offset Y:", false, ui.windows.general)
    ui.editboxes.offsetY = guiCreateEdit(230, 70, 100, 30, "0", false, ui.windows.general)

    ui.labels.offsetZ = guiCreateLabel(170, 110, 50, 30, "Offset Z:", false, ui.windows.general)
    ui.editboxes.offsetZ = guiCreateEdit(230, 110, 100, 30, "0", false, ui.windows.general)

    ui.scrollbars.rotationX = guiCreateScrollBar(10, 180, wndWidth - 20, 30, true, false, ui.windows.general)
    ui.scrollbars.rotationY = guiCreateScrollBar(10, 220, wndWidth - 20, 30, true, false, ui.windows.general)
    ui.scrollbars.rotationZ = guiCreateScrollBar(10, 260, wndWidth - 20, 30, true, false, ui.windows.general)

    ui.labels.output = guiCreateLabel(10, 300, 50, 30, "Output:", false, ui.windows.general)
    ui.editboxes.output = guiCreateEdit(10, 320, wndWidth - 20, 30, "Waiting...", false, ui.windows.general)
    guiEditSetReadOnly(ui.editboxes.output, true)
    
    bindKey("mouse2", "both", toggleCursor)
    addEventHandler("onClientGUIChanged", guiRoot, previewChanged)
    addEventHandler("onClientGUIScroll", guiRoot, previewChanged)
end

local function destroyPreviewWindow()
    if preview.state == false then
        return false
    end

    removeEventHandler("onClientGUIChanged", guiRoot, previewChanged)
    removeEventHandler("onClientGUIScroll", guiRoot, previewChanged)
    showCursor(false)
    unbindKey("mouse2", "both", toggleCursor)
    destroyElement(ui.windows.general)
    
    ui = {windows = {}, buttons = {}, labels = {}, editboxes = {}, scrollbars = {}}
end

local function createPreviewObject()
    if preview.state then
        return false
    end

    preview.object = createObject(1337, 0, 0, 0)
    attach(preview.object, localPlayer, 1, 0, 0, 0, 0, 0, 0)
end

local function destroyPreviewObject()
    if preview.state == false then
        return false
    end

    if preview.object and isElement(preview.object) then
        detach(preview.object)
        destroyElement(preview.object)
        preview.object = nil
    end
end

local function togglePreviewWindow(bool)
    if type(bool) ~= "boolean" then
        return false
    end

    if bool then
        createPreviewWindow()
        createPreviewObject()
        preview.state = true
    else
        destroyPreviewWindow()
        destroyPreviewObject()
        preview.state = false
    end
end

-- Commands
addCommandHandler("ap", function(command)
    togglePreviewWindow(not preview.state)
end)