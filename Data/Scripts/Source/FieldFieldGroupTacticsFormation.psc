Scriptname FieldFieldGroupTacticsFormation extends Quest

; FieldField Group Tactics - Packed positions and ability-use slot positions from node marker.
; Tight circle around centroid (shoulder to shoulder); ability slots as offsets for football-schematic layout.

Float Property PackedRadius = 75.0 Auto
Float Property AbilitySlotRadius = 120.0 Auto

; Output arrays (filled by GetPackedPositions) - exposed for Quest reader
Float[] Property PackedPositionsX Auto Hidden
Float[] Property PackedPositionsY Auto Hidden
Float[] Property PackedPositionsZ Auto Hidden

; Fill PackedPositionsX/Y/Z with positions around nodeMarker for count actors (circle in X/Y, same Z)
Function GetPackedPositions(ObjectReference nodeMarker, Int count)
    If nodeMarker == None || count <= 0
        PackedPositionsX = new Float[0]
        PackedPositionsY = new Float[0]
        PackedPositionsZ = new Float[0]
        Return
    EndIf
    Float cx = nodeMarker.GetPositionX()
    Float cy = nodeMarker.GetPositionY()
    Float cz = nodeMarker.GetPositionZ()
    PackedPositionsX = new Float[count]
    PackedPositionsY = new Float[count]
    PackedPositionsZ = new Float[count]
    Float angleStep = 360.0 / count
    Int i = 0
    While i < count
        Float angle = angleStep * i * 0.01745329
        PackedPositionsX[i] = cx + PackedRadius * Math.cos(angle)
        PackedPositionsY[i] = cy + PackedRadius * Math.sin(angle)
        PackedPositionsZ[i] = cz
        i += 1
    EndWhile
EndFunction

; Get ability-use slot position for character index (offset from node centroid)
Function GetAbilitySlotPosition(ObjectReference nodeMarker, Int characterIndex, Int totalSlots)
    ; Return as three floats via properties; caller reads Formation.AbilitySlotX etc after call
    ; Single slot: store in first element of small arrays
    If nodeMarker == None
        Return
    EndIf
    Float cx = nodeMarker.GetPositionX()
    Float cy = nodeMarker.GetPositionY()
    Float cz = nodeMarker.GetPositionZ()
    Float angleStep = 360.0 / totalSlots
    Float angle = angleStep * characterIndex * 0.01745329
    AbilitySlotX = cx + AbilitySlotRadius * Math.cos(angle)
    AbilitySlotY = cy + AbilitySlotRadius * Math.sin(angle)
    AbilitySlotZ = cz
EndFunction

Float Property AbilitySlotX Auto Hidden
Float Property AbilitySlotY Auto Hidden
Float Property AbilitySlotZ Auto Hidden
