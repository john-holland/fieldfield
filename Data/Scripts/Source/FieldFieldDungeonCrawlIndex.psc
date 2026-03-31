Scriptname FieldFieldDungeonCrawlIndex extends Quest

; FieldField Dungeon Crawl - Rooms and Floors Index
; Holds two categories: rooms (named spaces) and floors (connection/walkable regions).
; Used as the basis for navigation and camera placement.
; Populated via markers with Keywords DungeonCrawlRoom / DungeonCrawlFloor, or fallback to single node.

Keyword Property DungeonCrawlRoomKeyword Auto
Keyword Property DungeonCrawlFloorKeyword Auto
; Optional: FormList of room/floor base forms if not using keywords
FormList Property RoomMarkerFormList Auto
FormList Property FloorMarkerFormList Auto
; Optional: FormList of refs (e.g. Ring Builder placement/roam volumes) to add as room nodes for pathfinding
FormList Property RingBuilderNodeFormList Auto
Float Property ScanRadius = 10000.0 Auto

; Room data
ObjectReference[] RoomMarkers
String[] RoomNames
Float[] RoomCentroidX
Float[] RoomCentroidY
Float[] RoomCentroidZ

; Floor data
ObjectReference[] FloorMarkers
String[] FloorNames
Float[] FloorCentroidX
Float[] FloorCentroidY
Float[] FloorCentroidZ

; Current cell we indexed (for invalidation)
Cell Property CurrentIndexedCell Auto Hidden

Event OnInit()
    Debug.Trace("FieldFieldDungeonCrawlIndex: Initialized")
    ClearIndex()
EndEvent

Function ClearIndex()
    RoomMarkers = new ObjectReference[0]
    RoomNames = new String[0]
    RoomCentroidX = new Float[0]
    RoomCentroidY = new Float[0]
    RoomCentroidZ = new Float[0]
    FloorMarkers = new ObjectReference[0]
    FloorNames = new String[0]
    FloorCentroidX = new Float[0]
    FloorCentroidY = new Float[0]
    FloorCentroidZ = new Float[0]
    CurrentIndexedCell = None
EndFunction

; Build index for the given cell. Uses player or a ref in the cell to run Find* from.
Function BuildIndexForCell(Cell targetCell)
    If targetCell == None
        Debug.Trace("FieldFieldDungeonCrawlIndex: Cannot build index - cell is None")
        Return
    EndIf

    ClearIndex()
    CurrentIndexedCell = targetCell

    ObjectReference seedRef = Game.GetPlayer()
    If seedRef == None || seedRef.GetParentCell() != targetCell
        ; No player in cell - try to use any ref; for now create fallback single room at origin
        AddFallbackRoom(targetCell)
        Debug.Trace("FieldFieldDungeonCrawlIndex: No player in cell, using fallback single room")
        Return
    EndIf

    Float x = seedRef.GetPositionX()
    Float y = seedRef.GetPositionY()
    Float z = seedRef.GetPositionZ()

    ; Scan for room markers (keyword or form list)
    If DungeonCrawlRoomKeyword != None
        ObjectReference[] roomRefs = seedRef.FindAllReferencesWithKeyword(DungeonCrawlRoomKeyword as Form, ScanRadius)
        Int i = 0
        While i < roomRefs.Length
            If roomRefs[i] != None && roomRefs[i].GetParentCell() == targetCell
                AddRoomMarker(roomRefs[i], "Room_" + RoomMarkers.Length)
            EndIf
            i += 1
        EndWhile
    EndIf
    If RoomMarkerFormList != None
        ObjectReference[] listRefs = seedRef.FindAllReferencesOfType(RoomMarkerFormList as Form, ScanRadius)
        Int j = 0
        While j < listRefs.Length
            If listRefs[j] != None && listRefs[j].GetParentCell() == targetCell
                AddRoomMarker(listRefs[j], "Room_" + RoomMarkers.Length)
            EndIf
            j += 1
        EndWhile
    EndIf
    ; Ring Builder: add placement/roam volumes as room nodes (FormList contains base forms of volume refs)
    If RingBuilderNodeFormList != None
        Int rbi = 0
        While rbi < RingBuilderNodeFormList.GetSize()
            Form f = RingBuilderNodeFormList.GetAt(rbi)
            If f != None
                ObjectReference[] rbRefs = seedRef.FindAllReferencesOfType(f, ScanRadius)
                Int rbr = 0
                While rbr < rbRefs.Length
                    If rbRefs[rbr] != None && rbRefs[rbr].GetParentCell() == targetCell
                        AddRoomMarker(rbRefs[rbr], "Room_" + RoomMarkers.Length)
                    EndIf
                    rbr += 1
                EndWhile
            EndIf
            rbi += 1
        EndWhile
    EndIf

    ; Scan for floor markers
    If DungeonCrawlFloorKeyword != None
        ObjectReference[] floorRefs = seedRef.FindAllReferencesWithKeyword(DungeonCrawlFloorKeyword as Form, ScanRadius)
        Int k = 0
        While k < floorRefs.Length
            If floorRefs[k] != None && floorRefs[k].GetParentCell() == targetCell
                AddFloorMarker(floorRefs[k], "Floor_" + FloorMarkers.Length)
            EndIf
            k += 1
        EndWhile
    EndIf
    If FloorMarkerFormList != None
        ObjectReference[] floorListRefs = seedRef.FindAllReferencesOfType(FloorMarkerFormList as Form, ScanRadius)
        Int m = 0
        While m < floorListRefs.Length
            If floorListRefs[m] != None && floorListRefs[m].GetParentCell() == targetCell
                AddFloorMarker(floorListRefs[m], "Floor_" + FloorMarkers.Length)
            EndIf
            m += 1
        EndWhile
    EndIf

    ; Fallback: if no markers found, single room at player position
    If RoomMarkers.Length == 0 && FloorMarkers.Length == 0
        AddFallbackRoom(targetCell)
    EndIf

    Debug.Trace("FieldFieldDungeonCrawlIndex: Built index for cell " + targetCell + " - Rooms: " + RoomMarkers.Length + ", Floors: " + FloorMarkers.Length)
