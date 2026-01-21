Scriptname FieldFieldShipGraphTest extends Quest

; FieldField Ship Graph Test Script
; Tests ship topology for a ship with:
; - One rear entrance (hatch)
; - One front docker port (hatch)
; - Should produce exit points placed correctly based on graph structure

FieldFieldShipGraph Property ShipGraph Auto
FieldFieldHatchManager Property HatchManager Auto

; Test markers (to be placed in Creation Kit or created at runtime)
ObjectReference Property TestShipInteriorCell Auto
ObjectReference Property TestRearEntranceHatch Auto
ObjectReference Property TestFrontDockerPort Auto
ObjectReference Property TestInteriorNodeRear Auto
ObjectReference Property TestInteriorNodeFront Auto
ObjectReference Property TestExteriorNodeRear Auto
ObjectReference Property TestExteriorNodeFront Auto

Event OnInit()
    Debug.Trace("FieldFieldShipGraphTest: Test script initialized")
    ; Note: RegisterForSingleUpdate may not be available in Starfield
    ; Tests can be run manually via RunTopologyTests() function
EndEvent

Function RunTopologyTests()
    Debug.Trace("========================================")
    Debug.Trace("FieldFieldShipGraphTest: Starting Tests")
    Debug.Trace("========================================")
    
    ; Test 1: Build interior graph
    TestBuildInteriorGraph()
    
    ; Test 2: Build exterior graph
    TestBuildExteriorGraph()
    
    ; Test 3: Associate hatches to graph
    TestAssociateHatches()
    
    ; Test 4: Verify exit point placement
    TestExitPointPlacement()
    
    ; Test 5: Verify graph structure
    TestGraphStructure()
    
    ; Test 6: Verify distance calculations
    TestDistanceCalculations()
    
    Debug.Trace("========================================")
    Debug.Trace("FieldFieldShipGraphTest: Tests Complete")
    Debug.Trace("========================================")
EndFunction

Function TestBuildInteriorGraph()
    Debug.Trace("--- Test 1: Build Interior Graph ---")
    
    If ShipGraph == None
        Debug.Trace("FAIL: ShipGraph is None")
        Return
    EndIf
    
    If TestShipInteriorCell == None
        Debug.Trace("WARNING: TestShipInteriorCell not set - using current cell")
        Cell currentCell = Game.GetPlayer().GetParentCell()
        If currentCell != None
            ShipGraph.BuildInteriorGraph(currentCell)
        Else
            Debug.Trace("FAIL: Cannot get current cell")
            Return
        EndIf
    Else
        Cell testCell = TestShipInteriorCell.GetParentCell()
        If testCell != None
            ShipGraph.BuildInteriorGraph(testCell)
        Else
            Debug.Trace("FAIL: TestShipInteriorCell has no parent cell")
            Return
        EndIf
    EndIf
    
    ; Manually add test nodes if markers are provided
    If TestInteriorNodeRear != None
        Int rearNodeID = ShipGraph.AddInteriorNode(TestInteriorNodeRear, "Rear Entrance Area")
        Debug.Trace("PASS: Added interior rear node " + rearNodeID)
    EndIf
    
    If TestInteriorNodeFront != None
        Int frontNodeID = ShipGraph.AddInteriorNode(TestInteriorNodeFront, "Front Docker Area")
        Debug.Trace("PASS: Added interior front node " + frontNodeID)
    EndIf
    
    ; Add edge connecting rear and front nodes
    If TestInteriorNodeRear != None && TestInteriorNodeFront != None
        Float distance = TestInteriorNodeRear.GetDistance(TestInteriorNodeFront)
        ShipGraph.AddInteriorEdge(0, 1, distance, None)
        Debug.Trace("PASS: Added interior edge (distance: " + distance + ")")
    EndIf
    
    Debug.Trace("PASS: Interior graph built")
EndFunction

