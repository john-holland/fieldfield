Scriptname FieldFieldRingBuilderQuest extends Quest

; Porrima II Ring Builder - Central quest. Tracks 12 rings, time elapsed, (secret) WIP ring.
; Do NOT set Start Game Enabled; trigger via FieldFieldRingBuilderStartup or world interaction.
; Use quest stages in increments of 10 (10, 20, 30, ...).

; --- Time (show in mission menu via text replacement: add this global to Quest Data, use <FFRB_DaysOnRoad> in description) ---
GlobalVariable Property FFRB_DaysOnRoad Auto Mandatory

; --- Secret: link to the ring being built (never shown in objectives) ---
ObjectReference Property WIPRingRef Auto

; --- Omnicap (city zone) start position ---
ObjectReference Property OmnicapStartRef Auto

; --- 12 rings: each FormList holds zone refs or anchor refs for that ring (0..11) ---
FormList Property Ring0ZoneRefs Auto
FormList Property Ring1ZoneRefs Auto
FormList Property Ring2ZoneRefs Auto
FormList Property Ring3ZoneRefs Auto
FormList Property Ring4ZoneRefs Auto
FormList Property Ring5ZoneRefs Auto
FormList Property Ring6ZoneRefs Auto
FormList Property Ring7ZoneRefs Auto
FormList Property Ring8ZoneRefs Auto
FormList Property Ring9ZoneRefs Auto
FormList Property Ring10ZoneRefs Auto
FormList Property Ring11ZoneRefs Auto

; --- Current state ---
Int Property CurrentRing = 0 Auto Hidden
Int Property CurrentZoneInRing = 0 Auto Hidden

; --- Optional: city zone override (script or quest that handles "arrive at capitol" / return to normal mode) ---
Quest Property CityZoneOverrideQuest Auto

; --- Optional: per-ring refs for omnicap report (placement volumes and ship landings). If None, report shows 0. ---
FormList Property Ring0PlacementVolumes Auto
FormList Property Ring1PlacementVolumes Auto
FormList Property Ring2PlacementVolumes Auto
FormList Property Ring3PlacementVolumes Auto
FormList Property Ring4PlacementVolumes Auto
FormList Property Ring5PlacementVolumes Auto
FormList Property Ring6PlacementVolumes Auto
FormList Property Ring7PlacementVolumes Auto
FormList Property Ring8PlacementVolumes Auto
FormList Property Ring9PlacementVolumes Auto
FormList Property Ring10PlacementVolumes Auto
FormList Property Ring11PlacementVolumes Auto
FormList Property Ring0ShipLandings Auto
FormList Property Ring1ShipLandings Auto
FormList Property Ring2ShipLandings Auto
FormList Property Ring3ShipLandings Auto
FormList Property Ring4ShipLandings Auto
FormList Property Ring5ShipLandings Auto
FormList Property Ring6ShipLandings Auto
FormList Property Ring7ShipLandings Auto
FormList Property Ring8ShipLandings Auto
FormList Property Ring9ShipLandings Auto
FormList Property Ring10ShipLandings Auto
FormList Property Ring11ShipLandings Auto

Event OnInit()
    Debug.Trace("FieldFieldRingBuilderQuest: Initialized")
    CurrentRing = 0
    CurrentZoneInRing = 0
EndEvent

; Call when a leg of travel completes or time advances (e.g. after zone transition).
Function AdvanceTime(Float daysToAdd = 1.0)
    If FFRB_DaysOnRoad == None
        Return
    EndIf
    FFRB_DaysOnRoad.SetValue(FFRB_DaysOnRoad.GetValue() + daysToAdd)
    UpdateTimeDisplay()
EndFunction

; Refresh mission menu description (quest must have FFRB_DaysOnRoad in Quest Data for text replacement).
Function UpdateTimeDisplay()
    If FFRB_DaysOnRoad != None
        UpdateCurrentInstanceGlobal(FFRB_DaysOnRoad)
    EndIf
EndFunction

; Start on a specific ring (0..11). Call from dialog or terminal.
Function SetCurrentRing(Int ringIndex)
    If ringIndex < 0
        ringIndex = 0
    ElseIf ringIndex > 11
        ringIndex = 11
    EndIf
    CurrentRing = ringIndex
    CurrentZoneInRing = 0
    Debug.Trace("FieldFieldRingBuilderQuest: SetCurrentRing " + CurrentRing)
EndFunction

Int Function GetCurrentRing()
    Return CurrentRing
EndFunction

Int Function GetCurrentZoneInRing()
    Return CurrentZoneInRing
EndFunction

Float Function GetDaysOnRoad()
    If FFRB_DaysOnRoad != None
        Return FFRB_DaysOnRoad.GetValue()
    EndIf
    Return 0.0
