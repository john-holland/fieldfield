Scriptname FieldFieldDungeonCrawlController extends Quest

; FieldField Dungeon Crawl - Main controller Quest.
; Owns index + pathfinding; halting procedural movement; camera at centroid; effects.
; Movement: W forward, A strafe left, S backward, D strafe right, Q turn left, E turn right (when controls enabled).
; Combat and interactions paused during path movement via InputEnableLayer.

FieldFieldDungeonCrawlIndex Property Index Auto
FieldFieldDungeonCrawlPathfinding Property Pathfinding Auto
ReferenceAlias Property PlayerAlias Auto
; When set and Snowfield mode active, OnNodeEntered notifies Group Tactics (pack cadre, etc.)
FieldFieldGroupTacticsQuest Property GroupTacticsQuest Auto

Float Property StepDuration = 0.8 Auto
Float Property RumblePower = 0.3 Auto
Float Property RumbleDuration = 0.2 Auto
ImageSpaceModifier Property TransitionEffect Auto

; Quest integration: when player enters this node, complete the given objective (set in CK)
Int Property ObjectiveTargetNodeID = -1 Auto
Int Property ObjectiveIndexToComplete = 0 Auto

Bool Property IsMoving = False Auto Hidden
Int Property CurrentNodeID = -1 Auto Hidden
InputEnableLayer Property MovementLayer Auto Hidden

Event OnInit()
    Debug.Trace("FieldFieldDungeonCrawlController: Initialized")
EndEvent

; Ensure index and graph are built for the player's current cell
Function EnsureIndexAndGraphForCurrentCell()
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    Cell cell = player.GetParentCell()
    If cell == None
        Return
    EndIf
    If Index == None || Pathfinding == None
        Return
    EndIf
    If !Index.IsIndexValidForCell(cell)
        Index.BuildIndexForCell(cell)
        Pathfinding.BuildGraphFromIndex()
    EndIf
EndFunction

; Start movement to target node. Finds path from current node and runs ProcedureMoveAlongPath.
Function StartMovementToNode(Int targetNodeID)
    If IsMoving
        Debug.Trace("FieldFieldDungeonCrawlController: Already moving, ignoring StartMovementToNode")
        Return
    EndIf
    EnsureIndexAndGraphForCurrentCell()
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    Int fromNode = Pathfinding.GetCurrentNode(player)
    If fromNode < 0
        Debug.Trace("FieldFieldDungeonCrawlController: Could not get current node")
        Return
    EndIf
    Int[] path = Pathfinding.FindPath(fromNode, targetNodeID)
    If path.Length == 0
        Debug.Trace("FieldFieldDungeonCrawlController: No path to node " + targetNodeID)
        Return
    EndIf
    ProcedureMoveAlongPath(path, StepDuration)
EndFunction

; Halting procedural movement along path. Disables movement/fighting/activate; moves player node-by-node; re-enables at end.
Function ProcedureMoveAlongPath(Int[] path, Float stepDuration)
    If path.Length == 0
        Return
    EndIf
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf

    IsMoving = True
    MovementLayer = InputEnableLayer.Create()
    MovementLayer.DisablePlayerControls(True, True, False, False, True, True, True, True, True, True, True)

    Int i = 0
    While i < path.Length
        Int nodeID = path[i]
        ObjectReference marker = Pathfinding.GetNodeMarker(nodeID)
        If marker != None
            player.MoveTo(marker)
            Game.ForceFirstPerson()
            If TransitionEffect != None
                TransitionEffect.Apply(0.15)
                Utility.Wait(0.15)
                TransitionEffect.Remove()
            EndIf
            player.rampRumble(RumblePower, RumbleDuration, 1600.0)
        EndIf
        CurrentNodeID = nodeID
        OnNodeEntered(nodeID)
        If i < path.Length - 1
            Utility.Wait(stepDuration)
        EndIf
        i += 1
    EndWhile

    MovementLayer.EnablePlayerControls(True, True, True, True, True, True, True, True, True, True, True)
    MovementLayer.Delete()
    MovementLayer = None
    IsMoving = False
    Debug.Trace("FieldFieldDungeonCrawlController: Path complete, controls restored")
EndFunction

; Override point for quest/UI: when player enters a node after a step.
Function OnNodeEntered(Int nodeID)
    ; Snowfield: notify Group Tactics to cancel pathfinding and teleport cadre to packed positions
    If GroupTacticsQuest != None && GroupTacticsQuest.IsSnowfieldMode
        GroupTacticsQuest.OnNodeEntered(nodeID)
    EndIf
    ; Example objective: reach a specific node (set ObjectiveTargetNodeID and ObjectiveIndexToComplete in CK)
    If ObjectiveTargetNodeID >= 0 && nodeID == ObjectiveTargetNodeID && ObjectiveIndexToComplete >= 0
        SetObjectiveCompleted(ObjectiveIndexToComplete)
    EndIf
    Debug.Trace("FieldFieldDungeonCrawlController: OnNodeEntered " + nodeID)
EndFunction

Int Function GetCurrentNode()
    Actor player = Game.GetPlayer()
    If player == None || Pathfinding == None
        Return -1
    EndIf
    Return Pathfinding.GetCurrentNode(player)
EndFunction

; Place camera at node centroid (move player to marker + first person)
Function PlaceCameraAtNode(Int nodeID)
    ObjectReference marker = Pathfinding.GetNodeMarker(nodeID)
    If marker == None
        Return
    EndIf
    Actor player = Game.GetPlayer()
    If player == None
        Return
    EndIf
    player.MoveTo(marker)
    Game.ForceFirstPerson()
    CurrentNodeID = nodeID
EndFunction

; One-off shake/rumble at current position
Function TriggerCameraShake(Float power = 0.4, Float duration = 0.25)
    Actor player = Game.GetPlayer()
    If player != None
        player.rampRumble(power, duration, 1600.0)
    EndIf
EndFunction

; Apply full-screen effect (e.g. damage, transition)
Function ApplyScreenEffect(ImageSpaceModifier modifier, Float strength = 1.0)
    If modifier != None
        modifier.Apply(strength)
    EndIf
EndFunction

Function RemoveScreenEffect(ImageSpaceModifier modifier)
    If modifier != None
        modifier.Remove()
    EndIf
EndFunction
