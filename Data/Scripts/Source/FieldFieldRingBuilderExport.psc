Scriptname FieldFieldRingBuilderExport extends Quest

; Strip serialization: build a transmittable string (JSON-like) for the current ring/zone and placed buildings.
; PC-only in practice: player copies from trace or message and submits via Nexus/Discord. No native file write in Papyrus.
; Optional: add FFRB_ExportEnabled global (true on PC) and check before showing export UI.

FieldFieldRingBuilderQuest Property RingBuilderQuest Auto Mandatory
RefCollectionAlias Property PlacedQuestBuildingsAlias Auto
RefCollectionAlias Property PlacedBuildingsAlias Auto

; Format version for validator
Int Property ExportFormatVersion = 1 Auto Const

String Function BuildStripExportString()
    If RingBuilderQuest == None
        Return ""
    EndIf
    String s = "{\"formatVersion\":" + ExportFormatVersion + ","
    s += "\"ring\":" + RingBuilderQuest.GetCurrentRing() + ","
    s += "\"zoneInRing\":" + RingBuilderQuest.GetCurrentZoneInRing() + ","
    Int days = RingBuilderQuest.GetDaysOnRoad() as Int
    s += "\"daysOnRoad\":" + days + ","
    s += "\"placedRefs\":["
    Bool first = True
    If PlacedBuildingsAlias != None
        Int n = PlacedBuildingsAlias.GetCount()
        Int i = 0
        While i < n
            ObjectReference ref = PlacedBuildingsAlias.GetAt(i)
            If ref != None
                If !first
                    s += ","
                EndIf
                s += "{\"formId\":" + ref.GetFormID() + ",\"baseId\":" + ref.GetBaseObject().GetFormID() + "}"
                first = False
              EndIf
            i += 1
        EndWhile
    EndIf
    If PlacedQuestBuildingsAlias != None
        Int m = PlacedQuestBuildingsAlias.GetCount()
        Int j = 0
        While j < m
            ObjectReference ref = PlacedQuestBuildingsAlias.GetAt(j)
            If ref != None
                If !first
                    s += ","
                EndIf
                s += "{\"formId\":" + ref.GetFormID() + ",\"baseId\":" + ref.GetBaseObject().GetFormID() + ",\"questUnique\":true}"
                first = False
            EndIf
            j += 1
        EndWhile
    EndIf
    s += "]}"
    Return s
EndFunction

; Output to trace (PC: capture with log or external tool). Call from a terminal/button.
Function ExportStripToTrace()
    String data = BuildStripExportString()
    Debug.Trace("FFRB_STRIP_EXPORT_START")
    Debug.Trace(data)
    Debug.Trace("FFRB_STRIP_EXPORT_END")
EndFunction

; Show a message directing player to the log. Assign ExportResultMessage in CK; set its text to e.g.
; "Strip data written to the Papyrus log. Copy from the log file (see MOD_README / RING_BUILDER.md)."
Message Property ExportResultMessage Auto

Function ExportStripToMessage()
    String data = BuildStripExportString()
    Debug.Trace("FFRB_STRIP_EXPORT_START")
    Debug.Trace(data)
    Debug.Trace("FFRB_STRIP_EXPORT_END")
    If ExportResultMessage != None
        ExportResultMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    EndIf
    Debug.Notification("Strip export written to Papyrus log. See message.")
EndFunction
