Scriptname FieldFieldInSpaceZeroGTrigger extends ObjectReference

; Applies/removes the configured zero-g spell while the player is inside this trigger.

Spell Property ZeroGSpell Auto Const Mandatory
Bool Property RequirePlayerInSpace = True Auto Const
Bool Property RemoveSpellOnUnload = True Auto Const
Bool Property RemoveSpellOnDisable = True Auto Const

Event OnTriggerEnter(ObjectReference akActionRef)
    Actor playerRef = Game.GetPlayer()
    If akActionRef != playerRef
        Return
    EndIf

    If !ShouldApplyToPlayer(playerRef)
        Return
    EndIf

    Spell zeroG = GetZeroGSpell()
    If zeroG == None
        Return
    EndIf

    If !playerRef.HasSpell(zeroG)
        playerRef.AddSpell(zeroG, False)
    EndIf
EndEvent

Event OnTriggerLeave(ObjectReference akActionRef)
    Actor playerRef = Game.GetPlayer()
    If akActionRef != playerRef
        Return
    EndIf

    RemoveFromPlayer(playerRef)
EndEvent

Event OnUnload()
    If RemoveSpellOnUnload
        RemoveFromPlayer(Game.GetPlayer())
    EndIf
EndEvent

Event OnDisable()
    If RemoveSpellOnDisable
        RemoveFromPlayer(Game.GetPlayer())
    EndIf
EndEvent

Bool Function ShouldApplyToPlayer(Actor playerRef)
    If playerRef == None
        Return False
    EndIf

    If RequirePlayerInSpace && !playerRef.IsInSpace()
        Return False
    EndIf

    If GetZeroGSpell() == None
        Return False
    EndIf

    Return True
EndFunction

Function RemoveFromPlayer(Actor playerRef)
    If playerRef == None
        Return
    EndIf

    Spell zeroG = GetZeroGSpell()
    If zeroG == None
        Return
    EndIf

    If playerRef.HasSpell(zeroG)
        playerRef.RemoveSpell(zeroG)
    EndIf
EndFunction

Spell Function GetZeroGSpell()
    If ZeroGSpell == None
        Debug.Trace("FieldFieldInSpaceZeroGTrigger: ZeroGSpell property is not set on " + Self)
    EndIf
    Return ZeroGSpell
EndFunction
