Scriptname FieldFieldRingBuilderRoamVolume extends ObjectReference

; Roam volume: exterior land that is roamable. At the boundary: snow VFX, then "too heavy to continue" and teleport back.
; Attach to a trigger or volume; set BoundaryRef or use distance from center.

; Optional: explicit boundary ref (trigger). When player enters it, apply effect and send back.
ObjectReference Property BoundaryRef Auto

; If BoundaryRef is None: treat distance from this ref as boundary. When player exceeds BoundaryDistance, trigger.
Float Property BoundaryDistance = 3000.0 Auto

; Where to send the player when they hit the boundary (e.g. volume start or last safe node)
ObjectReference Property ReturnToRef Auto

; VFX: snow or other effect at boundary (optional)
VisualEffect Property BoundaryEffect Auto
EffectShader Property BoundaryShader Auto

; Message or scene for "too heavy to continue"
Message Property TooHeavyMessage Auto

Bool Property BoundaryTriggered = False Auto Hidden

Event OnTriggerEnter(ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    ; If this is the boundary trigger, send back
    If BoundaryRef != None && self == BoundaryRef
        TriggerBoundaryReturn()
    EndIf
EndEvent

; Call from a separate boundary trigger that has this script, or from OnUpdate if using distance check
Function TriggerBoundaryReturn()
    If BoundaryTriggered
        Return
    EndIf
    BoundaryTriggered = True
    Actor player = Game.GetPlayer()
    If player == None
        BoundaryTriggered = False
        Return
    EndIf
    If BoundaryEffect != None
        BoundaryEffect.Play(player, -1.0)
    EndIf
    If BoundaryShader != None
        BoundaryShader.Play(player, 2.0)
    EndIf
    If TooHeavyMessage != None
        TooHeavyMessage.Show()
    EndIf
    Utility.Wait(1.5)
    If ReturnToRef != None
        player.MoveTo(ReturnToRef)
    Else
        player.MoveTo(self)
    EndIf
    If BoundaryShader != None
        BoundaryShader.Stop(player)
    EndIf
    BoundaryTriggered = False
EndFunction

; Distance-based boundary requires a separate trigger (BoundaryRef). Starfield Papyrus does not support
; RegisterForSingleUpdate/OnUpdate in non-native scripts; set BoundaryRef in CK for boundary detection.
