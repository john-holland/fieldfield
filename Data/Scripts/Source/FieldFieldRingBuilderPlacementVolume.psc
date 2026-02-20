Scriptname FieldFieldRingBuilderPlacementVolume extends ObjectReference

; Procedural placement volume: bins and places buildings on XZ plane with padding.
; Hand-placed in CK. Category determines which spawn list is used; some buildings are quest-unique (tracked on quest).
; Categories: 0=Residential, 1=Factory, 2=Agriculture, 3=ZoneTransition, 4=SpecialCutscene

; Category for this volume (0..4). Determines which FormList is used if you use CategorySpawnLists.
Int Property VolumeCategory = 0 Auto

; Single spawn list (used when CategorySpawnLists not set): buildings/packins to place
FormList Property SpawnFormList Auto

; Optional: per-category spawn lists (FormList[5] or 5 FormList properties). If set, overrides SpawnFormList by VolumeCategory.
FormList Property Category0SpawnList Auto
FormList Property Category1SpawnList Auto
FormList Property Category2SpawnList Auto
FormList Property Category3SpawnList Auto
FormList Property Category4SpawnList Auto

; Grid: number of bins on X and Z (XZ plane only)
Int Property BinCountX = 4 Auto
Int Property BinCountZ = 4 Auto
Float Property Padding = 256.0 Auto
; Volume extent in X and Z (from center); total size = 2 * VolumeSizeX etc.
Float Property VolumeSizeX = 2000.0 Auto
Float Property VolumeSizeZ = 2000.0 Auto

; Quest that tracks time and quest-unique buildings (RefCollectionAlias "PlacedQuestBuildings" on that quest)
FieldFieldRingBuilderQuest Property RingBuilderQuest Auto
FormList Property QuestUniqueBuildingForms Auto
RefCollectionAlias Property PlacedQuestBuildingsAlias Auto

; Zone transition: link to next scene (door/NPC/ref). When player interacts, advance zone (handled by that ref/door script).
ObjectReference Property ZoneTransitionNextRef Auto

; Special cutscene: radio ref to enable when building is placed (optional)
ObjectReference Property SpecialCutsceneRadioRef Auto

Bool Property AlreadyFilled = False Auto Hidden

FormList Function GetEffectiveSpawnList()
    If VolumeCategory == 0 && Category0SpawnList != None
        Return Category0SpawnList
    ElseIf VolumeCategory == 1 && Category1SpawnList != None
        Return Category1SpawnList
    ElseIf VolumeCategory == 2 && Category2SpawnList != None
        Return Category2SpawnList
    ElseIf VolumeCategory == 3 && Category3SpawnList != None
        Return Category3SpawnList
    ElseIf VolumeCategory == 4 && Category4SpawnList != None
        Return Category4SpawnList
    EndIf
    Return SpawnFormList
EndFunction

Bool Function IsQuestUnique(Form baseForm)
    If QuestUniqueBuildingForms == None
        Return False
    EndIf
    Int i = 0
    While i < QuestUniqueBuildingForms.GetSize()
        If QuestUniqueBuildingForms.GetAt(i) == baseForm
            Return True
        EndIf
        i += 1
    EndWhile
    Return False
EndFunction

Bool Function AlreadyPlacedQuestBuilding(Form baseForm)
    If PlacedQuestBuildingsAlias == None
        Return False
    EndIf
    Int n = PlacedQuestBuildingsAlias.GetCount()
    Int j = 0
    While j < n
        ObjectReference ref = PlacedQuestBuildingsAlias.GetAt(j)
        If ref != None && ref.GetBaseObject() == baseForm
            Return True
        EndIf
        j += 1
    EndWhile
    Return False
EndFunction

; Pick a random form from the list that is either not quest-unique or not yet placed.
Form Function PickFormToPlace(FormList list)
    If list == None || list.GetSize() == 0
        Return None
    EndIf
    Int size = list.GetSize()
    Int attempts = 0
    While attempts < size * 2
        Int idx = Utility.RandomInt(0, size - 1)
        Form f = list.GetAt(idx)
        If f != None && (!IsQuestUnique(f) || !AlreadyPlacedQuestBuilding(f))
            Return f
        EndIf
        attempts += 1
    EndWhile
    Return None
EndFunction

Function RunPlacement()
    If AlreadyFilled
        Return
    EndIf
    FormList list = GetEffectiveSpawnList()
    If list == None || list.GetSize() == 0
        Debug.Trace("FieldFieldRingBuilderPlacementVolume: No spawn list for category " + VolumeCategory)
        AlreadyFilled = True
        Return
    EndIf

    Float cx = GetPositionX()
    Float cy = GetPositionY()
    Float cz = GetPositionZ()
    Float stepX = (2.0 * VolumeSizeX) / BinCountX
    Float stepZ = (2.0 * VolumeSizeZ) / BinCountZ
    Float halfStepX = stepX * 0.5
    Float halfStepZ = stepZ * 0.5
    Float minX = cx - VolumeSizeX
    Float minZ = cz - VolumeSizeZ

    Int placed = 0
    Int ix = 0
    While ix < BinCountX
        Int iz = 0
        While iz < BinCountZ
            Float px = minX + ix * stepX + halfStepX + (Utility.RandomFloat(-1.0, 1.0) * Padding * 0.5)
            Float pz = minZ + iz * stepZ + halfStepZ + (Utility.RandomFloat(-1.0, 1.0) * Padding * 0.5)
            Form toPlace = PickFormToPlace(list)
            If toPlace != None
                ObjectReference spawnRef = PlaceAtMe(toPlace, 1, False, False, True, None, None, True)
                If spawnRef != None
                    spawnRef.MoveTo(self, px - cx, 0.0, pz - cz)
                    If IsQuestUnique(toPlace) && PlacedQuestBuildingsAlias != None
                        PlacedQuestBuildingsAlias.AddRef(spawnRef)
                    EndIf
                    placed += 1
                EndIf
            EndIf
            iz += 1
        EndWhile
        ix += 1
    EndWhile

    If RingBuilderQuest != None
        RingBuilderQuest.AdvanceTime(0.0)
    EndIf
    If SpecialCutsceneRadioRef != None
        SpecialCutsceneRadioRef.EnableNoWait()
    EndIf
    AlreadyFilled = True
    Debug.Trace("FieldFieldRingBuilderPlacementVolume: Placed " + placed + " refs")
EndFunction

Event OnLoad()
    RunPlacement()
EndEvent

; Optional: also fill when player enters (if you prefer to defer placement until visited)
Event OnTriggerEnter(ObjectReference akActionRef)
    If akActionRef == Game.GetPlayer() && !AlreadyFilled
        RunPlacement()
    EndIf
EndEvent
