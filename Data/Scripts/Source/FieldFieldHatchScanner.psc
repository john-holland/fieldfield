Scriptname FieldFieldHatchScanner extends Quest

; FieldField Animation-Based Hatch Scanner
; Scans objects for door-like animations
; Maintains search list of potential door animation actions
; Produces list of "potential hatch objects"
; Filters objects based on animation patterns

String[] Property DoorAnimationPatterns Auto
Float Property MinAnimationMatchScore = 0.5 Auto

ObjectReference[] PotentialHatches
Float[] MatchScores

Event OnInit()
    Debug.Trace("FieldFieldHatchScanner: Initialized")
    PotentialHatches = new ObjectReference[0]
    MatchScores = new Float[0]
    
    ; Initialize default animation patterns if not set
    If DoorAnimationPatterns.Length == 0
        InitializeDefaultPatterns()
    EndIf
EndEvent

Function InitializeDefaultPatterns()
    DoorAnimationPatterns = new String[15]
    DoorAnimationPatterns[0] = "Open"
    DoorAnimationPatterns[1] = "Close"
    DoorAnimationPatterns[2] = "HatchOpen"
    DoorAnimationPatterns[3] = "HatchClose"
    DoorAnimationPatterns[4] = "DoorOpen"
    DoorAnimationPatterns[5] = "DoorClose"
    DoorAnimationPatterns[6] = "Unlock"
    DoorAnimationPatterns[7] = "Lock"
    DoorAnimationPatterns[8] = "Activate"
    DoorAnimationPatterns[9] = "Deactivate"
    DoorAnimationPatterns[10] = "OpenFast"
    DoorAnimationPatterns[11] = "OpenSlow"
    DoorAnimationPatterns[12] = "CloseFast"
    DoorAnimationPatterns[13] = "CloseSlow"
    DoorAnimationPatterns[14] = "Play01"
EndFunction

; Scan a cell for potential hatches
Function ScanCellForHatches(Cell targetCell)
    If targetCell == None
        Debug.Trace("FieldFieldHatchScanner: Cannot scan - cell is None")
        Return
    EndIf
    
    Debug.Trace("FieldFieldHatchScanner: Scanning cell " + targetCell + " for hatches")
    
    ; Clear previous results
    PotentialHatches = new ObjectReference[0]
    MatchScores = new Float[0]
    
    ; Get all references in the cell
    ; Note: This may need to be adjusted based on actual Starfield API
    ; For now, this is a placeholder - actual implementation depends on available functions
    
    ; Would iterate through objects and check animations
    ; ObjectReference[] cellRefs = GetCellReferences(targetCell)
    ; For each ref, check animations and score
    
    Debug.Trace("FieldFieldHatchScanner: Scan complete. Found " + PotentialHatches.Length + " potential hatches")
EndFunction

; Scan a location for potential hatches
Function ScanLocationForHatches(Location loc)
    If loc == None
        Return
    EndIf
    
    ; Get cells in location and scan each
    ; This is a placeholder - actual implementation depends on available API
    Debug.Trace("FieldFieldHatchScanner: Scanning location " + loc + " for hatches")
EndFunction

; Property button function - scans current player location/cell for hatches
Function ScanCurrentLocationButton()
    ; Try location first
    Location currentLoc = Game.GetPlayer().GetCurrentLocation()
    If currentLoc != None
        Debug.Trace("FieldFieldHatchScanner: Property button - Scanning location: " + currentLoc)
        ScanLocationForHatches(currentLoc)
        Debug.Notification("FieldField: Scanning location for hatches")
    Else
        ; Fallback to cell
        Cell currentCell = Game.GetPlayer().GetParentCell()
        If currentCell != None
            Debug.Trace("FieldFieldHatchScanner: Property button - Scanning cell: " + currentCell)
            ScanCellForHatches(currentCell)
            Debug.Notification("FieldField: Scanning cell for hatches")
        Else
            Debug.Trace("FieldFieldHatchScanner: Property button - No location or cell available")
            Debug.Notification("FieldField: No location/cell available")
        EndIf
    EndIf
EndFunction

; Check if object has door-like animations
Bool Function CheckObjectAnimations(ObjectReference obj)
    If obj == None
        Return False
    EndIf
    
    ; Calculate match score
    Float score = CalculateMatchScore(obj, DoorAnimationPatterns)
    
    Return score >= MinAnimationMatchScore
EndFunction

; Calculate match score for an object
Float Function CalculateMatchScore(ObjectReference obj, String[] patterns)
    If obj == None || patterns.Length == 0
        Return 0.0
    EndIf
    
    Float score = 0.0
    Float maxScore = 0.0
    
    ; Check object form ID/type (hatch-like objects get bonus)
    ; This would need actual form ID checks based on Starfield's object types
    
    ; Check for animation pattern matches
    ; Note: We may not be able to enumerate animations directly
    ; This would need to test if animations exist by trying to play them
    ; or use available API to query animation names
    
    ; For now, use object name/type as heuristic
    String objName = obj.GetDisplayName()
    If objName == ""
        objName = obj.GetBaseObject().GetName()
    EndIf
    
    ; Check if name contains hatch/door keywords
    String lowerName = StringUtil.ToLower(objName)
    If StringUtil.Find(lowerName, "hatch") >= 0
        score += 0.5
        maxScore += 0.5
    EndIf
    If StringUtil.Find(lowerName, "door") >= 0
        score += 0.3
        maxScore += 0.3
    EndIf
    If StringUtil.Find(lowerName, "exit") >= 0
        score += 0.4
        maxScore += 0.4
    EndIf
    
    ; Normalize score
    If maxScore > 0.0
        Return score / maxScore
    EndIf
    
    Return 0.0
EndFunction

; Get list of potential hatches
ObjectReference[] Function GetPotentialHatches()
    Return PotentialHatches
EndFunction

; Filter hatches by confidence score
ObjectReference[] Function FilterHatchesByConfidence(Float minScore)
    ObjectReference[] filtered = new ObjectReference[0]
    
    Int i = 0
    While i < PotentialHatches.Length
        If i < MatchScores.Length && MatchScores[i] >= minScore
            filtered.Add(PotentialHatches[i])
        EndIf
        i += 1
    EndWhile
    
    Return filtered
EndFunction

; Add a potential hatch with score
Function AddPotentialHatch(ObjectReference hatch, Float score)
    If hatch == None
        Return
    EndIf
    
    PotentialHatches.Add(hatch)
    MatchScores.Add(score)
    
    Debug.Trace("FieldFieldHatchScanner: Added potential hatch " + hatch + " with score " + score)
EndFunction

