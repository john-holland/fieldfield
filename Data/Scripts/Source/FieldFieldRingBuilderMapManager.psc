Scriptname FieldFieldRingBuilderMapManager extends Quest

; Manages waypoints on Porrima II for the Ring Builder. Enables map markers for the current ring's zones
; and supports "select next travel" via dialog (place description can be replaced by this flow).
; Hook map open/close in CK or from quest stages to refresh visible markers.

FieldFieldRingBuilderQuest Property RingBuilderQuest Auto Mandatory

; Optional: FormList of map marker refs per ring (same order as zone refs). If None, zone refs are assumed to have or link to map markers.
FormList Property Ring0MapMarkers Auto
FormList Property Ring1MapMarkers Auto
FormList Property Ring2MapMarkers Auto
FormList Property Ring3MapMarkers Auto
FormList Property Ring4MapMarkers Auto
FormList Property Ring5MapMarkers Auto
FormList Property Ring6MapMarkers Auto
FormList Property Ring7MapMarkers Auto
FormList Property Ring8MapMarkers Auto
FormList Property Ring9MapMarkers Auto
FormList Property Ring10MapMarkers Auto
FormList Property Ring11MapMarkers Auto

; Next destination zone index (within current ring) - set by travel dialog or map selection
Int Property NextDestinationZoneIndex = -1 Auto Hidden

; Optional: message to show when player selects a site on the planet map (e.g. "Travel here with Sir and Monsieur?"). Set in CK.
Message Property TravelConfirmMessage Auto

FormList Function GetMapMarkersForRing(Int ringIndex)
    If ringIndex == 0
        Return Ring0MapMarkers
    ElseIf ringIndex == 1
        Return Ring1MapMarkers
    ElseIf ringIndex == 2
        Return Ring2MapMarkers
    ElseIf ringIndex == 3
        Return Ring3MapMarkers
    ElseIf ringIndex == 4
        Return Ring4MapMarkers
    ElseIf ringIndex == 5
        Return Ring5MapMarkers
    ElseIf ringIndex == 6
        Return Ring6MapMarkers
    ElseIf ringIndex == 7
        Return Ring7MapMarkers
    ElseIf ringIndex == 8
        Return Ring8MapMarkers
    ElseIf ringIndex == 9
        Return Ring9MapMarkers
    ElseIf ringIndex == 10
        Return Ring10MapMarkers
    ElseIf ringIndex == 11
        Return Ring11MapMarkers
    EndIf
    Return None
EndFunction

; Enable and discover map markers for the current ring so they appear on the planet map.
Function RefreshMarkersForCurrentRing()
    If RingBuilderQuest == None
        Return
    EndIf
    Int ring = RingBuilderQuest.GetCurrentRing()
    FormList markers = GetMapMarkersForRing(ring)
    If markers == None
        ; Fallback: zone refs might be map markers or have linked map markers
        FormList zoneRefs = RingBuilderQuest.GetZoneRefsForRing(ring)
        If zoneRefs != None
            Int i = 0
            While i < zoneRefs.GetSize()
                ObjectReference ref = zoneRefs.GetAt(i) as ObjectReference
                If ref != None
                    EnableAndDiscoverMarker(ref)
                EndIf
                i += 1
            EndWhile
        EndIf
        Return
    EndIf
    Int j = 0
    While j < markers.GetSize()
        ObjectReference m = markers.GetAt(j) as ObjectReference
        If m != None
            EnableAndDiscoverMarker(m)
        EndIf
        j += 1
    EndWhile
    Debug.Trace("FieldFieldRingBuilderMapManager: Refreshed markers for ring " + ring)
EndFunction

Function EnableAndDiscoverMarker(ObjectReference mapMarker)
    If mapMarker == None
        Return
    EndIf
    If mapMarker.IsDisabled()
        mapMarker.EnableNoWait()
    EndIf
    mapMarker.SetMarkerDiscovered()
    mapMarker.OnMapMarkerDiscovered()
    mapMarker.SetMarkerVisibleOnStarMap()
EndFunction

; Set next destination by zone index (within current ring). Call from dialog/terminal.
Function SetNextDestination(Int zoneIndex)
    NextDestinationZoneIndex = zoneIndex
    Debug.Trace("FieldFieldRingBuilderMapManager: Next destination zone " + zoneIndex)
EndFunction

; Get the zone travel place description for a zone (current ring, zone index). Use in travel dialog; if zone has ZoneData and description set, returns it else empty or default.
String Function GetPlaceDescriptionForZone(Int zoneIndex)
    If RingBuilderQuest == None
        Return ""
    EndIf
    ObjectReference zoneRef = RingBuilderQuest.GetZoneRef(RingBuilderQuest.GetCurrentRing(), zoneIndex)
    If zoneRef == None
        Return ""
    EndIf
    FieldFieldRingBuilderZoneData zd = zoneRef as FieldFieldRingBuilderZoneData
    If zd != None && zd.ZoneTravelPlaceDescription != ""
        Return zd.ZoneTravelPlaceDescription
    EndIf
    Return ""
EndFunction

Int Function GetNextDestinationZoneIndex()
    Return NextDestinationZoneIndex
EndFunction

; Call when player confirms travel (e.g. from "Travel here with Sir and Monsieur?" dialog).
; Advances quest to that zone; caller is responsible for MoveTo or load.
Function ConfirmTravelToNextDestination()
    If RingBuilderQuest == None || NextDestinationZoneIndex < 0
        Return
    EndIf
    Int ring = RingBuilderQuest.GetCurrentRing()
    ObjectReference dest = RingBuilderQuest.GetZoneRef(ring, NextDestinationZoneIndex)
    If dest != None
        RingBuilderQuest.SetCurrentZoneInRing(NextDestinationZoneIndex)
        Game.GetPlayer().MoveTo(dest)
        RingBuilderQuest.AdvanceTime(1.0)
    EndIf
    NextDestinationZoneIndex = -1
EndFunction

Event OnInit()
    RegisterForPlanetSiteSelectEvent()
    Debug.Trace("FieldFieldRingBuilderMapManager: Initialized, registered for PlanetSiteSelect")
EndEvent

; When player selects a landing site on the planet/surface map, resolve to zone index and set next destination; show optional message.
Event OnPlanetSiteSelectEvent(Location aSite)
    If RingBuilderQuest == None || aSite == None
        Return
    EndIf
    Int ring = RingBuilderQuest.GetCurrentRing()
    FormList zoneRefs = RingBuilderQuest.GetZoneRefsForRing(ring)
    If zoneRefs == None
        Return
    EndIf
    Int i = 0
    Int n = zoneRefs.GetSize()
    While i < n
        ObjectReference zref = zoneRefs.GetAt(i) as ObjectReference
        If zref != None && zref.GetCurrentLocation() == aSite
            SetNextDestination(i)
            If TravelConfirmMessage != None
                TravelConfirmMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            EndIf
            Debug.Trace("FieldFieldRingBuilderMapManager: Planet site selected -> zone " + i)
            Return
        EndIf
        i += 1
    EndWhile
EndEvent