EndFunction

Function AddRoomMarker(ObjectReference marker, String name)
    If marker == None
        Return
    EndIf
    RoomMarkers.Add(marker)
    RoomNames.Add(name)
    RoomCentroidX.Add(marker.GetPositionX())
    RoomCentroidY.Add(marker.GetPositionY())
    RoomCentroidZ.Add(marker.GetPositionZ())
EndFunction

Function AddFloorMarker(ObjectReference marker, String name)
    If marker == None
        Return
    EndIf
    FloorMarkers.Add(marker)
    FloorNames.Add(name)
    FloorCentroidX.Add(marker.GetPositionX())
    FloorCentroidY.Add(marker.GetPositionY())
    FloorCentroidZ.Add(marker.GetPositionZ())
EndFunction

; Single room node when no markers exist
Function AddFallbackRoom(Cell targetCell)
    ObjectReference playerRef = Game.GetPlayer()
    If playerRef != None && playerRef.GetParentCell() == targetCell
        RoomMarkers.Add(playerRef)
        RoomNames.Add("DefaultRoom")
        RoomCentroidX.Add(playerRef.GetPositionX())
        RoomCentroidY.Add(playerRef.GetPositionY())
        RoomCentroidZ.Add(playerRef.GetPositionZ())
    EndIf
EndFunction

; --- Getters ---

ObjectReference[] Function GetRoomMarkers()
    Return RoomMarkers
EndFunction

ObjectReference[] Function GetFloorMarkers()
    Return FloorMarkers
EndFunction

; Centroid as ref (marker position)
ObjectReference Function GetCentroidRefForRoom(Int roomIndex)
    If roomIndex < 0 || roomIndex >= RoomMarkers.Length
        Return None
    EndIf
    Return RoomMarkers[roomIndex]
EndFunction

ObjectReference Function GetCentroidRefForFloor(Int floorIndex)
    If floorIndex < 0 || floorIndex >= FloorMarkers.Length
        Return None
    EndIf
    Return FloorMarkers[floorIndex]
EndFunction

; Centroid as XYZ (for room by index)
Float Function GetRoomCentroidX(Int roomIndex)
    If roomIndex < 0 || roomIndex >= RoomCentroidX.Length
        Return 0.0
    EndIf
    Return RoomCentroidX[roomIndex]
EndFunction

Float Function GetRoomCentroidY(Int roomIndex)
    If roomIndex < 0 || roomIndex >= RoomCentroidY.Length
        Return 0.0
    EndIf
    Return RoomCentroidY[roomIndex]
EndFunction

Float Function GetRoomCentroidZ(Int roomIndex)
    If roomIndex < 0 || roomIndex >= RoomCentroidZ.Length
        Return 0.0
    EndIf
    Return RoomCentroidZ[roomIndex]
EndFunction

Int Function GetRoomCount()
    Return RoomMarkers.Length
EndFunction

Int Function GetFloorCount()
    Return FloorMarkers.Length
EndFunction

Cell Function GetCurrentIndexedCell()
    Return CurrentIndexedCell
EndFunction

Bool Function IsIndexValidForCell(Cell targetCell)
    Return CurrentIndexedCell == targetCell
EndFunction
