#Include %A_ScriptDir%\Monitor.ahk
#Include %A_ScriptDir%\Counter.ahk
#SingleInstance Force

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Global Variables --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__show_arrows := 0
__ALIGN_LEN := 6

;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

StringToSortedListString(str, comparator, type := "MERGE", default_delim := "", width := 0, tracking := 0) {
	if (tracking) {
		TrackingCounter.Reset()
		TrackingCounter.SetSegmentLength(width)
	}
	
	list := GetList(str, list, delim)
	list := SortBy(list, comparator, type, tracking)
	
	if (width > 0)
		str := TrackingCounter.GetIndent() . ListToAlignedString(list, width)
	else
		str := ListToDelimitedString(list, (default_delim = "") ? delim : default_delim)
		
	if (tracking) {
		str := TrackingCounter.NewNumberLine() . "`r`n" . str . "`r`n`r`n" . TrackingCounter.GetTrackingString()
	}
	
	return str
}

SortAscending(ByRef list, type := "MERGE") {
	return __Sort(list, 1, list.MaxIndex(), "CompareAscending", type, tracking)
}

SortDescending(ByRef list, type := "MERGE") {
	return __Sort(list, 1, list.MaxIndex(), "CompareDescending", type, tracking)
}

SortBy(ByRef list, comparator, type := "MERGE", tracking := 1) {
	return __Sort(list, 1, list.MaxIndex(), comparator, type, tracking)
}

CompareAscending(left, right) {
	what := ""
	
	if (left < right) {
		what := -1
	} else if (left > right) {
		what := 1
	} else {
		what := 0
	}
	
	return what
}

CompareDescending(left, right) {
	return CompareAscending(right, left)
}

Swap(ByRef list, first, secnd, tracking) {
	if (tracking) {
		TrackingCounter.GetTrackingCounters()[1].AddComment(Format(" Swap {1} and {2}.", first, secnd))
	}
	
	what := list[first]
	list[first] := list[secnd]
	list[secnd] := what
}

__Sort(ByRef list, start, end, comparator, type, tracking) {
	StringUpper, type, type
	sort_proc := ""
	what := ""
	
	if (type = "MERGE") {
		what := __MergeSort(list, start, end, comparator, tracking)
	} else if (type = "LQUICK") {
		what := __LomutoQuickSort(list, start, end, comparator, tracking)
	} else if (type = "HQUICK") {
		what := __HoareQuickSort(list, start, end, comparator, tracking)
	}
	
	return what
}

__LomutoQuickSort(ByRef list, start, end, comparator, tracking) {
	if (start < end) {
		pos := __LomutoPartition(list, start, end, comparator, tracking)
		__LomutoQuickSort(list, start, pos - 1, comparator, tracking)
		__LomutoQuickSort(list, pos + 1, end, comparator, tracking)
	}
	
	return list
}

CName(name, name_with_arrow, show_arrows) {
	return show_arrows ? name_with_arrow : name
}

__LomutoPartition(ByRef list, start, end, comparator, tracking) {
	global
	
	if (tracking) {
		p := New TrackingCounter(end, "p")
		i := New TrackingCounter(start - 1, CName("i", "i->", __show_arrows))
		j := New TrackingCounter(start, CName("j", "j->", __show_arrows))
	} else {
		p := New Counter(end)
		i := New Counter(start - 1)
		j := New Counter(start)
	}
	
	pivot := list[p.Get()]
	
	while (j.Get() <= end - 1) {
		if (InvokeCompare(comparator, list[j.Get()], pivot) <= 0) {
			i.Increment()
			Swap(list, i.Get(), j.Get(), tracking)
		}
		
		j.Increment()
	}
	
	i := i.Get()
	Swap(list, i + 1, end, tracking)
	
	if (tracking) {
		TrackingCounter.Consume()
		TrackingCounter.AddCommentLine("")
	}
	
	return i + 1
}

__HoareQuickSort(ByRef list, start, end, comparator, tracking) {
	if (start < end) {
		pos := __HoarePartition(list, start, end, comparator, tracking)
		__HoareQuickSort(list, start, pos, comparator, tracking)
		__HoareQuickSort(list, pos + 1, end, comparator, tracking)
	}
	
	return list
}

