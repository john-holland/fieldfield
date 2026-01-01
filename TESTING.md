# FieldField Mod Testing Guide

## Ship Topology Test

This test verifies that the ship skeleton graph system correctly places exit points for a ship with:
- **One rear entrance** (hatch at the rear of the ship)
- **One front docker port** (hatch at the front of the ship)

### Expected Behavior

- **Rear entrance** should produce an exit point **in front of the ship** (exterior)
- **Front docker port** should produce an exit point **in rear of the ship** (exterior)

This creates a logical flow: entering from the rear takes you to the front exterior, and entering from the front takes you to the rear exterior.

## Test Setup

### 1. Create Test Quest

In Creation Kit:
1. Create a new Quest named "FieldFieldTestQuest"
2. Attach `FieldFieldShipGraphTest` script
3. Set quest to start game enabled (optional)

### 2. Place Test Markers

You need to place the following ObjectReferences in your test ship:

#### Interior Markers (inside ship):
- **TestInteriorNodeRear**: XMarkerHeading at rear entrance area
- **TestInteriorNodeFront**: XMarkerHeading at front docker area
- **TestRearEntranceHatch**: Actual hatch object at rear entrance
- **TestFrontDockerPort**: Actual hatch/docker object at front

#### Exterior Markers (outside ship):
- **TestExteriorNodeRear**: XMarkerHeading at rear landing area (outside ship)
- **TestExteriorNodeFront**: XMarkerHeading at front landing area (outside ship)

### 3. Configure Script Properties

In the Creation Kit, set the following properties on `FieldFieldShipGraphTest`:
- `ShipGraph`: Reference to FieldFieldShipGraph quest/script
- `HatchManager`: Reference to FieldFieldHatchManager quest/script
- `TestShipInteriorCell`: The ship interior cell (optional)
- `TestRearEntranceHatch`: The rear entrance hatch reference
- `TestFrontDockerPort`: The front docker port reference
- `TestInteriorNodeRear`: Interior rear node marker
- `TestInteriorNodeFront`: Interior front node marker
- `TestExteriorNodeRear`: Exterior rear node marker
- `TestExteriorNodeFront`: Exterior front node marker

## Running Tests

### Method 1: Automatic (On Game Start)

If the test quest is set to start game enabled, tests will run automatically 2 seconds after game start.

### Method 2: Console Command

1. Open console (`~` key)
2. Type: `coc YourTestCell` (to get to your test location)
3. Type: `sqv FieldFieldTestQuest` (to check quest status)
4. The tests should run automatically, or you can call:
   - `FieldFieldTestQuest.RunTopologyTests()`
   - `FieldFieldTestQuest.RunAssertions()`

### Method 3: Using Test Runner

1. Create a quest with `FieldFieldTestRunner` script attached
2. Set `GraphTest` property to your `FieldFieldShipGraphTest` quest
3. Call `RunTests()` function from console or script

## Test Output

All test results are logged to the Papyrus log file. Check:
- `Documents/My Games/Starfield/Logs/Script/Papyrus.0.log`

### Test Results Format

```
========================================
FieldFieldShipGraphTest: Starting Tests
========================================
--- Test 1: Build Interior Graph ---
PASS: Added interior rear node 0
PASS: Added interior front node 1
PASS: Added interior edge (distance: 1500.0)
PASS: Interior graph built
--- Test 2: Build Exterior Graph ---
PASS: Added exterior rear node 0
PASS: Added exterior front node 1
...
========================================
FieldFieldShipGraphTest: Tests Complete
========================================
```

## Assertions

The test includes two main assertions:

### Assertion 1: Rear Entrance Exit in Front
- Verifies that the rear entrance hatch produces an exit point
- Verifies the exit point is closer to the front exterior node than the rear exterior node
- **Expected**: PASS - Exit point should be in front area

### Assertion 2: Front Docker Exit in Rear
- Verifies that the front docker port produces an exit point
- Verifies the exit point is closer to the rear exterior node than the front exterior node
- **Expected**: PASS - Exit point should be in rear area

## Troubleshooting

### Tests Fail: "Test markers not set"
- Ensure all test marker properties are set in Creation Kit
- Verify markers are placed in the correct cells

### Tests Fail: "ShipGraph is None"
- Ensure ShipGraph property is set on the test script
- Verify FieldFieldShipGraph quest is created and running

### Exit Points Not Placed Correctly
- Check that graph nodes are created correctly
- Verify hatch-to-node associations are working
- Check that `GetCorrespondingNode()` is finding the correct opposite node

### Distance Calculations Wrong
- Verify node markers are placed at correct positions
- Check that interior and exterior graphs are built correctly
- Ensure context (interior/exterior) is set correctly

## Test Coverage

The test suite covers:
1. ✅ Interior graph construction
2. ✅ Exterior graph construction
3. ✅ Hatch-to-graph association
4. ✅ Exit point placement
5. ✅ Graph structure verification
6. ✅ Distance calculations
7. ✅ Context-aware operations
8. ✅ Main assertions (rear→front, front→rear)

## Example Test Scenario

```
Ship Layout:
  [Front Docker Port] ---- [Ship Interior] ---- [Rear Entrance]
         |                                            |
         |                                            |
  [Front Landing]                            [Rear Landing]
     (Exterior)                                (Exterior)

Expected Exit Points:
  - Rear Entrance → Front Landing (exit in front)
  - Front Docker → Rear Landing (exit in rear)
```

This creates a logical flow where entering from either end takes you to the opposite exterior location.

