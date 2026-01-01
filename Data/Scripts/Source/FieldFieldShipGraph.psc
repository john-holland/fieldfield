Scriptname FieldFieldShipGraph extends Quest

; FieldField Ship Skeleton Graph System
; Manages ship skeleton graph system
; Constructs spatial graph representation of ship
; Interior Graph: Nodes represent interior spaces/rooms, edges represent connections
; Exterior Graph: Nodes represent exterior spaces/landing areas, edges represent connections

; Graph data structures (using arrays since Papyrus doesn't have structs)
Int[] InteriorNodeIDs
ObjectReference[] InteriorNodeMarkers
String[] InteriorNodeNames
Int[] ExteriorNodeIDs
ObjectReference[] ExteriorNodeMarkers
String[] ExteriorNodeNames

; Edge data (fromNodeID, toNodeID, distance, connectionType)
Int[] InteriorEdgeFromNodes
Int[] InteriorEdgeToNodes
Float[] InteriorEdgeDistances
ObjectReference[] InteriorEdgeHatches
Int[] ExteriorEdgeFromNodes
Int[] ExteriorEdgeToNodes
Float[] ExteriorEdgeDistances
ObjectReference[] ExteriorEdgeHatches

; Hatch to node associations
ObjectReference[] AssociatedHatches
Int[] AssociatedNodeIDs
Bool[] AssociatedIsInterior

; Exit points for hatches
ObjectReference[] HatchExitPoints
ObjectReference[] HatchExitPointHatches

Int Property CurrentContext = 0 Auto ; 0=Out, 1=In

Event OnInit()
    Debug.Trace("FieldFieldShipGraph: Initialized")
    InitializeGraphs()
EndEvent

Function InitializeGraphs()
    InteriorNodeIDs = new Int[0]
    InteriorNodeMarkers = new ObjectReference[0]
    InteriorNodeNames = new String[0]
    ExteriorNodeIDs = new Int[0]
    ExteriorNodeMarkers = new ObjectReference[0]
    ExteriorNodeNames = new String[0]
    
    InteriorEdgeFromNodes = new Int[0]
    InteriorEdgeToNodes = new Int[0]
    InteriorEdgeDistances = new Float[0]
    InteriorEdgeHatches = new ObjectReference[0]
    ExteriorEdgeFromNodes = new Int[0]
    ExteriorEdgeToNodes = new Int[0]
    ExteriorEdgeDistances = new Float[0]
    ExteriorEdgeHatches = new ObjectReference[0]
    
    AssociatedHatches = new ObjectReference[0]
    AssociatedNodeIDs = new Int[0]
    AssociatedIsInterior = new Bool[0]
    
    HatchExitPoints = new ObjectReference[0]
    HatchExitPointHatches = new ObjectReference[0]
EndFunction

; Build interior graph from cell
Function BuildInteriorGraph(Cell shipCell)
    If shipCell == None
        Debug.Trace("FieldFieldShipGraph: Cannot build interior graph - cell is None")
        Return
    EndIf
    
    Debug.Trace("FieldFieldShipGraph: Building interior graph for cell " + shipCell)
    
    ; Clear existing interior graph
    InteriorNodeIDs = new Int[0]
    InteriorNodeMarkers = new ObjectReference[0]
    InteriorNodeNames = new String[0]
    InteriorEdgeFromNodes = new Int[0]
    InteriorEdgeToNodes = new Int[0]
    InteriorEdgeDistances = new Float[0]
    InteriorEdgeHatches = new ObjectReference[0]
    
    ; Scan cell for potential nodes (rooms, spaces)
    ; This would need to identify distinct spaces/rooms in the cell
    ; For now, this is a placeholder - actual implementation depends on available API
    
    ; Would iterate through objects, identify rooms/spaces, create nodes
    ; Then identify connections (doors, hatches) and create edges
    
    Debug.Trace("FieldFieldShipGraph: Interior graph built with " + InteriorNodeIDs.Length + " nodes")
EndFunction

; Build exterior graph from worldspace
Function BuildExteriorGraph(WorldSpace worldSpace, ObjectReference shipRef)
    If worldSpace == None
        Debug.Trace("FieldFieldShipGraph: Cannot build exterior graph - worldspace is None")
        Return
    EndIf
    
    Debug.Trace("FieldFieldShipGraph: Building exterior graph for worldspace " + worldSpace)
    
    ; Clear existing exterior graph
    ExteriorNodeIDs = new Int[0]
    ExteriorNodeMarkers = new ObjectReference[0]
    ExteriorNodeNames = new String[0]
    ExteriorEdgeFromNodes = new Int[0]
    ExteriorEdgeToNodes = new Int[0]
    ExteriorEdgeDistances = new Float[0]
    ExteriorEdgeHatches = new ObjectReference[0]
    
    ; Identify exterior spaces/landing areas
    ; Create nodes for exterior locations
    ; Create edges for connections
    
    ; For now, create a default node at ship location
    If shipRef != None
        Int nodeID = AddExteriorNode(shipRef, "Ship Landing Area")
        Debug.Trace("FieldFieldShipGraph: Created exterior node " + nodeID + " at ship location")
    EndIf
    
    Debug.Trace("FieldFieldShipGraph: Exterior graph built with " + ExteriorNodeIDs.Length + " nodes")
EndFunction

; Add interior node
Int Function AddInteriorNode(ObjectReference marker, String spaceName)
    Int nodeID = InteriorNodeIDs.Length
    InteriorNodeIDs.Add(nodeID)
    InteriorNodeMarkers.Add(marker)
    InteriorNodeNames.Add(spaceName)
    Return nodeID
EndFunction

; Add exterior node
Int Function AddExteriorNode(ObjectReference marker, String spaceName)
    Int nodeID = ExteriorNodeIDs.Length
    ExteriorNodeIDs.Add(nodeID)
    ExteriorNodeMarkers.Add(marker)
    ExteriorNodeNames.Add(spaceName)
    Return nodeID
EndFunction

; Add interior edge
Function AddInteriorEdge(Int fromNode, Int toNode, Float distance, ObjectReference hatch = None)
    InteriorEdgeFromNodes.Add(fromNode)
    InteriorEdgeToNodes.Add(toNode)
    InteriorEdgeDistances.Add(distance)
    InteriorEdgeHatches.Add(hatch)
EndFunction

; Add exterior edge
Function AddExteriorEdge(Int fromNode, Int toNode, Float distance, ObjectReference hatch = None)
    ExteriorEdgeFromNodes.Add(fromNode)
    ExteriorEdgeToNodes.Add(toNode)
    ExteriorEdgeDistances.Add(distance)
    ExteriorEdgeHatches.Add(hatch)
EndFunction

; Get distance to node
Float Function GetDistanceToNode(ObjectReference position, Int nodeID, Bool isInterior)
    If position == None
        Return -1.0
    EndIf
    
    ObjectReference nodeMarker = GetNodeMarker(nodeID, isInterior)
    If nodeMarker == None
        Return -1.0
    EndIf
    
    Return position.GetDistance(nodeMarker)
EndFunction

; Find nearest node
Int Function FindNearestNode(ObjectReference position, Bool isInterior)
    If position == None
        Return -1
    EndIf
    
    Int[] nodeIDs
    ObjectReference[] nodeMarkers
    
    If isInterior
        nodeIDs = InteriorNodeIDs
        nodeMarkers = InteriorNodeMarkers
    Else
        nodeIDs = ExteriorNodeIDs
        nodeMarkers = ExteriorNodeMarkers
    EndIf
    
    If nodeIDs.Length == 0
        Return -1
    EndIf
    
    Float minDistance = 999999.0
    Int nearestNode = -1
    
    Int i = 0
    While i < nodeIDs.Length
        If i < nodeMarkers.Length && nodeMarkers[i] != None
            Float distance = position.GetDistance(nodeMarkers[i])
            If distance < minDistance
                minDistance = distance
                nearestNode = nodeIDs[i]
            EndIf
        EndIf
        i += 1
    EndWhile
    
    Return nearestNode
EndFunction

; Associate hatch to graph
Function AssociateHatchToGraph(ObjectReference hatch, Bool isInterior)
    If hatch == None
        Return
    EndIf
    
    ; Find nearest node
    Int nodeID = FindNearestNode(hatch, isInterior)
    If nodeID < 0
        Debug.Trace("FieldFieldShipGraph: Could not find node for hatch " + hatch)
        Return
    EndIf
    
    ; Check if already associated
    Int index = AssociatedHatches.Find(hatch)
    If index >= 0
        ; Update association
        AssociatedNodeIDs[index] = nodeID
        AssociatedIsInterior[index] = isInterior
    Else
        ; Add new association
        AssociatedHatches.Add(hatch)
        AssociatedNodeIDs.Add(nodeID)
        AssociatedIsInterior.Add(isInterior)
    EndIf
    
    Debug.Trace("FieldFieldShipGraph: Associated hatch " + hatch + " to node " + nodeID + " (interior: " + isInterior + ")")
EndFunction

; Get corresponding node in opposite graph
; For a ship with rear entrance and front docker:
; - Rear interior node corresponds to front exterior node (exit in front)
; - Front interior node corresponds to rear exterior node (exit in rear)
Int Function GetCorrespondingNode(Int nodeID, Bool isInterior)
    ; Find hatches associated with this node
    Int i = 0
    While i < AssociatedHatches.Length
        If AssociatedNodeIDs[i] == nodeID && AssociatedIsInterior[i] == isInterior
            ; Find the hatch associated with this node
            ObjectReference hatch = AssociatedHatches[i]
            
            ; Find corresponding node in opposite graph
            ; Strategy: Find nearest node in opposite graph to the hatch position
            ; This creates the correspondence (rear interior -> front exterior, front interior -> rear exterior)
            Int oppositeNode = FindNearestNode(hatch, !isInterior)
            
            If oppositeNode >= 0
                Debug.Trace("FieldFieldShipGraph: Node " + nodeID + " (interior: " + isInterior + ") corresponds to node " + oppositeNode + " (interior: " + (!isInterior) + ")")
                Return oppositeNode
            EndIf
        EndIf
        i += 1
    EndWhile
    
    ; Fallback: If no hatch association found, find nearest node in opposite graph
    ; This handles cases where we're querying a node directly
    ObjectReference nodeMarker = GetNodeMarker(nodeID, isInterior)
    If nodeMarker != None
        Int oppositeNode = FindNearestNode(nodeMarker, !isInterior)
        If oppositeNode >= 0
            Return oppositeNode
        EndIf
    EndIf
    
    Return -1
EndFunction

; Place exit point for hatch at corresponding graph node
ObjectReference Function PlaceExitPointForHatch(ObjectReference hatch, Bool isInterior)
    If hatch == None
        Return None
    EndIf
    
    ; Check if exit point already exists
    Int index = HatchExitPointHatches.Find(hatch)
    If index >= 0
        Return HatchExitPoints[index]
    EndIf
    
    ; Find associated node
    Int nodeIndex = AssociatedHatches.Find(hatch)
    If nodeIndex < 0
        Debug.Trace("FieldFieldShipGraph: Hatch not associated to graph: " + hatch)
        Return None
    EndIf
    
    Int nodeID = AssociatedNodeIDs[nodeIndex]
    Bool hatchIsInterior = AssociatedIsInterior[nodeIndex]
    
    ; Get corresponding node in opposite graph
    Int correspondingNodeID = GetCorrespondingNode(nodeID, hatchIsInterior)
    If correspondingNodeID < 0
        ; Create exit point at same node if no correspondence found
        correspondingNodeID = nodeID
    EndIf
    
    ; Get node marker position
    ObjectReference nodeMarker = GetNodeMarker(correspondingNodeID, !hatchIsInterior)
    If nodeMarker == None
        Debug.Trace("FieldFieldShipGraph: Could not get node marker for exit point")
        Return None
    EndIf
    
    ; Create exit point marker at node position
    ; Note: This would need to create an actual ObjectReference in the game world
    ; For now, return the node marker as placeholder
    ObjectReference exitPoint = nodeMarker
    
    ; Register exit point
    HatchExitPointHatches.Add(hatch)
    HatchExitPoints.Add(exitPoint)
    
    Debug.Trace("FieldFieldShipGraph: Placed exit point for hatch " + hatch + " at node " + correspondingNodeID)
    Return exitPoint
EndFunction

; Get exit point for hatch
ObjectReference Function GetExitPointForHatch(ObjectReference hatch)
    Int index = HatchExitPointHatches.Find(hatch)
    If index >= 0
        Return HatchExitPoints[index]
    EndIf
    Return None
EndFunction

; Auto-place exit points for all associated hatches
Function AutoPlaceExitPointsForHatches()
    Debug.Trace("FieldFieldShipGraph: Auto-placing exit points for " + AssociatedHatches.Length + " hatches")
    
    Int i = 0
    While i < AssociatedHatches.Length
        PlaceExitPointForHatch(AssociatedHatches[i], AssociatedIsInterior[i])
        i += 1
    EndWhile
EndFunction

; Get context
Int Function GetContext()
    Return CurrentContext
EndFunction

; Set context
Function SetContext(Bool isInterior)
    CurrentContext = isInterior as Int
    String contextName = "Exterior"
    If isInterior
        contextName = "Interior"
    EndIf
    Debug.Trace("FieldFieldShipGraph: Context set to " + contextName)
EndFunction

; Find hatches in range
ObjectReference[] Function FindHatchesInRange(ObjectReference position, Float range, Bool isInterior)
    ObjectReference[] hatchesInRange = new ObjectReference[0]
    
    Int i = 0
    While i < AssociatedHatches.Length
        If AssociatedIsInterior[i] == isInterior
            ObjectReference hatch = AssociatedHatches[i]
            If hatch != None && position.GetDistance(hatch) <= range
                hatchesInRange.Add(hatch)
            EndIf
        EndIf
        i += 1
    EndWhile
    
    Return hatchesInRange
EndFunction

; Get node marker
ObjectReference Function GetNodeMarker(Int nodeID, Bool isInterior)
    Int[] nodeIDs
    ObjectReference[] nodeMarkers
    
    If isInterior
        nodeIDs = InteriorNodeIDs
        nodeMarkers = InteriorNodeMarkers
    Else
        nodeIDs = ExteriorNodeIDs
        nodeMarkers = ExteriorNodeMarkers
    EndIf
    
    Int index = nodeIDs.Find(nodeID)
    If index >= 0 && index < nodeMarkers.Length
        Return nodeMarkers[index]
    EndIf
    
    Return None
EndFunction