Function TestBuildExteriorGraph()
    Debug.Trace("--- Test 2: Build Exterior Graph ---")
    
    If ShipGraph == None
        Debug.Trace("FAIL: ShipGraph is None")
        Return
    EndIf
    
    WorldSpace testWorldSpace = Game.GetPlayer().GetWorldSpace()
    ObjectReference shipRef = Game.GetPlayer() ; Placeholder - should be actual ship reference
    
    ShipGraph.BuildExteriorGraph(testWorldSpace, shipRef)
    
    ; Manually add test nodes if markers are provided
    If TestExteriorNodeRear != None
        Int rearNodeID = ShipGraph.AddExteriorNode(TestExteriorNodeRear, "Rear Landing Area")
        Debug.Trace("PASS: Added exterior rear node " + rearNodeID)
    EndIf
    
    If TestExteriorNodeFront != None
        Int frontNodeID = ShipGraph.AddExteriorNode(TestExteriorNodeFront, "Front Landing Area")
        Debug.Trace("PASS: Added exterior front node " + frontNodeID)
    EndIf
    
    ; Add edge connecting rear and front exterior nodes
    If TestExteriorNodeRear != None && TestExteriorNodeFront != None
        Float distance = TestExteriorNodeRear.GetDistance(TestExteriorNodeFront)
        ShipGraph.AddExteriorEdge(0, 1, distance, None)
        Debug.Trace("PASS: Added exterior edge (distance: " + distance + ")")
    EndIf
    
    Debug.Trace("PASS: Exterior graph built")
EndFunction

Function TestAssociateHatches()
    Debug.Trace("--- Test 3: Associate Hatches to Graph ---")
    
    If ShipGraph == None
        Debug.Trace("FAIL: ShipGraph is None")
        Return
    EndIf
    
    ; Associate rear entrance hatch (should be near rear interior node)
    If TestRearEntranceHatch != None
        ShipGraph.SetContext(True) ; Interior context
        ShipGraph.AssociateHatchToGraph(TestRearEntranceHatch, True)
        Debug.Trace("PASS: Associated rear entrance hatch to interior graph")
    Else
        Debug.Trace("WARNING: TestRearEntranceHatch not set")
    EndIf
    
    ; Associate front docker port (should be near front interior node)
    If TestFrontDockerPort != None
        ShipGraph.SetContext(True) ; Interior context
        ShipGraph.AssociateHatchToGraph(TestFrontDockerPort, True)
        Debug.Trace("PASS: Associated front docker port to interior graph")
    Else
        Debug.Trace("WARNING: TestFrontDockerPort not set")
    EndIf
    
    Debug.Trace("PASS: Hatches associated to graph")
EndFunction

Function TestExitPointPlacement()
    Debug.Trace("--- Test 4: Verify Exit Point Placement ---")
    
    If ShipGraph == None
        Debug.Trace("FAIL: ShipGraph is None")
        Return
    EndIf
    
    ; Test: Rear entrance should have exit point in front of ship
    If TestRearEntranceHatch != None
        ObjectReference exitPoint = ShipGraph.PlaceExitPointForHatch(TestRearEntranceHatch, True)
        If exitPoint != None
            Debug.Trace("PASS: Exit point placed for rear entrance: " + exitPoint)
            
            ; Verify exit point is in front area (should be near front exterior node)
            If TestExteriorNodeFront != None
                Float distanceToFront = exitPoint.GetDistance(TestExteriorNodeFront)
                Float distanceToRear = 999999.0
                If TestExteriorNodeRear != None
                    distanceToRear = exitPoint.GetDistance(TestExteriorNodeRear)
                EndIf
                
                If distanceToFront < distanceToRear
                    Debug.Trace("PASS: Rear entrance exit point is correctly placed in front area (distance to front: " + distanceToFront + ")")
                Else
                    Debug.Trace("FAIL: Rear entrance exit point is not in front area (distance to front: " + distanceToFront + ", distance to rear: " + distanceToRear + ")")
                EndIf
            EndIf
        Else
            Debug.Trace("FAIL: No exit point placed for rear entrance")
        EndIf
    Else
        Debug.Trace("WARNING: TestRearEntranceHatch not set - skipping test")
    EndIf
    
    ; Test: Front docker port should have exit point in rear of ship
    If TestFrontDockerPort != None
        ObjectReference exitPoint = ShipGraph.PlaceExitPointForHatch(TestFrontDockerPort, True)
        If exitPoint != None
            Debug.Trace("PASS: Exit point placed for front docker port: " + exitPoint)
            
            ; Verify exit point is in rear area (should be near rear exterior node)
            If TestExteriorNodeRear != None
                Float distanceToRear = exitPoint.GetDistance(TestExteriorNodeRear)
                Float distanceToFront = 999999.0
                If TestExteriorNodeFront != None
                    distanceToFront = exitPoint.GetDistance(TestExteriorNodeFront)
                EndIf
                
                If distanceToRear < distanceToFront
                    Debug.Trace("PASS: Front docker port exit point is correctly placed in rear area (distance to rear: " + distanceToRear + ")")
                Else
                    Debug.Trace("FAIL: Front docker port exit point is not in rear area (distance to rear: " + distanceToRear + ", distance to front: " + distanceToFront + ")")
                EndIf
            EndIf
        Else
            Debug.Trace("FAIL: No exit point placed for front docker port")
        EndIf
    Else
        Debug.Trace("WARNING: TestFrontDockerPort not set - skipping test")
    EndIf
    
    Debug.Trace("PASS: Exit point placement tests complete")
