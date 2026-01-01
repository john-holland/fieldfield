Scriptname FieldFieldDataExplorer extends Quest

; FieldField Data Explorer Script
; Utility functions to query:
; Object properties and states
; Animation capabilities
; UI system access
; Engine data availability
; Logs findings to debug output
; Provides test functions for exploration

Event OnInit()
    Debug.Trace("FieldFieldDataExplorer: Initialized")
EndEvent

; Explore object properties
Function ExploreObjectProperties(ObjectReference obj)
    If obj == None
        Debug.Trace("FieldFieldDataExplorer: Cannot explore - object is None")
        Return
    EndIf
    
    Debug.Trace("=== FieldFieldDataExplorer: Exploring Object Properties ===")
    Debug.Trace("Object: " + obj)
    Debug.Trace("Display Name: " + obj.GetDisplayName())
    Debug.Trace("Base Object: " + obj.GetBaseObject())
    Debug.Trace("Position X: " + obj.GetPositionX())
    Debug.Trace("Position Y: " + obj.GetPositionY())
    Debug.Trace("Position Z: " + obj.GetPositionZ())
    Debug.Trace("Angle X: " + obj.GetAngleX())
    Debug.Trace("Angle Y: " + obj.GetAngleY())
    Debug.Trace("Angle Z: " + obj.GetAngleZ())
    Debug.Trace("Current Cell: " + obj.GetParentCell())
    Debug.Trace("Current Location: " + obj.GetCurrentLocation())
    Debug.Trace("Is3DLoaded: " + obj.Is3DLoaded())
    Debug.Trace("IsDisabled: " + obj.IsDisabled())
    Debug.Trace("IsDeleted: " + obj.IsDeleted())
    Debug.Trace("===========================================================")
EndFunction

; Explore animation capabilities
Function ExploreAnimationCapabilities(ObjectReference obj)
    If obj == None
        Debug.Trace("FieldFieldDataExplorer: Cannot explore - object is None")
        Return
    EndIf
    
    Debug.Trace("=== FieldFieldDataExplorer: Exploring Animation Capabilities ===")
    Debug.Trace("Object: " + obj)
    
    ; Test common animation functions
    ; Note: Actual capabilities depend on Starfield's Papyrus API
    
    ; Try to query if object supports animations
    Debug.Trace("Is3DLoaded: " + obj.Is3DLoaded())
    
    ; Test animation playback (commented out to avoid actually playing)
    ; obj.PlayAnimation("Open")
    
    Debug.Trace("===========================================================")
EndFunction

; Explore UI system access
Function ExploreUISystem()
    Debug.Trace("=== FieldFieldDataExplorer: Exploring UI System ===")
    
    ; Test UI notification functions
    Debug.Notification("FieldField: UI Notification Test")
    Debug.MessageBox("FieldField: UI MessageBox Test")
    
    ; Test if UI functions are available
    ; Note: Starfield may have different UI API than Skyrim/Fallout
    
    Debug.Trace("UI functions tested")
    Debug.Trace("===========================================================")
EndFunction

; Explore engine data
Function ExploreEngineData()
    Debug.Trace("=== FieldFieldDataExplorer: Exploring Engine Data ===")
    
    ; Test game state queries
    Actor player = Game.GetPlayer()
    If player != None
        Debug.Trace("Player: " + player)
        Debug.Trace("Player Position X: " + player.GetPositionX())
        Debug.Trace("Player Position Y: " + player.GetPositionY())
        Debug.Trace("Player Position Z: " + player.GetPositionZ())
        Debug.Trace("Player Cell: " + player.GetParentCell())
        Debug.Trace("Player Location: " + player.GetCurrentLocation())
    EndIf
    
    ; Test form/reference data access
    Debug.Trace("Game Version: " + Game.GetVersion())
    
    Debug.Trace("===========================================================")
EndFunction

; Test context detection
Function TestContextDetection()
    Debug.Trace("=== FieldFieldDataExplorer: Testing Context Detection ===")
    
    Actor player = Game.GetPlayer()
    If player != None
        Location loc = player.GetCurrentLocation()
        Cell cell = player.GetParentCell()
        
        Debug.Trace("Player Location: " + loc)
        Debug.Trace("Player Cell: " + cell)
        
        ; Try to determine if in ship interior
        ; This would need actual game-specific checks
        Bool isInterior = cell != None && cell.IsInterior()
        Debug.Trace("Is Interior Cell: " + isInterior)
    EndIf
    
    Debug.Trace("===========================================================")
EndFunction

; Comprehensive exploration of an object
Function ExploreObject(ObjectReference obj)
    ExploreObjectProperties(obj)
    ExploreAnimationCapabilities(obj)
EndFunction

; Run all exploration tests
Function RunAllTests()
    Debug.Trace("FieldFieldDataExplorer: Running all exploration tests")
    ExploreUISystem()
    ExploreEngineData()
    TestContextDetection()
    
    ; Test with player
    Actor player = Game.GetPlayer()
    If player != None
        ExploreObject(player)
    EndIf
EndFunction