EndFunction

; Set current zone index (e.g. when travelling via map selection).
Function SetCurrentZoneInRing(Int zoneIndex)
    If zoneIndex < 0
        CurrentZoneInRing = 0
    Else
        FormList list = GetZoneRefsForRing(CurrentRing)
        If list != None && zoneIndex < list.GetSize()
            CurrentZoneInRing = zoneIndex
        EndIf
    EndIf
EndFunction

; Get FormList of zone refs for the given ring (0..11).
FormList Function GetZoneRefsForRing(Int ringIndex)
    If ringIndex == 0
        Return Ring0ZoneRefs
    ElseIf ringIndex == 1
        Return Ring1ZoneRefs
    ElseIf ringIndex == 2
        Return Ring2ZoneRefs
    ElseIf ringIndex == 3
        Return Ring3ZoneRefs
    ElseIf ringIndex == 4
        Return Ring4ZoneRefs
    ElseIf ringIndex == 5
        Return Ring5ZoneRefs
    ElseIf ringIndex == 6
        Return Ring6ZoneRefs
    ElseIf ringIndex == 7
        Return Ring7ZoneRefs
    ElseIf ringIndex == 8
        Return Ring8ZoneRefs
    ElseIf ringIndex == 9
        Return Ring9ZoneRefs
    ElseIf ringIndex == 10
        Return Ring10ZoneRefs
    ElseIf ringIndex == 11
        Return Ring11ZoneRefs
    EndIf
    Return None
EndFunction

; Get zone ref at index within current ring (for "next zone" / start position). Returns None if out of range.
ObjectReference Function GetZoneRef(Int ringIndex, Int zoneIndex)
    FormList list = GetZoneRefsForRing(ringIndex)
    If list == None || zoneIndex < 0
        Return None
    EndIf
    Int n = list.GetSize()
    If zoneIndex >= n
        Return None
    EndIf
    Form f = list.GetAt(zoneIndex)
    Return f as ObjectReference
EndFunction

; Advance to next zone in current ring. Returns true if there is a next zone.
Bool Function AdvanceToNextZone()
    FormList list = GetZoneRefsForRing(CurrentRing)
    If list == None
        Return False
    EndIf
    If CurrentZoneInRing + 1 >= list.GetSize()
        Return False
    EndIf
    CurrentZoneInRing += 1
    Debug.Trace("FieldFieldRingBuilderQuest: AdvanceToNextZone -> " + CurrentZoneInRing)
    Return True
EndFunction

; Move to previous zone in ring.
Bool Function RetreatToPreviousZone()
    If CurrentZoneInRing <= 0
        Return False
    EndIf
    CurrentZoneInRing -= 1
    Debug.Trace("FieldFieldRingBuilderQuest: RetreatToPreviousZone -> " + CurrentZoneInRing)
    Return True
EndFunction

; Called when player arrives at city zone (omnicap). Optionally run override quest logic.
Function OnArrivedAtCityZone()
    UpdateTimeDisplay()
    If CityZoneOverrideQuest != None && CityZoneOverrideQuest.IsRunning()
        ; Custom: e.g. set stage on CityZoneOverrideQuest to play capitol cutscene, check stability, return to normal mode
        CityZoneOverrideQuest.SetStage(20)
    EndIf
EndFunction

; Call from city zone override quest when the ring builder finale runs: disable dungeon-crawl takeover, enable normal camera/movement.
; Set FFRB_ReturnToNormalMode (or similar global) to 1 so other systems (e.g. Dungeon Crawl Controller) can release control; then optionally advance MQ101 for "join Constellation as Cyborg."
Function RequestReturnToNormalMode()
    If FFRB_ReturnToNormalMode != None
        FFRB_ReturnToNormalMode.SetValueInt(1)
    EndIf
    Debug.Trace("FieldFieldRingBuilderQuest: RequestReturnToNormalMode called")
EndFunction

; Optional global: when set to 1, dungeon-crawl/ring-builder takeover should release (normal movement and camera). Set in CK.
GlobalVariable Property FFRB_ReturnToNormalMode Auto

