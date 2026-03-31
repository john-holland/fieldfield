Scriptname FieldFieldFareyQuestTree extends Quest

; Farey nested interval quest tree: each quest has left/right fractional IDs;
; child quests are those whose interval is strictly contained in parent's.
; Allows infinite insertion of quests without renumbering. Populate while building
; the ring; remove from active tree when completed (completed stay in log).

; All registered quests (and root). Parallel arrays hold Farey bounds per index.
FormList Property RegisteredQuests Auto
; Quests removed from active tree (completed); still in log, excluded from GetChildQuests.
FormList Property CompletedQuests Auto
; Filled and returned by GetChildQuests; create in CK. Revert() then AddForm each child; caller use immediately.
FormList Property ChildQuestsResultFormList Auto
Int[] LeftNum
Int[] LeftDen
Int[] RightNum
Int[] RightDen

; Root interval: 0/1 to 1/1. Set in CK or by EnsureRoot.
Quest Property RootQuest Auto

Event OnInit()
    LeftNum = new Int[0]
    LeftDen = new Int[0]
    RightNum = new Int[0]
    RightDen = new Int[0]
    If RegisteredQuests == None
        Debug.Trace("FieldFieldFareyQuestTree: RegisteredQuests is None - create in CK")
    EndIf
    Debug.Trace("FieldFieldFareyQuestTree: Initialized")
EndEvent

; Register root with interval (0/1, 1/1). Call once or ensure root exists.
Function EnsureRoot()
    If RootQuest == None
        Return
    EndIf
    Int idx = GetQuestIndex(RootQuest)
    If idx >= 0
        Return
    EndIf
    RegisterQuestWithInterval(RootQuest, 0, 1, 1, 1)
    Debug.Trace("FieldFieldFareyQuestTree: Root registered")
EndFunction

; Register a quest with explicit Farey bounds (num/den). Used for root or manual insert.
Function RegisterQuestWithInterval(Quest q, Int leftN, Int leftD, Int rightN, Int rightD)
    If q == None || RegisteredQuests == None
        Return
    EndIf
    If GetQuestIndex(q) >= 0
        Return
    EndIf
    RegisteredQuests.AddForm(q as Form)
    LeftNum = AppendInt(LeftNum, leftN)
    LeftDen = AppendInt(LeftDen, leftD)
    RightNum = AppendInt(RightNum, rightN)
    RightDen = AppendInt(RightDen, rightD)
EndFunction

; Add newQuest as a child of akParent (insert as rightmost child). Assigns interval inside parent.
Function AddChild(Quest akParent, Quest newQuest)
    If akParent == None || newQuest == None || RegisteredQuests == None
        Return
    EndIf
    Int pIdx = GetQuestIndex(akParent)
    If pIdx < 0
        Debug.Trace("FieldFieldFareyQuestTree: Parent not registered")
        Return
    EndIf
    If GetQuestIndex(newQuest) >= 0
        Debug.Trace("FieldFieldFareyQuestTree: Quest already registered")
        Return
    EndIf
    Int pLnum = LeftNum[pIdx]
    Int pLden = LeftDen[pIdx]
    Int pRnum = RightNum[pIdx]
    Int pRden = RightDen[pIdx]
    ; Find rightmost child of akParent (largest right bound)
    Int cRnum = pLnum
    Int cRden = pLden
    Int i = 0
    Int n = RegisteredQuests.GetSize()
    While i < n
        If i != pIdx && IntervalContains(pLnum, pLden, pRnum, pRden, LeftNum[i], LeftDen[i], RightNum[i], RightDen[i])
            ; This is a child; compare right bound: RightNum[i]/RightDen[i] vs cRnum/cRden
            If CompareFractions(RightNum[i], RightDen[i], cRnum, cRden) > 0
                cRnum = RightNum[i]
                cRden = RightDen[i]
            EndIf
        EndIf
        i += 1
    EndWhile
    ; New child: left = FareyMedian(cRnum/cRden, pRnum/pRden), right = pRnum/pRden
    Int newLeftNum = cRnum + pRnum
    Int newLeftDen = cRden + pRden
    RegisterQuestWithInterval(newQuest, newLeftNum, newLeftDen, pRnum, pRden)
    Debug.Trace("FieldFieldFareyQuestTree: Added child " + newQuest + " under " + akParent)
EndFunction

; Remove quest from the active tree (e.g. when completed). Quest stays in log; GetChildQuests excludes it.
Function RemoveFromTree(Quest q)
    If q == None || CompletedQuests == None
        Return
    EndIf
    If GetQuestIndex(q) < 0
        Return
    EndIf
    CompletedQuests.AddForm(q as Form)
    Debug.Trace("FieldFieldFareyQuestTree: Removed from tree (completed) " + q)
EndFunction

; Get all quests whose interval is strictly contained in akParent's. Fills ChildQuestsResultFormList; use result immediately.
FormList Function GetChildQuests(Quest akParent)
    If ChildQuestsResultFormList == None
        Return None
    EndIf
    ChildQuestsResultFormList.Revert()
    Int pIdx = GetQuestIndex(akParent)
    If pIdx < 0
        Return ChildQuestsResultFormList
    EndIf
    Int pLnum = LeftNum[pIdx]
    Int pLden = LeftDen[pIdx]
    Int pRnum = RightNum[pIdx]
    Int pRden = RightDen[pIdx]
    Int i = 0
    Int n = RegisteredQuests.GetSize()
    While i < n
        Form f = RegisteredQuests.GetAt(i)
        Quest q = f as Quest
        If i != pIdx && q != None && (CompletedQuests == None || !CompletedQuests.HasForm(q as Form))
            If LeftDen[i] != 0 && RightDen[i] != 0
                If IntervalContains(pLnum, pLden, pRnum, pRden, LeftNum[i], LeftDen[i], RightNum[i], RightDen[i])
                    ChildQuestsResultFormList.AddForm(f)
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile
    Return ChildQuestsResultFormList
EndFunction

; True if (pL/pLD, pR/pRD) strictly contains (cL/cLD, cR/cRD): pL < cL and cR < pR
Bool Function IntervalContains(Int pLnum, Int pLden, Int pRnum, Int pRden, Int cLnum, Int cLden, Int cRnum, Int cRden)
    Return CompareFractions(pLnum, pLden, cLnum, cLden) < 0 && CompareFractions(cRnum, cRden, pRnum, pRden) < 0
EndFunction

; a/b vs c/d: returns -1 if a/b < c/d, 0 if equal, 1 if a/b > c/d (assumes positive denom)
Int Function CompareFractions(Int a, Int b, Int c, Int d)
    If b == 0 || d == 0
        Return 0
    EndIf
    Int ad = a * d
    Int bc = b * c
    If ad < bc
        Return -1
    ElseIf ad > bc
        Return 1
    EndIf
    Return 0
EndFunction

; Farey median: (a_num + c_num)/(a_den + c_den) between a_num/a_den and c_num/c_den
Int Function GetQuestIndex(Quest q)
    If q == None || RegisteredQuests == None
        Return -1
    EndIf
    Int i = 0
    Int n = RegisteredQuests.GetSize()
    While i < n
        If RegisteredQuests.GetAt(i) == q as Form
            Return i
        EndIf
        i += 1
    EndWhile
    Return -1
EndFunction

Int[] Function AppendInt(Int[] arr, Int val)
    Int n = arr.Length
    Int[] newArr = new Int[n + 1]
    Int j = 0
    While j < n
        newArr[j] = arr[j]
        j += 1
    EndWhile
    newArr[n] = val
    Return newArr
EndFunction

