local rad = math.rad
local sin = math.sin
local cos = math.cos

function table.getn(t)
    local i = 0

    for _ in pairs(t) do
        i = i + 1
    end
    return i
end

function calculateRotMat(rotationX, rotationY, rotationZ)
    local rotationX, rotationY, rotationZ = rad(rotationX), rad(rotationY), rad(rotationZ)
    local syaw, cyaw = sin(rotationX), cos(rotationX)
    local spitch, cpitch = sin(rotationY), cos(rotationY)
    local sroll, croll = sin(rotationZ), cos(rotationZ)

    return {
        {
            sroll * spitch * syaw + croll * cyaw,
            sroll * cpitch,
            sroll * spitch * cyaw - croll * syaw
        },
        {
            croll * spitch * syaw - sroll * cyaw,
            croll * cpitch,
            croll * spitch * cyaw + sroll * syaw
        },
        {
            cpitch * syaw,
            -spitch,
            cpitch * cyaw
        }
    }
end

VALID_BONES = {
    [0] = "BONE_ROOT",
    [1] = "BONE_PELVIS1",
    [2] = "BONE_PELVIS",
    [3] = "BONE_SPINE1",
    [4] = "BONE_UPPERTORSO",
    [5] = "BONE_NECK",
    [6] = "BONE_HEAD2",
    [7] = "BONE_HEAD1",
    [8] = "BONE_HEAD",
    [22] = "BONE_RIGHTSHOULDER",
    [23] = "BONE_RIGHTELBOW",
    [24] = "BONE_RIGHTWRIST",
    [25] = "BONE_RIGHTHAND",
    [26] = "BONE_RIGHTTHUMB",
    [31] = "BONE_LEFTUPPERTORSO",
    [32] = "BONE_LEFTSHOULDER",
    [33] = "BONE_LEFTELBOW",
    [34] = "BONE_LEFTWRIST",
    [35] = "BONE_LEFTHAND",
    [36] = "BONE_LEFTTHUMB",
    [41] = "BONE_LEFTHIP",
    [42] = "BONE_LEFTKNEE",
    [43] = "BONE_LEFTANKLE",
    [44] = "BONE_LEFTFOOT",
    [51] = "BONE_RIGHTHIP",
    [52] = "BONE_RIGHTKNEE",
    [53] = "BONE_RIGHTANKLE",
    [54] = "BONE_RIGHTFOOT",
    [201] = "BONE_BELLY",
    [301] = "BONE_RIGHTBREAST",
    [302] = "BONE_LEFTBREAST",
}