; --- Omnicap report: build a string with per-ring stats and completion %. Trace it; call from terminal/trigger. ---
String Function BuildOmnicapReportString()
    String s = "=== Omnicap Construction Report ==="
    Int totalChecks = 0
    Int passedChecks = 0
    Int ring = 0
    While ring < 12
        FormList zoneRefs = GetZoneRefsForRing(ring)
        FormList volRefs = GetPlacementVolumesForRing(ring)
        FormList landRefs = GetShipLandingsForRing(ring)
        Int zoneCount = 0
        If zoneRefs != None
            zoneCount = zoneRefs.GetSize()
        EndIf
        Int volCount = 0
        If volRefs != None
            volCount = volRefs.GetSize()
        EndIf
        Int landCount = 0
        If landRefs != None
            landCount = landRefs.GetSize()
        EndIf
        Int zonesWithEntrance = 0
        Int zonesWithExit = 0
        Bool hasCityZone = False
        Int zi = 0
        While zi < zoneCount
            ObjectReference zref = zoneRefs.GetAt(zi) as ObjectReference
            If zref != None
                FieldFieldRingBuilderZoneData zd = zref as FieldFieldRingBuilderZoneData
                If zd != None
                    If zd.HasEntrance
                        zonesWithEntrance += 1
                    EndIf
                    If zd.HasExit
                        zonesWithExit += 1
                    EndIf
                    If zd.IsCityZone
                        hasCityZone = True
                    EndIf
                EndIf
            EndIf
            zi += 1
        EndWhile
        Bool connectsAround = (zoneCount > 0)
        totalChecks += 5
        If volCount > 0
            passedChecks += 1
        EndIf
        If landCount > 0
            passedChecks += 1
        EndIf
        If zonesWithEntrance >= zoneCount && zoneCount > 0
            passedChecks += 1
        EndIf
        If zonesWithExit >= zoneCount && zoneCount > 0
            passedChecks += 1
        EndIf
        If hasCityZone && connectsAround
            passedChecks += 1
        EndIf
        s += "\nRing " + ring + ": zones=" + zoneCount + " volumes=" + volCount + " shipLandings=" + landCount
        s += " entranceOk=" + zonesWithEntrance + "/" + zoneCount + " exitOk=" + zonesWithExit + "/" + zoneCount
        s += " hasCityZone=" + hasCityZone
        ring += 1
    EndWhile
    Float pct = 0.0
    If totalChecks > 0
        pct = (passedChecks as Float / totalChecks as Float) * 100.0
    EndIf
    s += "\n--- Completion: " + passedChecks + "/" + totalChecks + " (" + pct + "%) ---"
    Return s
EndFunction

; Call from terminal or trigger; traces report and optionally shows message.
Function RunOmnicapReport()
    String report = BuildOmnicapReportString()
    Debug.Trace("FFRB_OMNICAP_REPORT_START")
    Debug.Trace(report)
    Debug.Trace("FFRB_OMNICAP_REPORT_END")
    If OmnicapReportMessage != None
        OmnicapReportMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    EndIf
EndFunction

Message Property OmnicapReportMessage Auto

FormList Function GetPlacementVolumesForRing(Int ringIndex)
    If ringIndex == 0
        Return Ring0PlacementVolumes
    ElseIf ringIndex == 1
        Return Ring1PlacementVolumes
    ElseIf ringIndex == 2
        Return Ring2PlacementVolumes
    ElseIf ringIndex == 3
        Return Ring3PlacementVolumes
    ElseIf ringIndex == 4
        Return Ring4PlacementVolumes
    ElseIf ringIndex == 5
        Return Ring5PlacementVolumes
    ElseIf ringIndex == 6
        Return Ring6PlacementVolumes
    ElseIf ringIndex == 7
        Return Ring7PlacementVolumes
    ElseIf ringIndex == 8
        Return Ring8PlacementVolumes
    ElseIf ringIndex == 9
        Return Ring9PlacementVolumes
    ElseIf ringIndex == 10
        Return Ring10PlacementVolumes
    ElseIf ringIndex == 11
        Return Ring11PlacementVolumes
    EndIf
    Return None
EndFunction

FormList Function GetShipLandingsForRing(Int ringIndex)
    If ringIndex == 0
        Return Ring0ShipLandings
    ElseIf ringIndex == 1
        Return Ring1ShipLandings
    ElseIf ringIndex == 2
        Return Ring2ShipLandings
    ElseIf ringIndex == 3
        Return Ring3ShipLandings
    ElseIf ringIndex == 4
        Return Ring4ShipLandings
    ElseIf ringIndex == 5
        Return Ring5ShipLandings
    ElseIf ringIndex == 6
        Return Ring6ShipLandings
    ElseIf ringIndex == 7
        Return Ring7ShipLandings
    ElseIf ringIndex == 8
        Return Ring8ShipLandings
    ElseIf ringIndex == 9
        Return Ring9ShipLandings
    ElseIf ringIndex == 10
        Return Ring10ShipLandings
    ElseIf ringIndex == 11
        Return Ring11ShipLandings
    EndIf
    Return None
EndFunction

; Optional: track credits/special items used across quests (e.g. hats). Extend in CK with aliases or globals.
; This quest is the single place that tracks "which ring we're on," "time elapsed," and "link to WIP ring."
