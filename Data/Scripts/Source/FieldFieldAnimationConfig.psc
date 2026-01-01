Scriptname FieldFieldAnimationConfig extends Quest

; FieldField Animation Configuration Script
; Utility script for animation management
; Manages animation configuration per hatch
; Maps existing animations to hatch states
; Allows custom animation overrides
; Handles animation state transitions

String[] CommonOpenAnimations
String[] CommonCloseAnimations
String[] CommonIdleAnimations

Event OnInit()
    ; Initialize common animation name arrays
    CommonOpenAnimations = new String[10]
    CommonOpenAnimations[0] = "Open"
    CommonOpenAnimations[1] = "HatchOpen"
    CommonOpenAnimations[2] = "DoorOpen"
    CommonOpenAnimations[3] = "OpenFast"
    CommonOpenAnimations[4] = "OpenSlow"
    CommonOpenAnimations[5] = "Activate"
    CommonOpenAnimations[6] = "Unlock"
    CommonOpenAnimations[7] = "Play01"
    CommonOpenAnimations[8] = "StateA"
    CommonOpenAnimations[9] = "Open01"
    
    CommonCloseAnimations = new String[10]
    CommonCloseAnimations[0] = "Close"
    CommonCloseAnimations[1] = "HatchClose"
    CommonCloseAnimations[2] = "DoorClose"
    CommonCloseAnimations[3] = "CloseFast"
    CommonCloseAnimations[4] = "CloseSlow"
    CommonCloseAnimations[5] = "Deactivate"
    CommonCloseAnimations[6] = "Lock"
    CommonCloseAnimations[7] = "Play02"
    CommonCloseAnimations[8] = "StateB"
    CommonCloseAnimations[9] = "Close01"
    
    CommonIdleAnimations = new String[5]
    CommonIdleAnimations[0] = "Idle"
    CommonIdleAnimations[1] = "Idle01"
    CommonIdleAnimations[2] = "Idle02"
    CommonIdleAnimations[3] = "Default"
    CommonIdleAnimations[4] = "Static"
    CommonIdleAnimations[5] = "OpenIdle"
    CommonIdleAnimations[6] = "CloseIdle"
EndEvent

; Detect available animations on an object
String[] Function DetectAvailableAnimations(ObjectReference obj)
    ; Note: Papyrus may have limited ability to enumerate animations
    ; This is a placeholder that would need to be implemented based on available API
    String[] detectedAnims = new String[0]
    
    ; Try to query object for animations
    ; This may require testing what's actually available in Starfield's Papyrus API
    ; For now, return empty array - actual implementation depends on engine capabilities
    
    Return detectedAnims
EndFunction

; Get appropriate animation for a given state
String Function GetDefaultAnimation(ObjectReference obj, String animState)
    If obj == None || animState == ""
        Return ""
    EndIf
    
    ; Try common animation names based on state
    String[] animList
    
    If animState == "Open"
        animList = CommonOpenAnimations
    ElseIf animState == "Close"
        animList = CommonCloseAnimations
    ElseIf animState == "Idle"
        animList = CommonIdleAnimations
    Else
        Return ""
    EndIf
    
    ; Try each animation name (would need to test if animation exists)
    ; For now, return the first common one
    If animList.Length > 0
        Return animList[0]
    EndIf
    
    Return ""
EndFunction

; Play hatch animation
Function PlayHatchAnimation(ObjectReference obj, String animName, Bool waitForCompletion)
    If obj == None || animName == ""
        Return
    EndIf
    
    ; Play animation
    If waitForCompletion
        obj.PlayAnimationAndWait(animName, "End")
    Else
        obj.PlayAnimation(animName)
    EndIf
    
    Debug.Trace("FieldFieldAnimationConfig: Playing animation " + animName + " on " + obj)
EndFunction

; Check if animation is currently playing
Bool Function IsAnimationPlaying(ObjectReference obj)
    ; This may not be directly queryable in Papyrus
    ; Would need to track animation state manually or use available API
    Return False ; Placeholder
EndFunction

