Scriptname FieldFieldShipGravityZoneController extends ObjectReference

; Controls gravity-mode spells for all actors inside this trigger.

Spell Property ZeroGSpell Auto Const
Spell Property NormalGravitySpell Auto Const
Bool Property StartInZeroG = False Auto Const
SpaceshipReference Property ControlledShip Auto Const

Bool GravityModeIsZeroG = False

Event OnInit()
    GravityModeIsZeroG = StartInZeroG
EndEvent

Event OnLoad()
    ApplyCurrentModeToAllInTrigger()
EndEvent

Event OnTriggerEnter(ObjectReference akActionRef)
    ApplyModeToRef(akActionRef)
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)
    RemoveManagedSpellsFromRef(akActionRef)
EndEvent

Function ToggleGravityMode()
    SetGravityMode(!GravityModeIsZeroG)
EndFunction

Function SetGravityMode(Bool makeZeroG)
    GravityModeIsZeroG = makeZeroG
    ApplyCurrentModeToAllInTrigger()
EndFunction

Bool Function IsForShip(SpaceshipReference shipRef)
    If shipRef == None
        Return False
    EndIf

    If ControlledShip != None
        Return shipRef == ControlledShip
    EndIf

    SpaceshipReference localShip = Self.GetCurrentShipRef()
    If localShip != None
        Return shipRef == localShip
    EndIf

    Return False
EndFunction

Bool Function IsZeroGActive()
    Return GravityModeIsZeroG
EndFunction

Function ApplyCurrentModeToAllInTrigger()
    ObjectReference[] triggerRefs = GetAllRefsInTrigger()
    If triggerRefs.Length == 0
        Return
    EndIf

    Int i = 0
    While i < triggerRefs.Length
        ApplyModeToRef(triggerRefs[i])
        i += 1
    EndWhile
EndFunction

Function ApplyModeToRef(ObjectReference targetRef)
    Actor targetActor = targetRef as Actor
    If targetActor == None
        Return
    EndIf

    If GravityModeIsZeroG
        If NormalGravitySpell != None && targetActor.HasSpell(NormalGravitySpell)
            targetActor.RemoveSpell(NormalGravitySpell)
        EndIf
        If ZeroGSpell != None && !targetActor.HasSpell(ZeroGSpell)
            targetActor.AddSpell(ZeroGSpell, False)
        EndIf
    Else
        If ZeroGSpell != None && targetActor.HasSpell(ZeroGSpell)
            targetActor.RemoveSpell(ZeroGSpell)
        EndIf
        If NormalGravitySpell != None && !targetActor.HasSpell(NormalGravitySpell)
            targetActor.AddSpell(NormalGravitySpell, False)
        EndIf
    EndIf
EndFunction

Function RemoveManagedSpellsFromRef(ObjectReference targetRef)
    Actor targetActor = targetRef as Actor
    If targetActor == None
        Return
    EndIf

    If ZeroGSpell != None && targetActor.HasSpell(ZeroGSpell)
        targetActor.RemoveSpell(ZeroGSpell)
    EndIf
    If NormalGravitySpell != None && targetActor.HasSpell(NormalGravitySpell)
        targetActor.RemoveSpell(NormalGravitySpell)
    EndIf
EndFunction