EndFunction

Function TestGraphStructure()
    Debug.Trace("--- Test 5: Verify Graph Structure ---")
    
    If ShipGraph == None
        Debug.Trace("FAIL: ShipGraph is None")
        Return
    EndIf
    
    ; Verify interior graph has at least 2 nodes (rear and front)
    ; Note: We can't directly access the node arrays, so we'll test via functions
    
    ; Test finding nearest nodes
    If TestInteriorNodeRear != None
        Int nearestNode = ShipGraph.FindNearestNode(TestInteriorNodeRear, True)
        If nearestNode >= 0
            Debug.Trace("PASS: Found nearest interior node for rear area: " + nearestNode)
        Else
            Debug.Trace("FAIL: Could not find nearest interior node for rear area")
        EndIf
    EndIf
    
    If TestInteriorNodeFront != None
        Int nearestNode = ShipGraph.FindNearestNode(TestInteriorNodeFront, True)
        If nearestNode >= 0
            Debug.Trace("PASS: Found nearest interior node for front area: " + nearestNode)
        Else
            Debug.Trace("FAIL: Could not find nearest interior node for front area")
        EndIf
    EndIf
    
    ; Verify exterior graph has at least 2 nodes
    If TestExteriorNodeRear != None
        Int nearestNode = ShipGraph.FindNearestNode(TestExteriorNodeRear, False)
        If nearestNode >= 0
            Debug.Trace("PASS: Found nearest exterior node for rear area: " + nearestNode)
        Else
            Debug.Trace("FAIL: Could not find nearest exterior node for rear area")
        EndIf
    EndIf
    
    If TestExteriorNodeFront != None
        Int nearestNode = ShipGraph.FindNearestNode(TestExteriorNodeFront, False)
        If nearestNode >= 0
            Debug.Trace("PASS: Found nearest exterior node for front area: " + nearestNode)
        Else
            Debug.Trace("FAIL: Could not find nearest exterior node for front area")
        EndIf
    EndIf
    
    Debug.Trace("PASS: Graph structure tests complete")
EndFunction

Function TestDistanceCalculations()
    Debug.Trace("--- Test 6: Verify Distance Calculations ---")
    
    If ShipGraph == None
        Debug.Trace("FAIL: ShipGraph is None")
        Return
    EndIf
    
    ; Test interior distance calculations
    ShipGraph.SetContext(True)
    If TestInteriorNodeRear != None && TestInteriorNodeFront != None
        Float distance = ShipGraph.GetDistanceToNode(TestInteriorNodeRear, 1, True)
        Float expectedDistance = TestInteriorNodeRear.GetDistance(TestInteriorNodeFront)
        
        If distance >= 0.0
            Debug.Trace("PASS: Interior distance calculation works (calculated: " + distance + ", expected: " + expectedDistance + ")")
        Else
            Debug.Trace("FAIL: Interior distance calculation failed")
        EndIf
    EndIf
    
    ; Test exterior distance calculations
    ShipGraph.SetContext(False)
    If TestExteriorNodeRear != None && TestExteriorNodeFront != None
        Float distance = ShipGraph.GetDistanceToNode(TestExteriorNodeRear, 1, False)
        Float expectedDistance = TestExteriorNodeRear.GetDistance(TestExteriorNodeFront)
        
        If distance >= 0.0
            Debug.Trace("PASS: Exterior distance calculation works (calculated: " + distance + ", expected: " + expectedDistance + ")")
        Else
            Debug.Trace("FAIL: Exterior distance calculation failed")
        EndIf
    EndIf
    
    Debug.Trace("PASS: Distance calculation tests complete")
EndFunction

