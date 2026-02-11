Scriptname FieldFieldGroupTacticsQuest extends Quest

; FieldField Group Tactics (Snowfield) - Main controller Quest.
; Cadre (party), current character/ability selection, ability state (cooldowns, counters) with serialization.
; Input: OnSelectCharacter(index), OnActivateAbility(). Integration: OnNodeEntered(nodeID) for pack/teleport.

RefCollectionAlias Property Cadre Auto
FieldFieldGroupTacticsAbilities Property Abilities Auto
FieldFieldGroupTacticsFormation Property Formation Auto
FieldFieldDungeonCrawlPathfinding Property Pathfinding Auto
FieldFieldDungeonCrawlUI Property PortraitSlots Auto
GlobalVariable Property SnowfieldModeActive Auto
ActorValue Property Health Auto

Int Property MaxCadreSize = 6 Auto
Int Property AbilityCount = 8 Auto
Float Property CadreHealthBonus = 500.0 Auto
Float Property DefaultCooldownSeconds = 10.0 Auto

Int Property CurrentCharacterIndex = 0 Auto Hidden
Int Property CurrentAbilityIndex = 0 Auto Hidden
Float[] CooldownEndTime
Int[] CounterRemaining
Int[] CounterMax
Bool Property IsSnowfieldMode = False Auto Hidden

; Ability indices for serialization
Int Const ABILITY_ATTACK = 0
Int Const ABILITY_HEAL = 1
Int Const ABILITY_CALL_TO_ARMS = 2
Int Const ABILITY_FORCE_POWER = 3
Int Const ABILITY_ROBOT_POWER_ATTACK = 4
Int Const ABILITY_APOLOGIZE = 5
Int Const ABILITY_GUARD = 6
Int Const ABILITY_CALL_FOR_HELP = 7

Event OnInit()
    Debug.Trace("FieldFieldGroupTacticsQuest: Initialized")
    InitializeAbilityState()
EndEvent

Function InitializeAbilityState()
    Int total = MaxCadreSize * AbilityCount
    CooldownEndTime = new Float[total]
    CounterRemaining = new Int[total]
    CounterMax = new Int[total]
    Int i = 0
    While i < total
        CooldownEndTime[i] = 0.0
        CounterRemaining[i] = 3
        CounterMax[i] = 3
        i += 1
    EndWhile
EndFunction

; Index into flat arrays
Int Function GetStateIndex(Int characterIndex, Int abilityIndex)
    Return characterIndex * AbilityCount + abilityIndex
EndFunction

Float Function GetCooldownEndTime(Int characterIndex, Int abilityIndex)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx < 0 || idx >= CooldownEndTime.Length
        Return 0.0
    EndIf
    Return CooldownEndTime[idx]
EndFunction

Function SetCooldownEndTime(Int characterIndex, Int abilityIndex, Float endTime)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx >= 0 && idx < CooldownEndTime.Length
        CooldownEndTime[idx] = endTime
    EndIf
EndFunction

Int Function GetCounterRemaining(Int characterIndex, Int abilityIndex)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx < 0 || idx >= CounterRemaining.Length
        Return 0
    EndIf
    Return CounterRemaining[idx]
EndFunction

Function SetCounterRemaining(Int characterIndex, Int abilityIndex, Int value)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx >= 0 && idx < CounterRemaining.Length
        CounterRemaining[idx] = value
    EndIf
EndFunction

Int Function GetCounterMax(Int characterIndex, Int abilityIndex)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx < 0 || idx >= CounterMax.Length
        Return 3
    EndIf
    Return CounterMax[idx]
EndFunction

Bool Function IsAbilityOnCooldown(Int characterIndex, Int abilityIndex)
    Float endTime = GetCooldownEndTime(characterIndex, abilityIndex)
    Return endTime > 0.0 && Utility.GetCurrentGameTime() < endTime
EndFunction

Bool Function CanUseAbility(Int characterIndex, Int abilityIndex)
    If IsAbilityOnCooldown(characterIndex, abilityIndex)
        Return False
    EndIf
    Int counter = GetCounterRemaining(characterIndex, abilityIndex)
    Return counter > 0
EndFunction

; --- Cadre ---
Int Function GetCadreCount()
    If Cadre == None
        Return 0
    EndIf
    Return Cadre.GetCount()
EndFunction

Actor Function GetCadreMember(Int index)
    If Cadre == None || index < 0 || index >= Cadre.GetCount()
        Return None
    EndIf
    Return Cadre.GetAt(index) as Actor
EndFunction

; Apply health bonus to cadre (call when entering Snowfield mode)
Function ApplyCadreHealthBonus()
    Int n = GetCadreCount()
    Int i = 0
    While i < n
        Actor a = GetCadreMember(i)
        If a != None
            a.ModValue(Health, CadreHealthBonus)
        EndIf
        i += 1
    EndWhile
    Debug.Trace("FieldFieldGroupTacticsQuest: Applied health bonus to " + n + " cadre members")