__HoarePartition(ByRef list, start, end, comparator, tracking) {
	global
	
	if (tracking) {
		p := New TrackingCounter(Floor((start + end)/2), "p")
		i := New TrackingCounter(start - 1, CName("i", "i->", __show_arrows))
		j := New TrackingCounter(end + 1, CName("j", "<-j", __show_arrows))
	} else {
		p := New Counter(Floor((start + end)/2))
		i := New Counter(start - 1)
		j := New Counter(end + 1)
	}
	
	pivot := list[p.Get()]
	
	loop {
		loop {
			i.Increment()
		} until (InvokeCompare(comparator, list[i.Get()], pivot) >= 0)
		
		loop {
			j.Decrement()
		} until (InvokeCompare(comparator, list[j.Get()], pivot) <= 0)
		
		if (i.Get() >= j.Get()) {
			j := j.Get()
			
			if (tracking) {
				TrackingCounter.Consume()
				TrackingCounter.AddCommentLine("")
			}
			
			return j
		}
		
		Swap(list, i.Get(), j.Get(), tracking)
	}
}

__MergeSort(ByRef list, start, end, comparator, tracking) {
	if (start < end) {
		mid := Floor((start + end)/2)
		__MergeSort(list, start, mid, comparator, tracking)
		__MergeSort(list, mid + 1, end, comparator, tracking)
		__Merge(list, start, mid, end, comparator, tracking)
	}
	
	return list
}

__Merge(ByRef list, start, mid, end, comparator, tracking) {
	global
	
	if (tracking) {
		cmid := New TrackingCounter(mid, CName("m", "m->", __show_arrows))
		cleft := New TrackingCounter(start, CName("le", "le->", __show_arrows))
		cright := New TrackingCounter(mid + 1, CName("ri", "ri->", __show_arrows))
	} else {
		cmid := New Counter(mid)
		cleft := New Counter(start)
		cright := New Counter(mid + 1)
	}
	
	if (InvokeCompare(comparator, list[cmid.Get()], list[cright.Get()]) > 0) {
		while (cleft.Get() <= cmid.Get() and cright.Get() <= end) {
			if (InvokeCompare(comparator, list[cleft.Get()], list[cright.Get()]) <= 0) {
				cleft.Increment()
			} else {
				if (tracking) {
					cindex := New TrackingCounter(cright.Get(), CName("i", "<-i", __show_arrows))
					what := list[cright.Get()]
					cindex.AddComment(Format(" temp <- [{1}]", cright.Get()))
					
					while (cindex.Get() <> cleft.Get()) {
						list[cindex.Get()] := list[cindex.Get() - 1]
						cindex.AddComment(Format(" <- [{1}]", cindex.Get() - 1))
						cindex.Decrement()
					}
					
					list[cleft.Get()] := what
					cindex.AddComment(Format(";  [{1}] <- temp", cleft.Get()))
					cindex.End()
				} else {
					index := cright.Get()
					what := list[cright.Get()]
					
					while (index <> cleft.Get()) {
						list[index] := list[index - 1]
						index := index - 1
					}
					
					list[cleft.Get()] := what
				}
				
				cmid.Increment()
				cleft.Increment()
				cright.Increment()
			}
		}
	}
	
	if (tracking) {
		TrackingCounter.Consume()
		TrackingCounter.AddCommentLine("")
	}
}

InvokeCompare(comparator_name, left_arg, right_arg) {
	return Func(comparator_name).Bind(left_arg, right_arg).Call()
}

AlignItem(payload, width) {
	return Format("{:" width "}", payload)
}

SublistToAlignedString(list, width, start, end) {
	out_str := ""
	i := start
	
	while (i < end) {
		out_str .= AlignItem(list[i], width)
		i := i + 1
	}
	
	if (list.MaxIndex() >= 1)
		out_str .= AlignItem(list[i], width)
		
	return out_str
}

