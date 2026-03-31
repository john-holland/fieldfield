Scriptname FieldFieldHatchManager extends Quest

; FieldField Hatch Manager
; Maintains registry of exit hatches (auto-detected + manually configured)
; Handles hatch activation events
; Manages teleport destinations
; Tracks hatch state (open/closed)
; Coordinates exit point automatic placement with ShipGraph

FieldFieldHatchScanner Property HatchScanner Auto
FieldFieldShipGraph Property ShipGraph Auto
FormList Property HatchList Auto
FormList Property ExitPointList Auto

ObjectReference[] RegisteredHatches
ObjectReference[] RegisteredExitPoints

Event OnInit()
    Debug.Trace("FieldFieldHatchManager: Initialized")
    RegisteredHatches = new ObjectReference[0]
    RegisteredExitPoints = new ObjectReference[0]
EndEvent

; Register a hatch (called by scanner or manual registration)
Function RegisterHatch(ObjectReference hatch)
    If hatch == None
        Return
    EndIf
    
    ; Check if already registered
    Int index = RegisteredHatches.Find(hatch)
    If index >= 0
        Debug.Trace("FieldFieldHatchManager: Hatch already registered: " + hatch)
        Return
    EndIf
    
    ; Add to array
    RegisteredHatches.Add(hatch)
    
    ; Add to FormList if available
    If HatchList != None
        HatchList.AddForm(hatch.GetBaseObject())
    EndIf
    
    ; Associate hatch to graph and place exit point
    If ShipGraph != None
        Bool isInterior = ShipGraph.GetContext() == 1
        Cell hatchCell = hatch.GetParentCell()
        If hatchCell != None && hatchCell.IsInterior()
            isInterior = True
        EndIf
        ShipGraph.AssociateHatchToGraph(hatch, isInterior)
        
        ; Automatically place exit point at corresponding graph node
        ObjectReference exitPoint = ShipGraph.PlaceExitPointForHatch(hatch, isInterior)
        If exitPoint != None
            RegisterExitPoint(exitPoint)
        EndIf
    EndIf
    
    Debug.Trace("FieldFieldHatchManager: Registered hatch: " + hatch)
EndFunction

; Register an exit point
Function RegisterExitPoint(ObjectReference exitPoint)
    If exitPoint == None
        Return
    EndIf
    
    ; Check if already registered
    Int index = RegisteredExitPoints.Find(exitPoint)
    If index >= 0
        Return
    EndIf
    
    ; Add to array
    RegisteredExitPoints.Add(exitPoint)
    
    ; Add to FormList if available
    If ExitPointList != None
        ExitPointList.AddForm(exitPoint.GetBaseObject())
    EndIf
    
    Debug.Trace("FieldFieldHatchManager: Registered exit point: " + exitPoint)
EndFunction

; Get exit point for a hatch
ObjectReference Function GetExitPointForHatch(ObjectReference hatch)
    If hatch == None
        Debug.Trace("FieldFieldHatchManager: GetExitPointForHatch called with None hatch")
        Return None
    EndIf

    If !IsHatchRegistered(hatch)
        RegisterHatch(hatch)
    EndIf

    ; First check if ShipGraph has an auto-placed exit point
    If ShipGraph != None
        ObjectReference exitPoint = ShipGraph.GetExitPointForHatch(hatch)
        If IsValidExitPoint(exitPoint, hatch)
            Return exitPoint
        EndIf

        ; If none is cached yet, attempt placement now.
        Bool isInterior = ShipGraph.GetContext() == 1
        Cell hatchCell = hatch.GetParentCell()
        If hatchCell != None && hatchCell.IsInterior()
            isInterior = True
        EndIf

        exitPoint = ShipGraph.PlaceExitPointForHatch(hatch, isInterior)
        If IsValidExitPoint(exitPoint, hatch)
            RegisterExitPoint(exitPoint)
            Return exitPoint
        EndIf

        Debug.Trace("FieldFieldHatchManager: Could not resolve valid exit point for hatch " + hatch)
    Else
        Debug.Trace("FieldFieldHatchManager: ShipGraph not set, cannot resolve hatch exit for " + hatch)
    EndIf
    
    ; Check if hatch has a manually configured exit point
    ; This would be set via script properties on FieldFieldHatchRef
    Return None
EndFunction

Bool Function IsValidExitPoint(ObjectReference exitPoint, ObjectReference hatch)
    If exitPoint == None
        Return False
    EndIf

    If exitPoint.IsDisabled()
        Debug.Trace("FieldFieldHatchManager: Exit point disabled for hatch " + hatch)
        Return False
    EndIf

    Return True
EndFunction

; Place exit points for all registered hatches
Function PlaceExitPointsForHatches()
    If ShipGraph == None
        Debug.Trace("FieldFieldHatchManager: Cannot place exit points - ShipGraph not available")
        Return
    EndIf
    
    Debug.Trace("FieldFieldHatchManager: Placing exit points for " + RegisteredHatches.Length + " hatches")
    ShipGraph.AutoPlaceExitPointsForHatches()
EndFunction

; Get all registered hatches
ObjectReference[] Function GetRegisteredHatches()
    Return RegisteredHatches
EndFunction

; Get all registered exit points
ObjectReference[] Function GetRegisteredExitPoints()
    Return RegisteredExitPoints
EndFunction

; Check if a hatch is registered
Bool Function IsHatchRegistered(ObjectReference hatch)
    Return RegisteredHatches.Find(hatch) >= 0
EndFunction

; Property button function - scans current location and registers found hatches
Function ScanAndRegisterHatchesButton()
    Debug.Trace("FieldFieldHatchManager: Property button - Starting scan and registration")
    
    If HatchScanner == None
        Debug.Trace("FieldFieldHatchManager: HatchScanner not set!")
        Return
    EndIf
    
    ; Scan current location
    Location currentLoc = Game.GetPlayer().GetCurrentLocation()
    If currentLoc != None
        HatchScanner.ScanLocationForHatches(currentLoc)
    Else
        Cell currentCell = Game.GetPlayer().GetParentCell()
        If currentCell != None
            HatchScanner.ScanCellForHatches(currentCell)
        EndIf
    EndIf
    
    ; Get potential hatches and register them
    ObjectReference[] potentialHatches = HatchScanner.GetPotentialHatches()
    Int i = 0
    While i < potentialHatches.Length
        RegisterHatch(potentialHatches[i])
        i += 1
    EndWhile
    
    Debug.Notification("FieldField: Scanned and registered " + potentialHatches.Length + " hatches")
EndFunction

