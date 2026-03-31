Scriptname FieldFieldRingBuilderZoneData extends ObjectReference

; Zone node for the ring linked list. Attach to a ref that is in the ring's zone FormList (order = list order).
; This ref is the start position unless StartPositionOverride is set.

; Start position for this zone (default: self)
ObjectReference Property StartPositionOverride Auto

; Optional: NPCs and enemies for this zone (FormLists of refs or base forms; fill in CK)
FormList Property ZoneNPCs Auto
FormList Property ZoneEnemies Auto

; Associated quests: when zone is entered, these can be started or advanced
Quest Property AssociatedQuest1 Auto
Quest Property AssociatedQuest2 Auto
Int Property AssociatedQuest1Stage = 10 Auto
Int Property AssociatedQuest2Stage = 10 Auto

; Cross-ring link (optional): next zone in another ring for supply chain / east-west
ObjectReference Property CrossRingNextRef Auto

; Is this zone the city zone (omnicap)? Only one per save should be true.
Bool Property IsCityZone = False Auto

; For omnicap report: does this zone have an entrance and exit (connection)?
Bool Property HasEntrance = False Auto
Bool Property HasExit = False Auto

; Zone travel place description (modifiable in editor). Shown when player selects this zone for travel (e.g. "Travel here with Sir and Monsieur?").
String Property ZoneTravelPlaceDescription = "" Auto

; Farey quest tree node for this zone: the Quest in the tree whose children are this zone's active quests. Set in CK.
Quest Property FareyZoneNodeQuest Auto

; Return the list of active (non-completed) quests for this zone from the Farey tree. Uses tree.GetChildQuests(FareyZoneNodeQuest).
FormList Function GetZoneQuests(FieldFieldFareyQuestTree tree)
    If tree == None || FareyZoneNodeQuest == None
        Return None
    EndIf
    Return tree.GetChildQuests(FareyZoneNodeQuest)
EndFunction

ObjectReference Function GetStartPosition()
    If StartPositionOverride != None
        Return StartPositionOverride
    EndIf
    Return self
EndFunction

; Call when player enters this zone (e.g. from placement volume or trigger).
Function OnPlayerEnteredZone()
    If AssociatedQuest1 != None && AssociatedQuest1Stage > 0
        AssociatedQuest1.SetStage(AssociatedQuest1Stage)
    EndIf
    If AssociatedQuest2 != None && AssociatedQuest2Stage > 0
        AssociatedQuest2.SetStage(AssociatedQuest2Stage)
    EndIf
EndFunction
