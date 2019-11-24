#SingleInstance Force
#Persistent
#Include %A_ScriptDir%\Monitor.ahk


; **********************
; * --- DICTIONARY --- *
; **********************

if (!__names) {
	__names:= {}
}
if (!__help) {
	__help:= {}
}
__names["numbers"] := "function_0000"
__names["choose"] := "function_0001"
__names["arrange"] := "function_0002"
__names["--"] := "function_0003"
__names["---"] := "function_0004"
__names["-."] := "function_0005"
__names[",-"] := "function_0006"
__names["x"] := "function_0007"
__names["-"] := "function_0008"
__names["not"] := "function_0009"
__names["ne"] := "function_0010"
__names["le"] := "function_0011"
__names["ge"] := "function_0012"
__names["means"] := "function_0013"
__names["and"] := "function_0014"
__names["or"] := "function_0015"
__names["all"] := "function_0016"
__names["del"] := "function_0017"
__names["inf"] := "function_0018"
__names["in"] := "function_0019"
__names["nin"] := "function_0020"
__names["some"] := "function_0021"
__names["Delt"] := "function_0023"
__names["delt"] := "function_0023"
__names["Omic"] := "function_0025"
__names["omic"] := "function_0025"
__names["Omeg"] := "function_0027"
__names["omeg"] := "function_0027"
__names["Thet"] := "function_0029"
__names["thet"] := "function_0029"
__names["cthet"] := "function_0030"
__help["numbers"] := "Hotstring: Replace the pattern -?\d+..-?\d+ in the clipboard with list of numbers"
__help["choose"] := "Hotstring: Replace the hotstring with a combination (binomial coefficient) using the first two separated numbers on the clipboard"
__help["arrange"] := "Hotstring: Replace the hotstring with an arragement using the first two separated numbers on the clipboard"
__help["--"] := "Hotstring: (–) En dash"
__help["---"] := "Hotstring: (—) Em dash"
__help["-."] := "Hotstring: (→) Arrow"
__help[",-"] := "Hotstring: (←) Back arrow"
__help["x"] := "Hotstring: (✕) Multiplication sign"
__help["-"] := "Hotstring: (−) Minus sign"
__help["not"] := "Hotstring: (¬) Negation"
__help["ne"] := "Hotstring: (≠) Not equal"
__help["le"] := "Hotstring: (≤) Less than or equal"
__help["ge"] := "Hotstring: (≥) Greater than or equal"
__help["means"] := "Hotstring: (⇔) Material equivalence"
__help["and"] := "Hotstring: (∧) Logical conjunction (Wedge, Ac, Atque)"
__help["or"] := "Hotstring: (∨) Logical disjunction (Vel)"
__help["all"] := "Hotstring: (∀) Universal quantifier"
__help["del"] := "Hotstring: (∇) Nabla (Del)"
__help["inf"] := "Hotstring: (∞) Infinity"
__help["in"] := "Hotstring: (∈) Is an element of"
__help["nin"] := "Hotstring: (∉) Is not an element of"
__help["some"] := "Hotstring: (∃) Existential quantifier"
__help["Delt"] := "Hotstring: (δ) Lower delta"
__help["delt"] := "Hotstring: (δ) Lower delta"
__help["Omic"] := "Hotstring: (ο) Lower omicron"
__help["omic"] := "Hotstring: (ο) Lower omicron"
__help["Omeg"] := "Hotstring: (ω) Lower omega"
__help["omeg"] := "Hotstring: (ω) Lower omega"
__help["Thet"] := "Hotstring: (θ) Lower theta"
__help["thet"] := "Hotstring: (θ) Lower theta"
__help["cthet"] := "Hotstring: (ϑ) Cursive theta"




; **********************
; * --- MAIN ENTRY --- *
; **********************

Call(key) {
    global
    Func(__names[key]).Call()
}

Show(command, key) {
    global
    StringUpper, command, command

    if (command = "HELP") {
        MsgBox, % __help[key]
    }
}

