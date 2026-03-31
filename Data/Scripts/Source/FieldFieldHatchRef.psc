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
Bool IsTransitionLocked = False

Event OnActivate(ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    
    If IsAnimating || IsTransitionLocked
        Return
    EndIf

    ; Check if player is in ship vs. on land
    Bool inShip = IsPlayerInShip()
    
    ; Use graph teleport when player is in a ship interior and space-exit checks pass.
    If inShip && CanExitShipToSpace()
        HandleTeleport()
    Else
        ; Fall back to default hatch behavior.
        HandleNormalExit()
    EndIf
EndEvent

Bool Function IsPlayerInShip()
    Actor playerRef = Game.GetPlayer()
    If playerRef == None
        Return False
    EndIf

    SpaceshipReference currentShip = playerRef.GetCurrentShipRef()
    If currentShip == None
        Return False
    EndIf

    Cell playerCell = playerRef.GetParentCell()
    Return playerCell != None && playerCell.IsInterior()
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

Bool Function CanExitShipToSpace()
    Actor playerRef = Game.GetPlayer()
    If playerRef == None
        Return False
    EndIf

    SpaceshipReference currentShip = playerRef.GetCurrentShipRef()
    If currentShip == None
        Debug.Trace("FieldFieldHatchRef: Cannot exit to space - no current ship")
        Return False
    EndIf

    If !playerRef.IsInSpace()
        Debug.Trace("FieldFieldHatchRef: Cannot exit to space - player is not in space")
        Return False
    EndIf

    If currentShip.IsLanded()
        Debug.Trace("FieldFieldHatchRef: Cannot exit to space - ship is landed")
        Return False
    EndIf

    If currentShip.IsInCombat()
        Debug.Trace("FieldFieldHatchRef: Cannot exit to space - ship is in combat")
        Return False
    EndIf

    If currentShip.IsExteriorLoadDoorInaccessible()
        Debug.Trace("FieldFieldHatchRef: Cannot exit to space - exterior load door is inaccessible")
        Return False
    EndIf

    Return True
EndFunction

Function HandleTeleport()
    ; Teleport to configured exit point
    Debug.Trace("FieldFieldHatchRef: Teleport behavior for " + Self)

    If IsTransitionLocked
        Debug.Trace("FieldFieldHatchRef: Transition already in progress for " + Self)
        Return
    EndIf

    If !CanExitShipToSpace()
        Return
    EndIf
    
    IsTransitionLocked = True

    ; Get exit point (auto-placed or manual)
    ObjectReference exitPoint = GetExitPoint()
    
    If !IsValidExitPoint(exitPoint)
        Debug.Notification("FieldField: No exit point configured for this hatch")
        IsTransitionLocked = False
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
    IsTransitionLocked = False
    
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

Bool Function IsValidExitPoint(ObjectReference exitPoint)
    If exitPoint == None
        Debug.Trace("FieldFieldHatchRef: Exit point lookup returned None for " + Self)
        Return False
    EndIf

    If exitPoint.IsDisabled()
        Debug.Trace("FieldFieldHatchRef: Exit point is disabled for hatch " + Self)
        Return False
    EndIf

    Return True
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

