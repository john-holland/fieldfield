Scriptname FieldFieldGravityToggleItemEffect extends ActiveMagicEffect

; Item-use magic effect: toggles gravity mode on linked ship zone controllers.

Keyword Property ZoneControllerLinkKeyword Auto Const
Keyword Property ZoneControllerSearchKeyword Auto Const
Float Property SearchRadius = 15000.0 Auto Const
Bool Property ShowDebugNotifications = False Auto Const

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, float afMagnitude, float afDuration)
    Actor playerRef = Game.GetPlayer()
    If akCaster != playerRef
        Return
    EndIf

    SpaceshipReference currentShip = playerRef.GetCurrentShipRef()
    If currentShip == None
        Debug.Trace("FieldFieldGravityToggleItemEffect: No current ship; no gravity zones toggled")
        Return
    EndIf

    ObjectReference[] candidates = new ObjectReference[0]
    If ZoneControllerLinkKeyword != None
        candidates = currentShip.GetLinkedRefChain(ZoneControllerLinkKeyword)
    EndIf
    If candidates.Length == 0 && ZoneControllerSearchKeyword != None
        candidates = playerRef.FindAllReferencesWithKeyword(ZoneControllerSearchKeyword as Form, SearchRadius)
    EndIf

    Int toggledCount = 0
    Int i = 0
    While i < candidates.Length
        FieldFieldShipGravityZoneController controller = candidates[i] as FieldFieldShipGravityZoneController
        If controller != None && controller.IsForShip(currentShip)
            controller.ToggleGravityMode()
            toggledCount += 1
        EndIf
        i += 1
    EndWhile

    If ShowDebugNotifications
        Debug.Notification("FieldField: Gravity mode toggled for " + toggledCount + " ship zone(s)")
    EndIf
EndEvent