EndFunction

; --- Input ---
Function OnSelectCharacter(Int index)
    If index < 0 || index >= GetCadreCount()
        Return
    EndIf
    CurrentCharacterIndex = index
    ; If more than one ability per character, next press could cycle ability; for now single ability index
    Debug.Trace("FieldFieldGroupTacticsQuest: Selected character " + index)
EndFunction

; Cycle ability for current character (number key pressed again)
Function OnCycleAbility()
    CurrentAbilityIndex = (CurrentAbilityIndex + 1) % AbilityCount
    Debug.Trace("FieldFieldGroupTacticsQuest: Cycled to ability " + CurrentAbilityIndex)
EndFunction

Function OnActivateAbility()
    Actor caster = GetCadreMember(CurrentCharacterIndex)
    If caster == None
        Return
    EndIf
    If !CanUseAbility(CurrentCharacterIndex, CurrentAbilityIndex)
        Debug.Notification("Ability on cooldown or no uses left.")
        Return
    EndIf
    If Abilities != None
        Abilities.ExecuteAbility(CurrentCharacterIndex, CurrentAbilityIndex, caster, Self)
    EndIf
EndFunction

; Called when dungeon crawl controller enters a node (Snowfield mode: cancel pathfind, teleport to packed)
ObjectReference Property CurrentNodeMarker Auto Hidden

Function OnNodeEntered(Int nodeID)
    If Pathfinding == None
        Return
    EndIf
    ObjectReference marker = Pathfinding.GetNodeMarker(nodeID)
    If marker == None
        Return
    EndIf
    CurrentNodeMarker = marker
    CancelCadrePathfinding()
    If Formation != None
        TeleportCadreToPackedPositions(marker)
    EndIf
    ; Sync portrait slots to cadre
    If PortraitSlots != None
        Int n = GetCadreCount()
        Int s = 0
        While s < n
            PortraitSlots.SetSlotActor(s, GetCadreMember(s))
            s += 1
        EndWhile
        PortraitSlots.RefreshAllSlots()
    EndIf
    Debug.Trace("FieldFieldGroupTacticsQuest: OnNodeEntered " + nodeID + ", cadre packed")
EndFunction

Function TeleportCadreToPackedPositions(ObjectReference nodeMarker)
    If Formation == None || nodeMarker == None
        Return
    EndIf
    Int n = GetCadreCount()
    Formation.GetPackedPositions(nodeMarker, n)
    If Formation.PackedPositionsX.Length < n
        Return
    EndIf
    Int i = 0
    While i < n
        Actor a = GetCadreMember(i)
        If a != None
            a.SetPosition(Formation.PackedPositionsX[i], Formation.PackedPositionsY[i], Formation.PackedPositionsZ[i])
        EndIf
        i += 1
    EndWhile
EndFunction

; Cancel pathfinding for all cadre (e.g. before teleport)
Function CancelCadrePathfinding()
    Int n = GetCadreCount()
    Int i = 0
    While i < n
        Actor a = GetCadreMember(i)
        If a != None
            a.EvaluatePackage(False)
        EndIf
        i += 1
    EndWhile
EndFunction

; Called by Abilities script after use to update cooldown/counter
; cooldownDuration in seconds (converted to game time for storage)
Function ConsumeAbilityUse(Int characterIndex, Int abilityIndex, Float cooldownDurationSeconds)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx < 0 || idx >= CounterRemaining.Length
        Return
    EndIf
    Int remaining = CounterRemaining[idx] - 1
    CounterRemaining[idx] = remaining
    Float cooldownDays = cooldownDurationSeconds / 86400.0
    Float endTime = Utility.GetCurrentGameTime() + cooldownDays
    CooldownEndTime[idx] = endTime
EndFunction

Function RefillCounter(Int characterIndex, Int abilityIndex)
    Int idx = GetStateIndex(characterIndex, abilityIndex)
    If idx >= 0 && idx < CounterMax.Length
        CounterRemaining[idx] = CounterMax[idx]
    EndIf
EndFunction

; For UI: cooldown progress 0.0 (just used) to 1.0 (ready). Uses stored end time; duration inferred from now->end.
Float Function GetCooldownProgress(Int characterIndex, Int abilityIndex)
    Float endTime = GetCooldownEndTime(characterIndex, abilityIndex)
    If endTime <= 0.0
        Return 1.0
    EndIf
    Float now = Utility.GetCurrentGameTime()
    If now >= endTime
        Return 1.0
    EndIf
    Float startTime = endTime - (DefaultCooldownSeconds / 86400.0)
    Float duration = endTime - startTime
    Float remaining = endTime - now
    Float progress = 1.0 - (remaining / duration)
    If progress < 0.0
        progress = 0.0
    EndIf
    If progress > 1.0
        progress = 1.0
    EndIf
    Return progress
EndFunction
