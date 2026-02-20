Scriptname FieldFieldDungeonCrawlPathfinding extends Quest

; FieldField Dungeon Crawl - Hierarchical pathfinding over rooms and floors.
; Graph: nodes = rooms + floors from index; edges = connections (doors/hatches or proximity).
; Exposes FindPath, GetCurrentNode, GetNodeMarker for movement.
; Movement semantics: W forward, A strafe left, S backward, D strafe right, Q turn left, E turn right (when controls enabled).

FieldFieldDungeonCrawlIndex Property Index Auto

; Unified graph: node 0..RoomCount-1 = rooms, RoomCount..RoomCount+FloorCount-1 = floors
Int[] NodeIDs
ObjectReference[] NodeMarkers
Bool[] NodeIsRoom
Int[] EdgeFrom
Int[] EdgeTo
Float[] EdgeDistances

Int Property NodeCount Auto Hidden

Event OnInit()
    Debug.Trace("FieldFieldDungeonCrawlPathfinding: Initialized")
    ClearGraph()
EndEvent

Function ClearGraph()
    NodeIDs = new Int[0]
    NodeMarkers = new ObjectReference[0]
    NodeIsRoom = new Bool[0]
    EdgeFrom = new Int[0]
    EdgeTo = new Int[0]
    EdgeDistances = new Float[0]
    NodeCount = 0
EndFunction

; Build graph from current index. Call after Index.BuildIndexForCell(cell).
Function BuildGraphFromIndex()
    ClearGraph()
    If Index == None
        Debug.Trace("FieldFieldDungeonCrawlPathfinding: No index set")
        Return
    EndIf

    ObjectReference[] rooms = Index.GetRoomMarkers()
    ObjectReference[] floors = Index.GetFloorMarkers()
    Int r = 0
    While r < rooms.Length
        NodeIDs.Add(NodeCount)
        NodeMarkers.Add(rooms[r])
        NodeIsRoom.Add(True)
        NodeCount += 1
        r += 1
    EndWhile
    Int f = 0
    While f < floors.Length
        NodeIDs.Add(NodeCount)
        NodeMarkers.Add(floors[f])
        NodeIsRoom.Add(False)
        NodeCount += 1
        f += 1
    EndWhile

    ; Default: link all nodes within connection radius (proximity). Call AddEdge for explicit doors/hatches.
    BuildEdgesFromProximity(1500.0)
    Debug.Trace("FieldFieldDungeonCrawlPathfinding: Graph built - " + NodeCount + " nodes, " + EdgeFrom.Length + " edges")
EndFunction

Float Property ConnectionRadius = 1500.0 Auto

; Link nodes whose markers are within radius (walkable branches)
Function BuildEdgesFromProximity(Float radius)
    Int i = 0
    While i < NodeCount
        Int j = i + 1
        While j < NodeCount
            ObjectReference a = NodeMarkers[i]
            ObjectReference b = NodeMarkers[j]
            If a != None && b != None
                Float dist = a.GetDistance(b)
                If dist <= radius && dist >= 1.0
                    AddEdge(i, j, dist)
                EndIf
            EndIf
            j += 1
        EndWhile
        i += 1
    EndWhile
EndFunction

; Explicit edge (e.g. door/hatch between two nodes)
Function AddEdge(Int fromNode, Int toNode, Float distance = -1.0)
    If fromNode < 0 || fromNode >= NodeCount || toNode < 0 || toNode >= NodeCount || fromNode == toNode
        Return
    EndIf
    If distance < 0.0
        ObjectReference fromRef = NodeMarkers[fromNode]
        ObjectReference toRef = NodeMarkers[toNode]
        If fromRef != None && toRef != None
            distance = fromRef.GetDistance(toRef)
        Else
            distance = 1000.0
        EndIf
    EndIf
    EdgeFrom.Add(fromNode)
    EdgeTo.Add(toNode)
    EdgeDistances.Add(distance)
    EdgeFrom.Add(toNode)
    EdgeTo.Add(fromNode)
    EdgeDistances.Add(distance)
EndFunction

; BFS path from fromNode to toNode. Returns ordered array of node IDs (including start and end), or empty if no path.
Int[] Function FindPath(Int fromNode, Int toNode)
    Int[] empty = new Int[0]
    If fromNode < 0 || fromNode >= NodeCount || toNode < 0 || toNode >= NodeCount
        Return empty
    EndIf
    If fromNode == toNode
        Int[] single = new Int[1]
        single[0] = fromNode
        Return single
    EndIf

    ; parentNode[nodeId] = previous node id for path reconstruction
    Int[] parentNode = new Int[NodeCount]
    Int p = 0
    While p < NodeCount
        parentNode[p] = -1
        p += 1
    EndWhile
    parentNode[fromNode] = fromNode

    ; BFS queue: use array + read index
    Int[] queue = new Int[0]
    queue.Add(fromNode)
    Int readIndex = 0
    Bool found = False

    While readIndex < queue.Length
        Int current = queue[readIndex]
        readIndex += 1
        If current == toNode
            found = True
            readIndex = queue.Length
        EndIf

        ; Neighbors: all edges from current
        Int e = 0
        While e < EdgeFrom.Length
            If EdgeFrom[e] == current
                Int neighbor = EdgeTo[e]
                If parentNode[neighbor] < 0
                    parentNode[neighbor] = current
                    queue.Add(neighbor)
                EndIf
            EndIf
            e += 1
        EndWhile
    EndWhile

    If !found
        Return empty
    EndIf

    ; Reconstruct path (target -> start)
    Int[] reverse = new Int[0]
    Int node = toNode
    While node >= 0
        reverse.Add(node)
        If node == fromNode
            node = -1
        Else
            node = parentNode[node]
        EndIf
    EndWhile

    ; Flip to start -> target
    Int[] path = new Int[0]
    Int idx = reverse.Length - 1
    While idx >= 0
        path.Add(reverse[idx])
        idx -= 1
    EndWhile
    Return path
EndFunction

; Nearest node to ref (by distance to node marker)
Int Function GetCurrentNode(ObjectReference ref)
    If ref == None || NodeCount == 0
        Return -1
    EndIf
    Float minDist = 999999.0
    Int nearest = -1
    Int n = 0
    While n < NodeCount
        ObjectReference marker = NodeMarkers[n]
        If marker != None
            Float d = ref.GetDistance(marker)
            If d < minDist
                minDist = d
                nearest = n
            EndIf
        EndIf
        n += 1
    EndWhile
    Return nearest
EndFunction

ObjectReference Function GetNodeMarker(Int nodeID)
    If nodeID < 0 || nodeID >= NodeCount
        Return None
    EndIf
    Return NodeMarkers[nodeID]
EndFunction

Bool Function IsRoomNode(Int nodeID)
    If nodeID < 0 || nodeID >= NodeCount
        Return False
    EndIf
    Return NodeIsRoom[nodeID]
EndFunction

Int Function GetNodeCount()
    Return NodeCount
EndFunction
