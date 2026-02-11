Scriptname FieldFieldDungeonCrawlUI extends Quest

; FieldField Dungeon Crawl - UI character card slots.
; Reserve N slots for render targets; each slot shows an actor in a render zone (animated card).
; Script interface: SetSlotActor, RefreshSlot. Actual render target binding is CK/SFSE-dependent.
; When API allows: assign which actor is in which slot; refresh when party changes.

Int Property SlotCount = 6 Auto
ReferenceAlias[] Property SlotAliases Auto
RefCollectionAlias Property PartyMembers Auto

; Slot 0 = player by default; 1..N-1 = companions. Fill via aliases or SetSlotActor.
Actor[] SlotActors

Event OnInit()
    SlotActors = new Actor[SlotCount]
    Int i = 0
    While i < SlotCount
        SlotActors[i] = None
        i += 1
    EndWhile
    Debug.Trace("FieldFieldDungeonCrawlUI: Initialized with " + SlotCount + " slots")
EndEvent

; Assign an actor to a slot (e.g. player or companion). Call RefreshSlot to update the card.
Function SetSlotActor(Int slot, Actor akActor)
    If slot < 0 || slot >= SlotCount
        Return
    EndIf
    If slot >= SlotActors.Length
        Return
    EndIf
    SlotActors[slot] = akActor
    If SlotAliases != None && slot < SlotAliases.Length && SlotAliases[slot] != None
        SlotAliases[slot].ForceRefTo(akActor)
    EndIf
    Debug.Trace("FieldFieldDungeonCrawlUI: Slot " + slot + " set to " + akActor)
EndFunction

; Refresh the given slot (e.g. after moving actor to render zone or changing appearance).
Function RefreshSlot(Int slot)
    If slot < 0 || slot >= SlotCount
        Return
    EndIf
    ; When render target API is available: trigger re-render or update texture for this slot
    ; For now this is a no-op; override or extend when API exists
    Debug.Trace("FieldFieldDungeonCrawlUI: RefreshSlot " + slot)
EndFunction

; Refresh all slots
Function RefreshAllSlots()
    Int s = 0
    While s < SlotCount
        RefreshSlot(s)
        s += 1
    EndWhile
EndFunction

; Get actor currently in slot
Actor Function GetSlotActor(Int slot)
    If slot < 0 || slot >= SlotCount || slot >= SlotActors.Length
        Return None
    EndIf
    Return SlotActors[slot]
EndFunction

; Optional: fill slots from PartyMembers (0 = player, 1.. = collection)
Function FillSlotsFromParty()
    Actor player = Game.GetPlayer()
    If player != None
        SetSlotActor(0, player)
    EndIf
    If PartyMembers != None
        Int idx = 1
        Int count = PartyMembers.GetCount()
        While idx < SlotCount && idx <= count
            Actor member = PartyMembers.GetAt(idx - 1) as Actor
            If member != None
                SetSlotActor(idx, member)
            EndIf
            idx += 1
        EndWhile
    EndIf
    RefreshAllSlots()
EndFunction
