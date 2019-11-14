
class Counter
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- CLASS PARAMETERS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	static __PLACEHOLDER := "<Null>"
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- DYNAMIC MEMBERS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	__payload := Counter.__PLACEHOLDER
	
	;;;;;;;;;;;;;;;;;;;;;;;;
	; --- CONSTRUCTORS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	__New(payload) {
		this.__payload := payload
	}
	
	InstanceMethod() {
		if (this.__payload = Counter.__PLACEHOLDER) {
			throw Exception("OBJECT NOT INITIALIZED")
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- STATIC METHODS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; Named Constructors
	;;;;;;;;;;;;;;;;;;;;
	
	ConstructCounter(payload) {
		obj := New Counter(payload)
		return obj
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- DYNAMIC METHODS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Get() {
		this.InstanceMethod()
		return this.__payload
	}
	
	Set(payload) {
		this.InstanceMethod()
		this.__payload := payload
	}
	
	Increment() {
		this.InstanceMethod()
		this.Set(this.Get() + 1)  ; Calls `this.InstanceMethod()`
	}
	
	Decrement() {
		this.InstanceMethod()
		this.Set(this.Get() - 1)  ; Calls `this.InstanceMethod()`
	}
}

class TrackingCounter
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- CLASS PARAMETERS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	static __LEN := 4
	static __PLACEHOLDER := "<Null>"
	static __POSITIONS := 30
	static __INDENT := Format("{:12}", " ")
	static __BAR := Format("{:" (StrLen(TrackingCounter.__INDENT) + TrackingCounter.__POSITIONS * TrackingCounter.__LEN) "}", " ")
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- STATIC MEMBERS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	static __out_str := ""
	static __counters := []
	static __map := {}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- DYNAMIC MEMBERS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	__counter := "<Null>"
	__name := TrackingCounter.__PLACEHOLDER
	__str := ""
	
	;;;;;;;;;;;;;;;;;;;;;;;;
	; --- CONSTRUCTORS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	__New(payload, name) {
		this.__counter := New Counter(payload)
		this.__name := name
		this.__str := TrackingCounter.__BAR
		
		this.Displace(payload)
		
		TrackingCounter.__counters.Push(this)
		TrackingCounter.__map[name] := this
	}
	
	InstanceMethod() {
		if (this.__counter = Counter.__PLACEHOLDER) {
			throw Exception("OBJECT NOT INITIALIZED")
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- STATIC METHODS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	GetIndent() {
		return TrackingCounter.__INDENT
	}
	
	SetSegmentLength(len) {
		TrackingCounter.__LEN := len
	}
	
	SetNumberLineLimit(limit) {
		TrackingCounter.__POSITIONS := limit
	}
	
	NewNumberLine() {
		numbers := TrackingCounter.__INDENT
		index := 1
		
		while (index <= TrackingCounter.__POSITIONS) {
			numbers .= Format("{:" TrackingCounter.__LEN "}", index)
			index := index + 1
		}
		
		return numbers
	}
	
	GetDisplacementPattern(bar, init, len, pos, name) {
		replacement := Format(Format("{:{1}}", len), name)
		
		if (pos > 0) {
			pattern := Format("(?<=^.{{1}}.{{2}}).{{3}}", StrLen(init), len * (pos - 1), len)
		} else {
			pattern := Format("(?<=^.{{1}}).{{2}}", StrLen(init) + (len * (pos - 1)), len)
		}
		
		return RegExReplace(bar, pattern, replacement)
	}
	
	EndAll() {
		for index, c in TrackingCounter.__counters {
			c.End()
		}
	}
	
	Reset() {
		TrackingCounter.EndAll()
		TrackingCounter.__out_str := ""
	}
	
	Consume() {
		TrackingCounter.EndAll()
		TrackingCounter.__counters := []
		TrackingCounter.__map := {}
	}
	
	GetTrackingCounters() {
		return TrackingCounter.__counters
	}
	
	GetTrackingCounter(name) {
		return TrackingCounter.__map[name]
	}
	
	GetMap() {
		return TrackingCounter.__map
	}
	
	GetTrackingString() {
		return TrackingCounter.__out_str
	}
	
	AddCommentLine(comment) {
		TrackingCounter.__out_str .= comment . "`r`n"
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; --- DYNAMIC METHODS --- ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	NextLine() {
		; ; TEST
		; ; ----
		; MsgBox, % "NextLine1: [" this.__name "] [" this.__str "]`r`n`r`nTracking String:`r`n" TrackingCounter.__out_str
		
		this.InstanceMethod()
		TrackingCounter.__out_str .= this.__str . "`r`n"
		
		; ; TEST
		; ; ----
		; MsgBox, % "NextLine2: [" this.__name "] [" this.__str "]`r`n`r`nTracking String:`r`n" TrackingCounter.__out_str
		
		this.__str := TrackingCounter.__BAR
	}
	
	Displace(pos) {
		this.InstanceMethod()
		this.__str := TrackingCounter.GetDisplacementPattern(this.__str, TrackingCounter.__INDENT, TrackingCounter.__LEN, pos, this.__name)
	}
	
	Get() {
		return this.__counter.Get()
	}
	
	GetName() {
		return this.__name
	}
	
	Set(payload) {
		this.__counter.Set(payload)  ; Calls `this.InstanceMethod()`
		this.NextLine()
		this.Displace(payload)
	}
	
	Increment() {
		this.__counter.Increment()
		this.Displace(this.Get())
	}
	
	Decrement() {
		this.__counter.Decrement()
		this.Displace(this.Get())
	}
	
	End() {
		this.NextLine()  ; Calls `this.InstanceMethod()`
		this.__str := __PLACEHOLDER
		return this.Get()
	}
	
	AddComment(comment) {
		this.InstanceMethod()
		this.__str .= comment
	}
}


;;;;;;;;;;;;;;;;
; --- TEST --- ;
;;;;;;;;;;;;;;;;

; in := Format("{:8}", " ")
; len := 4
; bar := Format("{:80}", " ")
; name := "CT"
; ; pos := 3
; 
; ; RegExReplace(s, "(?<=(INIT)(space * 4 * (pos - 1)))(space * 4)", name)
; 
; ; str := RegExReplace(s, Format("(?<={1}{2}){3}", in, Format(" {d}", len * (pos - 1)), Format(" {d}", len)), name)
; 
; 
; 
; GetDisplacementPattern(bar, init, len, pos, name) {
; 	replacement := Format(Format("{:{1}}", len), name)
; 	pattern := Format("(?<=^{1} {{2}}) {{3}}", init, len * (pos - 1), len)
; 	return RegExReplace(bar, pattern, replacement)
; }
; 
; out .= "`r`n[" . GetDisplacementPattern(bar, in, 4, 7, name) . "]"
; out .= "`r`n[" . GetDisplacementPattern(bar, in, 4, 6, name) . "]"
; out .= "`r`n[" . GetDisplacementPattern(bar, in, 4, 5, name) . "]"
; out .= "`r`n[" . GetDisplacementPattern(bar, in, 4, 3, name) . "]"
; 
; Clipboard := out


; c := New TrackingCounter(0, "le")
; d := New TrackingCounter(10, "ri")
; 
; c.Increment()
; 
; d.Decrement()
; 
; c.Increment()
; c.Increment()
; 
; d.Decrement()
; d.Decrement()
; 
; c.Increment()
; 
; c.Set(1)
; 
; d.Set(9)
; 
; c.Increment()
; c.Increment()
; c.Increment()
; c.Increment()
; 
; d.Decrement()
; d.Decrement()
; d.Decrement()
; 
; Clipboard := TrackingCounter.GetTrackingString()