SublistToDelimitedString(list, delim, start, end) {
	out_str := ""
	i := start
	
	while (i < end) {
		out_str .= list[i] . delim
		i := i + 1
	}
	
	if (list.MaxIndex() >= 1)
		out_str .= list[i]
		
	return out_str
}

ListToAlignedString(list, width) {
	return SublistToAlignedString(list, width, 1, list.MaxIndex())
}

ListToDelimitedString(list, delim) {
	return SublistToDelimitedString(list, delim, 1, list.MaxIndex())
}

GetList(in_str, ByRef list, ByRef delim) {
	word := ""
	
	; Start a new list
	list := []
	
	; Get the first word
	next := RegExMatch(in_str, "-\d+|\w+", word)
	
	; Get the delimiter
	RegExMatch(in_str, "(?<=_|[0-9]|[A-Z]|[a-z])\W+\d?", delim, next + StrLen(word))  ; This is stupid.
	delim := RegExReplace(delim, "-?\d")
	
	while (next <> 0) {
		; Add word to the list
		list.Push(word)
		
		; Get next word
		next := RegExMatch(in_str, "-\d+|\w+", word, next + StrLen(word))
	}
	
	return list
}

;;;;;;;;;;;;;;;;;;;;;;
; --- Hotstrings --- ;
;;;;;;;;;;;;;;;;;;;;;;


; Without Tracking
;;;;;;;;;;;;;;;;;;

; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;ascm;::
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "MERGE")
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;descm;::
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "MERGE")
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;ascql;::
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "LQUICK")
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;descql;::
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "LQUICK")
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;ascqh;::
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "HQUICK")
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;descqh;::
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "HQUICK")
    return
    
	
; With Tracking
;;;;;;;;;;;;;;;

; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;track ascm;::
	__show_arrows := 0
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "MERGE", "", __ALIGN_LEN, 1)
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;track descm;::
	__show_arrows := 0
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "MERGE", "", __ALIGN_LEN, 1)
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;track ascql;::
	__show_arrows := 0
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "LQUICK", "", __ALIGN_LEN, 1)
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;track descql;::
	__show_arrows := 0
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "LQUICK", "", __ALIGN_LEN, 1)
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;track ascqh;::
	__show_arrows := 0
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "HQUICK", "", __ALIGN_LEN, 1)
    return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;track descqh;::
	__show_arrows := 0
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "HQUICK", "", __ALIGN_LEN, 1)
    return
    
	
; With Tracking & Arrows
;;;;;;;;;;;;;;;;;;;;;;;;

; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;arrow ascm;::
	__show_arrows := 1
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "MERGE", "", __ALIGN_LEN, 1)
    __show_arrows := 0
	return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;arrow descm;::
	__show_arrows := 1
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "MERGE", "", __ALIGN_LEN, 1)
    __show_arrows := 0
	return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;arrow ascql;::
	__show_arrows := 1
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "LQUICK", "", __ALIGN_LEN, 1)
    __show_arrows := 0
	return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;arrow descql;::
	__show_arrows := 1
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "LQUICK", "", __ALIGN_LEN, 1)
    __show_arrows := 0
	return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;arrow ascqh;::
	__show_arrows := 1
	Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareAscending", "HQUICK", "", __ALIGN_LEN, 1)
    __show_arrows := 0
	return
    
; Replace clipboard with a descending sorted list of the items on the clipboard
:*:;arrow descqh;::
	__show_arrows := 1
    Monitor.SendToClipboard("StringToSortedListString", Clipboard, "CompareDescending", "HQUICK", "", __ALIGN_LEN, 1)
    __show_arrows := 0
	return
    
	
;;;;;;;;;;;;;;;;
; --- Test --- ;
;;;;;;;;;;;;;;;;

; list := GetList("_1234 ... _21_ - 20 - asdf 14 , 91", list, delim)
; list := SortAscending(list)
; 
; MsgBox, % "[" ListToString(list, delim) "]"
; 
; GetList("1234 ... 21 - 20 - 19 0 3 14 , 91  5 51", list, delim)
; SortAscending(list)
; 
; MsgBox, % "[" ListToString(list, delim) "]"




