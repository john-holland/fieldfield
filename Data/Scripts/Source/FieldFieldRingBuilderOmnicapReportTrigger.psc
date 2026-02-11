Scriptname FieldFieldRingBuilderOmnicapReportTrigger extends ObjectReference

; Place in omnicap (or any menu/terminal). When player activates, runs the Ring Builder quest's omnicap report (trace + optional message).

FieldFieldRingBuilderQuest Property RingBuilderQuest Auto Mandatory

Event OnActivate(ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    If RingBuilderQuest == None || !RingBuilderQuest.IsRunning()
        Return
    EndIf
    RingBuilderQuest.RunOmnicapReport()
    Debug.Trace("FieldFieldRingBuilderOmnicapReportTrigger: Report run")
EndEvent