Main() {
    params := []

    for index, param in A_Args {
        if (StrLen(param) > 0) {
            params.Push(param)
        }
    }

    if (params.MaxIndex() = 1) {
        Call(params[1])
        Monitor.Exit()
    } else if (params.MaxIndex() > 1) {
        Show(params[1], params[2])
        Monitor.Exit()
    }
}

Main()


; *******************
; * --- CONTENT --- *
; *******************

;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;


ToList(in_str) {
	position := RegExMatch(in_str, "O)(?<FIRST>-?\d+)..(?<SECND>-?\d+)", match)
	first := match.Value("FIRST")
	secnd := match.Value("SECND")
	
	if (!first or !secnd) {
		return ""
	}
	
	out_str := ""
	number := first
	
	if (first < secnd) {
		while (number <= secnd) {
			out_str .= Format("{1}`r`n", number)
			number := number + 1
		}
	} else {
		while (number >= secnd) {
			out_str .= Format("{1}`r`n", number)
			number := number - 1
		}
	}
	
	return out_str
}

NewMatrix(x, y, payload) {
	mat := []
	
	i := 1
	while (i <= x) {
		mat.Push([])
		j := 1
		while (j <= y) {
			mat[i].Push(payload)
			j := j + 1
		}
		i := i + 1
	}
	
	return mat
}

MatrixToString(mat) {
	str := ""
	i := 1
	while (i <= mat.MaxIndex()) {
		j := 1
		while (j <= mat[i].MaxIndex()) {
			str .= Format("{1} ", mat[i][j])
			j := j + 1
		}
		str .= "`r`n"
		i := i + 1
	}
	return str
}

Min(a, b) {
	if (a < b) {
		return a
	}
	
	return b
}

Combination(n, k) {
	mat := NewMatrix(n + 1, k + 1, 0)
	
	i := 1
	while (i <= mat.MaxIndex()) {
		j := 1
		while (j <= Min(i, k + 1)) {
			if (j = 1 or j = i) {
				mat[i][j] := 1
			} else {
				mat[i][j] := mat[i - 1][j - 1] + mat[i - 1][j]
			}
			j := j + 1
		}
		i := i + 1
	}
	
	return mat[n + 1][k + 1]
}

Arrangement(n, k) {
	mat := NewMatrix(n + 1, k + 1, 0)
	
	i := 1
	while (i <= mat.MaxIndex()) {
		j := 1
		while (j <= Min(i, k + 1)) {
			if (j = 1) {
				mat[i][j] := 1
			} else {
				mat[i][j] := (i - 1) * mat[i - 1][j - 1]
			}
			j := j + 1
		}
		i := i + 1
	}
	
	return mat[n + 1][k + 1]
}

ToCombination(in_str) {
	; position := RegExMatch(in_str, "O)C\((?<FIRST>-?\d+),\s*(?<SECND>-?\d+)\)", match)
	position := RegExMatch(in_str, "O)(?<FIRST>-?\d+)\D+(?<SECND>-?\d+)", match)
	first := match.Value("FIRST")
	secnd := match.Value("SECND")
	
	if (!first or !secnd) {
		return ""
	}
	
	return Combination(first, secnd)
}

