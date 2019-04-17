####
#### Praat script ManipulateToken
#### Dan Villarreal
####
#### This script hosts a function that manipulates a single token
#### by specified F1, F2, F3, F4, and/or F5 differences. It iterates formant
#### increases by small formant steps (manipulation intervals, which work well
#### as JNDs) specified by the user. This interval approach drastically improves
#### accuracy of the manipulation process, relative to doing the manipulation all at once. It also necessitates doing
#### the manipulation formant-by-formant rather than all at once.
####
#### Improves upon an earlier version by iterating the manipulation
#### of just the filter (i.e., the Formant object) rather than both 
#### the source and the filter.
####

include ManipulateVowelsGetIngredientsProc.praat
include CloneIntensityProc.praat

##Recommended values of the following input parameters:
# buffer = 0.05
# timeStep = 0.005
# maxIntensity = 100

procedure manipulateToken: oldToken, maxFreq, numForms, manipType$, f1, f2, f3, f4, f5, start_with_highest_formant, manipulation_interval, buffer, minPitch, timeStep, maxIntensity, monitor
	manipType$ = replace_regex$(manipType$, "(.)", "\l\1", 0)
	if not (manipType$ = "absolute" or manipType$ = "abs" or manipType$ = "relative" or manipType$ = "rel") 
		exitScript: "Invalid manipType$ value. Must be 'abs[olute]' or 'rel[ative]'."
	endif
	manipCt = 1
	token[manipCt] = oldToken
	
	##Iterate manipulation over each formant
	for fmt from 1 to 5
		##If starting with highest formant, iterate from F5 to F1; otherwise, F1 to F5
		if start_with_highest_formant
			manipFmt = 6 - fmt
		else
			manipFmt = fmt
		endif
		manipCtFmt = 1
		
		##Manipulate only if desired increase is nonzero
		if not f'manipFmt' = undefined
			##Get midpoints
			@getIngredients: token[manipCt], maxFreq, numForms, buffer
			selectObject: formantObj
			midpointF'manipFmt' = Get value at time: manipFmt, vowelMid, "Hertz", "Linear"
			
			if manipType$ = "absolute" or manipType$ = "abs"
				desired_F'manipFmt' = f'manipFmt'
				f'manipFmt'_increase = desired_F'manipFmt' - midpointF'manipFmt'
			elsif manipType$ = "relative" or manipType$ = "rel"
				f'manipFmt'_increase = f'manipFmt'
				desired_F'manipFmt' = midpointF'manipFmt' + f'manipFmt'_increase
			endif
			newF'manipFmt'[manipCt] = midpointF'manipFmt'
			
			##Track remaining increase, initialized as overall desired increase
			remainingIncr = f'manipFmt'_increase
			##While loop runs as long as the remaining formant increase is
			##larger in magnitude than the manipulation interval (JND)
			while abs(remainingIncr) >= manipulation_interval
				if monitor
					appendInfoLine: tab$, manipCt, tab$, tab$, manipFmt, tab$, fixed$(newF'manipFmt'[manipCt],2), tab$, fixed$(desired_F'manipFmt',2), tab$, fixed$(manipulation_interval,2), tab$, fixed$(remainingIncr,2)
				endif
				##Determine magnitude and sign of manipulation and perform manipulation
				manip = manipulation_interval * (remainingIncr/abs(remainingIncr))
				selectObject: formantObj
				Formula (frequencies): "if row = " + string$(manipFmt) + " then self + " + string$(manip) + " else self fi"
				newObjValue = Get value at time: manipFmt, vowelMid, "Hertz", "Linear"
				selectObject: source, formantObj
				manipCt += 1
				manipCtFmt += 1
				sourceFilter = Filter
				Rename: "sourceFilter"
				token[manipCt] = Resample: sampFreq, 50
				Rename: "token_'manipCt'"
				Scale intensity: loudnessLow
				##Determine remaining formant increase.
				selectObject: token[manipCt]
				formant = To Formant (burg): 0, numForms, maxFreq, 0.025, 50
				newF'manipFmt'[manipCt] = Get value at time: manipFmt, vowelMid, "Hertz", "Linear"
				remainingIncr = desired_F'manipFmt' - newF'manipFmt'[manipCt]
				removeObject: formant, sourceFilter
				if token[manipCt-1] <> oldToken
					removeObject: token[manipCt-1]
				endif
			endwhile
			
			
			##Once remaining formant increase is smaller in magnitude than
			##the manipulation interval (JND), get the rest of the way.
			selectObject: formantObj
			Formula (frequencies): "if row = " + string$(manipFmt) + " then self + " + string$(remainingIncr) + " else self fi"
			newObjValue = Get value at time: manipFmt, vowelMid, "Hertz", "Linear"
			selectObject: source, formantObj
			sourceFilter = Filter
			Rename: "sourceFilter"
			newToken = Resample: sampFreq, 50
			Rename: "newToken"
			Scale intensity: loudnessLow
			manipCt += 1
			manipCtFmt += 1
			selectObject: newToken
			formant = To Formant (burg): 0, numForms, maxFreq, 0.025, 50
			newF'manipFmt'[manipCt] = Get value at time: manipFmt, vowelMid, "Hertz", "Linear"
			##In case the latest version of the vowel is actually further off-target
			##than the previous version, discard the latest version in favor of the
			##penultimate version.
			removeObject: formant, sourceFilter
			if abs(desired_F'manipFmt' - newF'manipFmt'[manipCt]) > remainingIncr
				k = manipCt-1
				token[manipCt] = token[k]
				if newToken <> oldToken
					removeObject: newToken
				endif
			else
				token[manipCt] = newToken
				if token[manipCt-1] <> oldToken
					removeObject: token[manipCt-1]
				endif
			endif
			##Add high-frquency portion of the signal back in
			selectObject: token[manipCt]
			Formula: "self[col] + Sound_highFreq[col]"
			remainingIncr = desired_F'manipFmt' - newF'manipFmt'[manipCt]
			
			##Run cloneIntensity procedure to clone intensity contour (which 
			##may have been affected by manipulation)
			if timeStep > 0
				@cloneIntensity: loudnessToken, token[manipCt], minPitch, timeStep, maxIntensity
				removeObject: loudnessToken
				if token[manipCt] <> oldToken
					removeObject: token[manipCt]
				endif
				token[manipCt] = endSound
			endif
	
			##Clean up created objects
			removeObject: highFreq, loudnessTokenNarrow, loudnessTokenLow, lowFreq, lpc, source, formantObj
		endif
	endfor
	##Measure output tokens
	selectObject: token[manipCt]
	newFormantObj = To Formant (burg): 0, numForms, maxFreq, 0.025, 50
	newF1 = Get value at time: 1, vowelMid, "Hertz", "Linear"
	newF2 = Get value at time: 2, vowelMid, "Hertz", "Linear"
	newF3 = Get value at time: 3, vowelMid, "Hertz", "Linear"
	newF4 = Get value at time: 4, vowelMid, "Hertz", "Linear"
	newF5 = Get value at time: 5, vowelMid, "Hertz", "Linear"
	removeObject: newFormantObj
endproc
