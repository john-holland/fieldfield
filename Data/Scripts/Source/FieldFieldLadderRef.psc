Scriptname FieldFieldLadderRef extends ObjectReference

; FieldField Clickable Ladder with highlight to use.
; Attach to ladder refs; set DestinationRef (top or bottom marker). Optional EffectShader for near-range highlight.
; LadderEnabled = false turns off use (no activation, no pathfinding use) but does not hide the ladder cosmetically.

ObjectReference Property DestinationRef Auto
EffectShader Property HighlightShader Auto
Float Property HighlightRange = 400.0 Auto
Bool Property ClimbUp = True Auto
Bool Property LadderEnabled = True Auto

Int Const EventID_Distance = 0

Event OnLoad()
    BlockActivation(False, False)
    If !LadderEnabled
        Return
    EndIf
    If HighlightShader != None
        RegisterForDistanceLessThanEvent(Game.GetPlayer(), Self, HighlightRange, EventID_Distance)
    EndIf
EndEvent

Event OnDistanceLessThan(ObjectReference akObj1, ObjectReference akObj2, Float afDistance, Int aiEventID)
    If aiEventID != EventID_Distance || !LadderEnabled
        Return
    EndIf
    If HighlightShader != None
        HighlightShader.Play(Self)
    EndIf
    UnregisterForDistanceEvents(Self, Game.GetPlayer(), EventID_Distance)
    RegisterForDistanceGreaterThanEvent(Game.GetPlayer(), Self, HighlightRange, EventID_Distance)
EndEvent

Event OnDistanceGreaterThan(ObjectReference akObj1, ObjectReference akObj2, Float afDistance, Int aiEventID)
    If aiEventID != EventID_Distance
        Return
    EndIf
    If HighlightShader != None
        HighlightShader.Stop(Self)
    EndIf
    UnregisterForDistanceEvents(Self, Game.GetPlayer(), EventID_Distance)
    RegisterForDistanceLessThanEvent(Game.GetPlayer(), Self, HighlightRange, EventID_Distance)
EndEvent

Event OnActivate(ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    If !LadderEnabled
        Return
    EndIf
    ; Stop highlight and unregister so ladder doesn't stay highlighted after use
    If HighlightShader != None
        HighlightShader.Stop(Self)
    EndIf
    UnregisterForDistanceEvents(Self, Game.GetPlayer(), EventID_Distance)
    RegisterForDistanceLessThanEvent(Game.GetPlayer(), Self, HighlightRange, EventID_Distance)

    If DestinationRef == None
        Return
    EndIf
    Debug.Notification("Climbing...")
    akActionRef.MoveTo(DestinationRef)
EndEvent