ToArrangement(in_str) {
	; position := RegExMatch(in_str, "O)P\((?<FIRST>-?\d+),\s*(?<SECND>-?\d+)\)", match)
	position := RegExMatch(in_str, "O)(?<FIRST>-?\d+)\D+(?<SECND>-?\d+)", match)
	first := match.Value("FIRST")
	secnd := match.Value("SECND")
	
	if (!first or !secnd) {
		return ""
	}
	
	return Arrangement(first, secnd)
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Hotstrings --- ;
;;;;;;;;;;;;;;;;;;;;;;


; Procedural
;;;;;;;;;;;;
	
	
	
	
; General
;;;;;;;;;
    
    
    
; Mathematical
;;;;;;;;;;;;;;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
; Mathematical Extended
;;;;;;;;;;;;;;;;;;;;;;;
    
    
    
    
; Greek Alphabet
;;;;;;;;;;;;;;;;
    
    
    
    
    
    
    
    


; ***********************
; * --- DEFINITIONS --- *
; ***********************

function_0000() {
    global
	return Monitor.Clip("ToList", Clipboard)
}

function_0001() {
    global
	return Monitor.Run("ToCombination", Clipboard)
}

function_0002() {
    global
	return Monitor.Run("ToArrangement", Clipboard)
}

function_0003() {
    global
    return Monitor.SendUnicode("{U+2013}") ; –
}

function_0004() {
    global
    return Monitor.SendUnicode("{U+2014}") ; —
}

function_0005() {
    global
    return Monitor.SendUnicode("{U+2192}") ; →
}

function_0006() {
    global
    return Monitor.SendUnicode("{U+2190}") ; ←
}

function_0007() {
    global
    return Monitor.SendUnicode("{U+2715}") ; ✕
}

function_0008() {
    global
    return Monitor.SendUnicode("{U+2212}") ; −
}

function_0009() {
    global
    return Monitor.SendUnicode("{U+00AC}") ; ¬
}

function_0010() {
    global
    return Monitor.SendUnicode("{U+2260}") ; ≠
}

function_0011() {
    global
    return Monitor.SendUnicode("{U+2264}") ; ≤
}

function_0012() {
    global
    return Monitor.SendUnicode("{U+2265}") ; ≥
}

function_0013() {
    global
    return Monitor.SendUnicode("{U+21D4}") ; ⇔
}

function_0014() {
    global
    return Monitor.SendUnicode("{U+2227}") ; ∧
}

function_0015() {
    global
    return Monitor.SendUnicode("{U+2228}") ; ∨
}

function_0016() {
    global
    return Monitor.SendUnicode("{U+2200}") ; ∀
}

function_0017() {
    global
    return Monitor.SendUnicode("{U+007F}") ; ∇
}

function_0018() {
    global
    return Monitor.SendUnicode("{U+221E}") ; ∞
}

function_0019() {
    global
    return Monitor.SendUnicode("{U+2208}") ; ∈
}

function_0020() {
    global
    return Monitor.SendUnicode("{U+2209}") ; ∉
}

function_0021() {
    global
    return Monitor.SendUnicode("{U+2203}") ; ∃
}

function_0022() {
    global
    return Monitor.SendUnicode("{U+0394}") ; Δ
}

function_0023() {
    global
    return Monitor.SendUnicode("{U+03B4}") ; δ
}

function_0024() {
    global
    return Monitor.SendUnicode("{U+039F}") ; Ο
}

function_0025() {
    global
    return Monitor.SendUnicode("{U+03BF}") ; ο
}

function_0026() {
    global
    return Monitor.SendUnicode("{U+03A9}") ; Ω
}

function_0027() {
    global
    return Monitor.SendUnicode("{U+03C9}") ; ω
}

function_0028() {
    global
    return Monitor.SendUnicode("{U+0398}") ; Θ
}

function_0029() {
    global
    return Monitor.SendUnicode("{U+03B8}") ; θ
}

function_0030() {
    global
    return Monitor.SendUnicode("{U+03D1}") ; ϑ
}


; **********************
; * --- HOTSTRINGS --- *
; **********************

:*:;numbers;::
:*:;choose;::
:*:;arrange;::
:*:;--;::
:*:;---;::
:*:;-.;::
:*:;,-;::
:*:;x;::
:*:;-;::
:*:;not;::
:*:;ne;::
:*:;le;::
:*:;ge;::
:*:;means;::
:*:;and;::
:*:;or;::
:*:;all;::
:*:;del;::
:*:;inf;::
:*:;in;::
:*:;nin;::
:*:;some;::
:c*:;Delt;::
:c*:;delt;::
:c*:;Omic;::
:c*:;omic;::
:c*:;Omeg;::
:c*:;omeg;::
:c*:;Thet;::
:c*:;thet;::
:c*:;cthet;::
    Call(Trim(Monitor.GetHotkeyName(A_ThisHotkey), ";"))
    return
