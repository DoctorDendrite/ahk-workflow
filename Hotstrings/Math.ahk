#Include %A_ScriptDir%\Monitor.ahk
#Persistent
#SingleInstance Force


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

; Replace the pattern -?\d+..-?\d+ in the clipboard with list of numbers
:*:;numbers;::
	Monitor.Clip("ToList", Clipboard)
	return
	
; Replace the hotstring with a combination (binomial coefficient) using the first two
; separated numbers on the clipboard
:*:;choose;::
	Monitor.Run("ToCombination", Clipboard)
	return
	
; Replace the hotstring with an arragement using the first two separated numbers on
; the clipboard
:*:;arrange;::
	Monitor.Run("ToArrangement", Clipboard)
	return
	
	
; General
;;;;;;;;;

; (–) En dash
:*:;--;::
    Monitor.Send("{U+2013}") ; –
    return
    
; (—) Em dash
:*:;---;::
    Monitor.Send("{U+2014}") ; —
    return
    
    
; Mathematical
;;;;;;;;;;;;;;

; (→) Arrow
:*:;-.;::
    Monitor.Send("{U+2192}") ; →
    return
    
; (←) Back arrow
:*:;,-;::
    Monitor.Send("{U+2190}") ; ←
    return
    
; (✕) Multiplication sign
:*:;x;::
    Monitor.Send("{U+2715}") ; ✕
    return
    
; (−) Minus sign
:*:;-;::
    Monitor.Send("{U+2212}") ; −
    return
    
; (¬) Negation
:*:;not;::
    Monitor.Send("{U+00AC}") ; ¬
    return
    
; (≠) Not equal
:*:;ne;::
    Monitor.Send("{U+2260}") ; ≠
    return
    
; (≤) Less than or equal
:*:;le;::
    Monitor.Send("{U+2264}") ; ≤
    return
    
; (≥) Greater than or equal
:*:;ge;::
    Monitor.Send("{U+2265}") ; ≥
    return
    
; (⇔) Material equivalence
:*:;means;::
    Monitor.Send("{U+21D4}") ; ⇔
    return
    
; (∧) Logical conjunction (Wedge, Ac, Atque)
:*:;and;::
    Monitor.Send("{U+2227}") ; ∧
    return
    
; (∨) Logical disjunction (Vel)
:*:;or;::
    Monitor.Send("{U+2228}") ; ∨
    return
    
; (∀) Universal quantifier
:*:;all;::
    Monitor.Send("{U+2200}") ; ∀
    return
    
; (∇) Nabla (Del)
:*:;del;::
    Monitor.Send("{U+007F}") ; ∇
    return
    
; (∞) Infinity
:*:;inf;::
    Monitor.Send("{U+221E}") ; ∞
    return
    
    
; Mathematical Extended
;;;;;;;;;;;;;;;;;;;;;;;

; (∈) Is an element of
:*:;in;::
    Monitor.Send("{U+2208}") ; ∈
    return
    
; (∉) Is not an element of
:*:;nin;::
    Monitor.Send("{U+2209}") ; ∉
    return
    
; (∃) Existential quantifier
:*:;some;::
    Monitor.Send("{U+2203}") ; ∃
    return
    
    
; Greek Alphabet
;;;;;;;;;;;;;;;;

; (Δ) Upper delta
:c*:;Delt;::
    Monitor.Send("{U+0394}") ; Δ
    return
    
; (δ) Lower delta
:c*:;delt;::
    Monitor.Send("{U+03B4}") ; δ
    return
    
; (Ο) Upper omicron
:c*:;Omic;::
    Monitor.Send("{U+039F}") ; Ο
    return
    
; (ο) Lower omicron
:c*:;omic;::
    Monitor.Send("{U+03BF}") ; ο
    return
    
; (Ω) Upper omega
:c*:;Omeg;::
    Monitor.Send("{U+03A9}") ; Ω
    return
    
; (ω) Lower omega
:c*:;omeg;::
    Monitor.Send("{U+03C9}") ; ω
    return
    
; (Θ) Upper theta
:c*:;Thet;::
    Monitor.Send("{U+0398}") ; Θ
    return
    
; (θ) Lower theta
:c*:;thet;::
    Monitor.Send("{U+03B8}") ; θ
    return
    
; (ϑ) Cursive theta
:c*:;cthet;::
    Monitor.Send("{U+03D1}") ; ϑ
    return
    