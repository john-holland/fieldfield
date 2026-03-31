Scriptname FieldFieldRingBuilderCityZoneTrigger extends ObjectReference

; Place in the city zone (omnicap) special volume. When the player enters, notifies the Ring Builder quest
; (arrival at capitol: play capitol cutscene, check stability, return to normal mode).
; Use with quest triggers and dialog cutscenes in CK.

FieldFieldRingBuilderQuest Property RingBuilderQuest Auto Mandatory

; Only fire once per visit (reset when player leaves ring or on quest stage)
Bool Property FiredThisVisit = False Auto Hidden

Event OnTriggerEnter(ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    If RingBuilderQuest == None || !RingBuilderQuest.IsRunning()
        Return
    EndIf
    ; Optional: only when returning (e.g. after at least one zone). For "first time" intro, use a different trigger/stage.
    RingBuilderQuest.OnArrivedAtCityZone()
    FiredThisVisit = True
    Debug.Trace("FieldFieldRingBuilderCityZoneTrigger: Player arrived at city zone")
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)
    If akActionRef == Game.GetPlayer()
        FiredThisVisit = False
    EndIf
EndEvent
