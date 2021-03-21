# Attachments (Bone) - MTA: SA
Bone attach with a preview panel to configure the positions and rotations.

## How to open the panel
**Command**: type ``/ap`` to open - everyone can open this, once it's just for previewing to the client.

## Exported Functions
### attach
```lua
void attach(
    object element, remote player, int boneId,
    float offsetX, float offsetY, float offsetZ,
    float rotationX, float rotationY, float rotationZ
)
```
#### Parameters
**element**: the object that you want to attach  
**player**: the remote player that will receive that attached element  
**boneId**: the bone ID that you are attaching to  
**offsetX, offsetY, offsetZ**: x, y and z values determining where the object will be. Left, right, backwards, forwards, up, down  
**rotationX, rotationY, rotationZ**: rx, ry and rz of the attached element

### detach
```lua
void detach(object element)
```
#### Parameters
**element**: the object that will be detached from the remote player

### updateAttachment
```lua
void updateAttachment(
    object element, int boneId,
    float offsetX, float offsetY, float offsetZ,
    float rotationX, float rotationY, float rotationZ
)
```
#### Parameters
**element**: the object that you want to update  
**boneId**: the bone ID that you are attaching to  
**offsetX, offsetY, offsetZ**: x, y and z values determining where the object will be. Left, right, backwards, forwards, up, down  
**rotationX, rotationY, rotationZ**: rx, ry and rz of the attached element

### isAttached
```lua
bool isAttached(object element)
```
#### Parameters
**element**: the object that you want to check  

### getAttachmentDetails
```lua
table getAttachmentDetails(object element)
```
#### Parameters
**element**: the object that you want to get the details
