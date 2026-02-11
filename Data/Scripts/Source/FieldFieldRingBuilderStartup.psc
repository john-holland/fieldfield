Scriptname FieldFieldRingBuilderStartup extends Quest

; Total conversion startup: runs once on new game. Set this quest to Start Game Enabled.
; Stage 10 fragment should: SetStage on vanilla intro (MQ101) to skip stage, MoveTo player to omnicap, start Ring Builder quest.

Quest Property VanillaIntroQuest Auto Mandatory
; Set in CK: the stage that completes/skips the vanilla intro (e.g. 2000 - verify with GetStage in console)
Int Property VanillaIntroSkipStage = 2000 Auto
; If set in CK and value is 0, skip is disabled (ring builder can be triggered by world interaction only, no MoveTo omnicap at start).
GlobalVariable Property FFRB_UseTotalConversion Auto

ObjectReference Property OmnicapStartRef Auto Mandatory
Quest Property RingBuilderQuest Auto Mandatory
; Ring Builder start stage (e.g. 10)
Int Property RingBuilderStartStage = 10 Auto

Event OnQuestInit()
    ; Run skip and handoff when this quest starts (first stage fragment will also run)
    Utility.Wait(0.5)
    RunVanillaSkipAndStartRingBuilder()
EndEvent

; Call from Stage 10 fragment or from here. SetStage on vanilla intro, MoveTo omnicap, start ring builder.
Function RunVanillaSkipAndStartRingBuilder()
    If FFRB_UseTotalConversion != None && FFRB_UseTotalConversion.GetValueInt() == 0
        Debug.Trace("FieldFieldRingBuilderStartup: Total conversion disabled (FFRB_UseTotalConversion=0), skipping")
        Return
    EndIf
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    If VanillaIntroQuest != None
        VanillaIntroQuest.SetStage(VanillaIntroSkipStage)
        Debug.Trace("FieldFieldRingBuilderStartup: Set vanilla intro quest to stage " + VanillaIntroSkipStage)
    EndIf
    If OmnicapStartRef != None
        player.MoveTo(OmnicapStartRef)
        Debug.Trace("FieldFieldRingBuilderStartup: Moved player to omnicap")
    EndIf
    If RingBuilderQuest != None && !RingBuilderQuest.IsRunning()
        RingBuilderQuest.Start()
        If RingBuilderStartStage > 0
            RingBuilderQuest.SetStage(RingBuilderStartStage)
        EndIf
        Debug.Trace("FieldFieldRingBuilderStartup: Started Ring Builder quest at stage " + RingBuilderStartStage)
    EndIf
    ; Optionally stop this startup quest so it doesn't run again
    SetStage(20)
EndFunction
