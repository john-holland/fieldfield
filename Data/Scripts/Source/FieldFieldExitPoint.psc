Scriptname FieldFieldExitPoint extends ObjectReference

; FieldField Exit Point Configuration Script
; Defines configurable exit point destinations
; Manages exit point properties (location, rotation, cell)
; Supports both static locations and dynamic references
; Handles exit point validation and error checking

ObjectReference Property DestinationRef Auto
Cell Property DestinationCell Auto
Float Property DestinationX = 0.0 Auto
Float Property DestinationY = 0.0 Auto
Float Property DestinationZ = 0.0 Auto
Float Property DestinationAngleZ = 0.0 Auto
String Property ExitPointName = "" Auto

; Validate exit point configuration
Bool Function Validate()
    ; Check if we have a valid destination
    If DestinationRef != None
        Return True
    EndIf
    
    If DestinationCell != None && (DestinationX != 0.0 || DestinationY != 0.0 || DestinationZ != 0.0)
        Return True
    EndIf
    
    Debug.Trace("FieldFieldExitPoint: Invalid exit point configuration")
    Return False
EndFunction

; Get destination ObjectReference for teleport
ObjectReference Function GetDestination()
    If DestinationRef != None
        Return DestinationRef
    EndIf
    
    ; If using coordinates, we'd need to create a temporary marker
    ; For now, return None if no reference is set
    Return None
EndFunction

; Get rotation angle for player on arrival
Float Function GetRotation()
    Return DestinationAngleZ
EndFunction

; Get display name
String Function GetName()
    If ExitPointName != ""
        Return ExitPointName
    EndIf
    
    If DestinationRef != None
        Return "Exit Point at " + DestinationRef
    EndIf
    
    Return "Unnamed Exit Point"
EndFunction

