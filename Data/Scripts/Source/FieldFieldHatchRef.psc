Scriptname FieldFieldHatchRef extends ObjectReference

; FieldField Hatch Reference Script
; Attached to individual hatch objects
; Handles per-hatch activation logic
; Manages animation state
; Triggers teleport when on land
; References configured exit point
; Uses animation configuration for state transitions

ObjectReference Property ExitPointRef Auto
Bool Property UseCustomAnimations = False Auto
String Property OpenAnimation = "" Auto
String Property CloseAnimation = "" Auto
Float Property AnimationDelay = 1.0 Auto

FieldFieldHatchManager Property HatchManager Auto
FieldFieldAnimationConfig Property AnimationConfig Auto

Bool IsOpen = False
Bool IsAnimating = False

Event OnActivate(ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    
    ; Check if player is in ship vs. on land
    Bool inShip = IsPlayerInShip()
    
    If inShip
        ; Normal hatch behavior (exit to space/land)
        HandleNormalExit()
    Else
        ; Teleport to configured destination
        HandleTeleport()
    EndIf
EndEvent

Bool Function IsPlayerInShip()
    ; Determine if player is in a ship interior
    ; This is a placeholder - actual implementation depends on available game functions
    Location playerLoc = Game.GetPlayer().GetCurrentLocation()
    
    ; Check location properties or keywords
    ; May need to check cell type or other indicators
    Return False ; Placeholder
EndFunction

Function HandleNormalExit()
    ; Normal hatch exit behavior
    Debug.Trace("FieldFieldHatchRef: Normal exit behavior for " + Self)
    
    ; Play close animation if needed
    If !IsOpen
        PlayOpenAnimation()
    EndIf
    
    ; Let the game handle normal exit
    ; This may need to call game functions or let default behavior occur
EndFunction

Function HandleTeleport()
    ; Teleport to configured exit point
    Debug.Trace("FieldFieldHatchRef: Teleport behavior for " + Self)
    
    ; Get exit point (auto-placed or manual)
    ObjectReference exitPoint = GetExitPoint()
    
    If exitPoint == None
        Debug.Notification("FieldField: No exit point configured for this hatch")
        Return
    EndIf
    
    ; Play open animation
    PlayOpenAnimation()
    
    ; Wait for animation delay
    Utility.Wait(AnimationDelay)
    
    ; Teleport player
    Game.GetPlayer().MoveTo(exitPoint)
    
    ; Play close animation at destination
    PlayCloseAnimation()
    
    Debug.Notification("FieldField: Teleported to exit point")
EndFunction

ObjectReference Function GetExitPoint()
    ; Get exit point from manager (auto-placed) or manual configuration
    If HatchManager != None
        ObjectReference exitPoint = HatchManager.GetExitPointForHatch(Self)
        If exitPoint != None
            Return exitPoint
        EndIf
    EndIf
    
    ; Fall back to manually configured exit point
    Return ExitPointRef
EndFunction

Function PlayOpenAnimation()
    If IsAnimating
        Return
    EndIf
    
    IsAnimating = True
    
    String animName = GetOpenAnimationName()
    If animName != ""
        If AnimationConfig != None
            AnimationConfig.PlayHatchAnimation(Self, animName, False)
        Else
            ; Fallback to direct animation call
            PlayAnimation(animName)
        EndIf
    EndIf
    
    IsOpen = True
    IsAnimating = False
EndFunction

Function PlayCloseAnimation()
    If IsAnimating
        Return
    EndIf
    
    IsAnimating = True
    
    String animName = GetCloseAnimationName()
    If animName != ""
        If AnimationConfig != None
            AnimationConfig.PlayHatchAnimation(Self, animName, False)
        Else
            ; Fallback to direct animation call
            PlayAnimation(animName)
        EndIf
    EndIf
    
    IsOpen = False
    IsAnimating = False
EndFunction

String Function GetOpenAnimationName()
    If UseCustomAnimations && OpenAnimation != ""
        Return OpenAnimation
    EndIf
    
    ; Auto-detect animation
    If AnimationConfig != None
        Return AnimationConfig.GetDefaultAnimation(Self, "Open")
    EndIf
    
    ; Default animation names to try
    Return "Open"
EndFunction

String Function GetCloseAnimationName()
    If UseCustomAnimations && CloseAnimation != ""
        Return CloseAnimation
    EndIf
    
    ; Auto-detect animation
    If AnimationConfig != None
        Return AnimationConfig.GetDefaultAnimation(Self, "Close")
    EndIf
    
    ; Default animation names to try
    Return "Close"
EndFunction

