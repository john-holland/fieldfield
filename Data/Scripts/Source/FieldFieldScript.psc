Scriptname FieldFieldScript extends Quest

; FieldField mod - Main Quest Script
; Manages mod initialization and global state
; Tracks player location (ship interior vs. land)
; Handles automatic hatch detection
; Coordinates hatch activation logic

FieldFieldHatchManager Property HatchManager Auto
FieldFieldHatchScanner Property HatchScanner Auto
FieldFieldShipGraph Property ShipGraph Auto

Event OnInit()
    Debug.Trace("FieldField: Mod initialized!")
    
    ; Initialize components
    InitializeHatchManager()
    InitializeHatchScanner()
    InitializeShipGraph()
    UpdateShipGraphContext()
    
    ; Register for player location change events
    RegisterForPlayerLocationChange()
    
    Debug.Notification("FieldField mod initialized!")
EndEvent

Event OnPlayerLoadGame()
    Debug.Trace("FieldField: Save loaded, refreshing ship graph context")
    UpdateShipGraphContext()
EndEvent

Function InitializeHatchManager()
    ; HatchManager should be set via Creation Kit properties
    If HatchManager == None
        Debug.Trace("FieldField: Warning - HatchManager not set!")
    EndIf
EndFunction

Function InitializeHatchScanner()
    ; HatchScanner should be set via Creation Kit properties
    If HatchScanner == None
        Debug.Trace("FieldField: Warning - HatchScanner not set!")
    EndIf
EndFunction

Function InitializeShipGraph()
    ; ShipGraph should be set via Creation Kit properties
    If ShipGraph == None
        Debug.Trace("FieldField: Warning - ShipGraph not set!")
    EndIf
EndFunction

Function RegisterForPlayerLocationChange()
    ; Register for events that indicate player location changes
    ; Note: Starfield may use different event registration - this is disabled for safety
    ; RegisterForCustomEvent(Game.GetPlayer(), "OnLocationChange")
    ; TODO: Implement proper location change event registration for Starfield
    Debug.Trace("FieldField: Location change registration disabled - needs Starfield-specific implementation")
EndFunction

; Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
;     ; Handle player location changes
;     ; Note: Disabled until proper Starfield event system is implemented
;     ; If akSender == Game.GetPlayer()
;     ;     Debug.Trace("FieldField: Player location changed from " + akOldLoc + " to " + akNewLoc)
;     ;     
;     ;     ; Update graph context based on location
;     ;     If ShipGraph != None
;     ;         Bool isInterior = IsShipInterior(akNewLoc)
;     ;         ShipGraph.SetContext(isInterior)
;     ;     EndIf
;     ;     
;     ;     ; Scan for hatches in new location if it's a ship interior
;     ;     If IsShipInterior(akNewLoc)
;     ;         ScanForHatches(akNewLoc)
;     ;     EndIf
;     ; EndIf
; EndEvent

Bool Function IsShipInterior(Location loc)
    Actor playerRef = Game.GetPlayer()
    If playerRef == None
        Return False
    EndIf

    If playerRef.GetCurrentShipRef() == None
        Return False
    EndIf

    Cell playerCell = playerRef.GetParentCell()
    Return playerCell != None && playerCell.IsInterior()
EndFunction

Function ScanForHatches(Location loc)
    ; Trigger hatch scanning in the current location
    If HatchScanner != None && HatchManager != None
        UpdateShipGraphContext()
        Debug.Trace("FieldField: Scanning for hatches in location: " + loc)
        HatchScanner.ScanLocationForHatches(loc)
    EndIf
EndFunction

; Property button function - scans current player location for hatches
Function ScanCurrentLocation()
    UpdateShipGraphContext()
    Location currentLoc = Game.GetPlayer().GetCurrentLocation()
    If currentLoc != None
        Debug.Trace("FieldField: Property button - Scanning current location: " + currentLoc)
        ScanForHatches(currentLoc)
        Debug.Notification("FieldField: Scanning current location for hatches")
    Else
        ; Fallback: scan current cell
        Cell currentCell = Game.GetPlayer().GetParentCell()
        If currentCell != None && HatchScanner != None
            Debug.Trace("FieldField: Property button - Scanning current cell: " + currentCell)
            HatchScanner.ScanCellForHatches(currentCell)
            Debug.Notification("FieldField: Scanning current cell for hatches")
        Else
            Debug.Trace("FieldField: Property button - No location or cell available")
            Debug.Notification("FieldField: No location available to scan")
        EndIf
    EndIf
EndFunction

Function UpdateShipGraphContext()
    If ShipGraph == None
        Return
    EndIf

    Actor playerRef = Game.GetPlayer()
    If playerRef == None
        Return
    EndIf

    Bool isInterior = IsShipInterior(playerRef.GetCurrentLocation())
    ShipGraph.SetContext(isInterior)
EndFunction