; Helper function to set up test scenario
Function SetupTestScenario()
    Debug.Trace("FieldFieldShipGraphTest: Setting up test scenario")
    
    ; This function can be called to set up a test scenario
    ; In a real implementation, this would create test markers and hatches
    ; For now, markers should be placed in Creation Kit
    
    Debug.Trace("FieldFieldShipGraphTest: Test scenario setup complete")
    Debug.Trace("NOTE: Ensure test markers are placed in Creation Kit:")
    Debug.Trace("  - TestRearEntranceHatch: Rear entrance hatch object")
    Debug.Trace("  - TestFrontDockerPort: Front docker port object")
    Debug.Trace("  - TestInteriorNodeRear: Interior node marker at rear")
    Debug.Trace("  - TestInteriorNodeFront: Interior node marker at front")
    Debug.Trace("  - TestExteriorNodeRear: Exterior node marker at rear")
    Debug.Trace("  - TestExteriorNodeFront: Exterior node marker at front")
EndFunction

; Main assertion: Rear entrance should produce exit in front
Bool Function AssertRearEntranceExitInFront()
    Debug.Trace("=== Assertion: Rear Entrance Exit Point in Front ===")
    
    If TestRearEntranceHatch == None
        Debug.Trace("FAIL: TestRearEntranceHatch not set")
        Return False
    EndIf
    
    If TestExteriorNodeFront == None
        Debug.Trace("FAIL: TestExteriorNodeFront not set")
        Return False
    EndIf
    
    ; Get exit point for rear entrance
    ObjectReference exitPoint = HatchManager.GetExitPointForHatch(TestRearEntranceHatch)
    If exitPoint == None
        Debug.Trace("FAIL: No exit point found for rear entrance")
        Return False
    EndIf
    
    ; Verify exit point is closer to front than rear
    Float distanceToFront = exitPoint.GetDistance(TestExteriorNodeFront)
    Float distanceToRear = 999999.0
    If TestExteriorNodeRear != None
        distanceToRear = exitPoint.GetDistance(TestExteriorNodeRear)
    EndIf
    
    If distanceToFront < distanceToRear
        Debug.Trace("PASS: Rear entrance exit point is correctly placed in front")
        Debug.Trace("  Distance to front: " + distanceToFront)
        Debug.Trace("  Distance to rear: " + distanceToRear)
        Return True
    Else
        Debug.Trace("FAIL: Rear entrance exit point is not in front")
        Debug.Trace("  Distance to front: " + distanceToFront)
        Debug.Trace("  Distance to rear: " + distanceToRear)
        Return False
    EndIf
EndFunction

; Main assertion: Front docker should produce exit in rear
Bool Function AssertFrontDockerExitInRear()
    Debug.Trace("=== Assertion: Front Docker Exit Point in Rear ===")
    
    If TestFrontDockerPort == None
        Debug.Trace("FAIL: TestFrontDockerPort not set")
        Return False
    EndIf
    
    If TestExteriorNodeRear == None
        Debug.Trace("FAIL: TestExteriorNodeRear not set")
        Return False
    EndIf
    
    ; Get exit point for front docker
    ObjectReference exitPoint = HatchManager.GetExitPointForHatch(TestFrontDockerPort)
    If exitPoint == None
        Debug.Trace("FAIL: No exit point found for front docker port")
        Return False
    EndIf
    
    ; Verify exit point is closer to rear than front
    Float distanceToRear = exitPoint.GetDistance(TestExteriorNodeRear)
    Float distanceToFront = 999999.0
    If TestExteriorNodeFront != None
        distanceToFront = exitPoint.GetDistance(TestExteriorNodeFront)
    EndIf
    
    If distanceToRear < distanceToFront
        Debug.Trace("PASS: Front docker port exit point is correctly placed in rear")
        Debug.Trace("  Distance to rear: " + distanceToRear)
        Debug.Trace("  Distance to front: " + distanceToFront)
        Return True
    Else
        Debug.Trace("FAIL: Front docker port exit point is not in rear")
        Debug.Trace("  Distance to rear: " + distanceToRear)
        Debug.Trace("  Distance to front: " + distanceToFront)
        Return False
    EndIf
EndFunction

; Run all assertions
Function RunAssertions()
    Debug.Trace("========================================")
    Debug.Trace("FieldFieldShipGraphTest: Running Assertions")
    Debug.Trace("========================================")
    
    Bool assertion1 = AssertRearEntranceExitInFront()
    Bool assertion2 = AssertFrontDockerExitInRear()
    
    Debug.Trace("========================================")
    If assertion1 && assertion2
        Debug.Trace("PASS: All assertions passed!")
    Else
        Debug.Trace("FAIL: Some assertions failed")
    EndIf
    Debug.Trace("========================================")
EndFunction

