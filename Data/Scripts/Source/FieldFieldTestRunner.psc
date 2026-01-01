Scriptname FieldFieldTestRunner extends Quest

; Simple test runner for FieldField ship topology tests
; Can be called from console or attached to a quest

FieldFieldShipGraphTest Property GraphTest Auto

; Console command to run tests
Function RunTests()
    If GraphTest == None
        Debug.Trace("FieldFieldTestRunner: GraphTest not set!")
        Debug.Notification("FieldField: Test script not configured")
        Return
    EndIf
    
    Debug.Notification("FieldField: Running topology tests...")
    GraphTest.RunTopologyTests()
    GraphTest.RunAssertions()
    Debug.Notification("FieldField: Tests complete - check logs")
EndFunction

; Quick test for rear entrance exit placement
Function TestRearEntranceExit()
    If GraphTest == None
        Debug.Trace("FieldFieldTestRunner: GraphTest not set!")
        Return
    EndIf
    
    Bool result = GraphTest.AssertRearEntranceExitInFront()
    If result
        Debug.Notification("FieldField: Rear entrance exit test PASSED")
    Else
        Debug.Notification("FieldField: Rear entrance exit test FAILED")
    EndIf
EndFunction

; Quick test for front docker exit placement
Function TestFrontDockerExit()
    If GraphTest == None
        Debug.Trace("FieldFieldTestRunner: GraphTest not set!")
        Return
    EndIf
    
    Bool result = GraphTest.AssertFrontDockerExitInRear()
    If result
        Debug.Notification("FieldField: Front docker exit test PASSED")
    Else
        Debug.Notification("FieldField: Front docker exit test FAILED")
    EndIf
EndFunction

