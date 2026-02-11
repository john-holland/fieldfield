Scriptname FieldFieldGroupTacticsAbilities extends Quest

; FieldField Group Tactics - Ability execution: Attack, Heal, Call to Arms, Force power, Robot power attack, Apologize, Guard, Call for Help.

FieldFieldGroupTacticsQuest Property TacticsQuest Auto
FieldFieldGroupTacticsFormation Property Formation Auto
Spell Property ForcePowerSpell Auto
Faction Property CallForHelpFaction Auto
Float Property RobotPowerAttackRadius = 2000.0 Auto
Float Property ApologizeRadius = 1500.0 Auto
Float Property CallForHelpRadius = 3000.0 Auto
Float Property DefaultCooldown = 10.0 Auto
Float Property GuardUpdateInterval = 0.8 Auto

; Execute ability by index. Caster = cadre member who activated.
Function ExecuteAbility(Int characterIndex, Int abilityIndex, Actor caster, FieldFieldGroupTacticsQuest quest)
    TacticsQuest = quest
    If caster == None || TacticsQuest == None
        Return
    EndIf
    If abilityIndex == 0
        ExecuteAttack(caster)
    ElseIf abilityIndex == 1
        ExecuteHeal(caster)
    ElseIf abilityIndex == 2
        ExecuteCallToArms(caster)
    ElseIf abilityIndex == 3
        ExecuteForcePower(caster)
    ElseIf abilityIndex == 4
        ExecuteRobotPowerAttack(caster)
    ElseIf abilityIndex == 5
        ExecuteApologize(caster)
    ElseIf abilityIndex == 6
        ExecuteGuard(caster)
    ElseIf abilityIndex == 7
        ExecuteCallForHelp(caster)
    EndIf
    TacticsQuest.ConsumeAbilityUse(characterIndex, abilityIndex, DefaultCooldown)
EndFunction

; Attack: use equipped weapon per Starfield rules
Function ExecuteAttack(Actor caster)
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    Actor target = player.GetCombatTarget()
    If target != None && !target.IsDead()
        caster.StartCombat(target)
    EndIf
    Debug.Notification("Attack!")
EndFunction

; Heal: restore health to self or ally
Function ExecuteHeal(Actor caster)
    Float healAmount = 100.0
    caster.RestoreValue(Health, healAmount)
    Debug.Notification("Heal!")
EndFunction

; Call to Arms: teleport all cadre to caster
Function ExecuteCallToArms(Actor caster)
    If TacticsQuest == None
        Return
    EndIf
    Int n = TacticsQuest.GetCadreCount()
    Int i = 0
    While i < n
        Actor a = TacticsQuest.GetCadreMember(i)
        If a != None && a != caster
            a.MoveTo(caster)
        EndIf
        i += 1
    EndWhile
    Debug.Notification("Call to Arms!")
EndFunction

ActorValue Property Health Auto

; Force power: configurable spell
Function ExecuteForcePower(Actor caster)
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    Actor target = player.GetCombatTarget()
    If ForcePowerSpell != None
        If target != None
            caster.Cast(ForcePowerSpell as Form, target)
        Else
            caster.Cast(ForcePowerSpell as Form, caster)
        EndIf
    EndIf
    Debug.Notification("Force power!")
EndFunction

; Robot power attack: one-hit-kill hostiles in encounter or radius
Function ExecuteRobotPowerAttack(Actor caster)
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    Actor[] targets = player.GetAllCombatTargets()
    Int i = 0
    While i < targets.Length
        If targets[i] != None && !targets[i].IsDead() && targets[i].IsHostileToActor(player)
            targets[i].Kill(caster)
        EndIf
        i += 1
    EndWhile
    Debug.Notification("WOW! That was unexpected! -Sir")
EndFunction

; Apologize: calm targets on screen / in radius
Function ExecuteApologize(Actor caster)
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    Float x = player.GetPositionX()
    Float y = player.GetPositionY()
    Float z = player.GetPositionZ()
    Actor[] targets = player.GetAllCombatTargets()
    Int i = 0
    While i < targets.Length
        If targets[i] != None && player.GetDistance(targets[i]) <= ApologizeRadius
            targets[i].StopCombat()
        EndIf
        i += 1
    EndWhile
    Debug.Notification("Apologize!")
EndFunction

; Guard: stand between protectee and enemies; update position for duration. Re-position on timer to "stay on" protectee.
Float Property GuardDuration = 15.0 Auto
Function ExecuteGuard(Actor caster)
    If Formation == None || TacticsQuest == None
        Return
    EndIf
    UpdateGuardPosition(caster)
    ; Optional: RegisterForSingleUpdate(GuardUpdateInterval) and in OnUpdate re-call UpdateGuardPosition until GuardDuration elapsed
    Debug.Notification("Guard!")
EndFunction

Function UpdateGuardPosition(Actor caster)
    ObjectReference nodeMarker = TacticsQuest.CurrentNodeMarker
    If nodeMarker == None
        Return
    EndIf
    Int characterIndex = TacticsQuest.CurrentCharacterIndex
    Int n = TacticsQuest.GetCadreCount()
    Formation.GetAbilitySlotPosition(nodeMarker, characterIndex, n)
    caster.SetPosition(Formation.AbilitySlotX, Formation.AbilitySlotY, Formation.AbilitySlotZ)
EndFunction

; Call for Help: friendlies pathfind to player; faction filter; at end pathfind back or timeout teleport to stored position
ObjectReference[] CallForHelpResponders
Float[] CallForHelpOriginalX
Float[] CallForHelpOriginalY
Float[] CallForHelpOriginalZ
Float Property CallForHelpReturnTimeoutSeconds = 60.0 Auto

Function ExecuteCallForHelp(Actor caster)
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    ; Store responders and positions when helpers are recruited; on combat end or timeout teleport back
    CallForHelpResponders = new ObjectReference[0]
    CallForHelpOriginalX = new Float[0]
    CallForHelpOriginalY = new Float[0]
    CallForHelpOriginalZ = new Float[0]
    Debug.Notification("Call for Help!")
EndFunction

Function OnCombatEnded()
    ; Timeout teleport: return call-for-help responders to stored positions
    If CallForHelpResponders.Length > 0
        Int i = 0
        While i < CallForHelpResponders.Length
            ObjectReference ref = CallForHelpResponders[i]
            If ref != None && i < CallForHelpOriginalX.Length && i < CallForHelpOriginalY.Length && i < CallForHelpOriginalZ.Length
                ref.SetPosition(CallForHelpOriginalX[i], CallForHelpOriginalY[i], CallForHelpOriginalZ[i])
            EndIf
            i += 1
        EndWhile
        CallForHelpResponders = new ObjectReference[0]
        CallForHelpOriginalX = new Float[0]
        CallForHelpOriginalY = new Float[0]
        CallForHelpOriginalZ = new Float[0]
    EndIf
EndFunction
