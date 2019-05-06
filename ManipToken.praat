####
#### Praat script ManipulateToken
#### Dan Villarreal
####
#### This script hosts a function that manipulates a single token
#### by specified F1, F2, F3, F4, and/or F5 differences. It iterates formant
#### increases by small formant steps (manipulation intervals, which work well
#### as JNDs) specified by the user. This interval approach drastically improves
#### accuracy of the manipulation process, relative to doing the manipulation 
#### all at once. This interval approach also necessitates doing the manipulation 
#### formant-by-formant rather than all at once; this can be done starting with
#### the lowest or highest formant.
####

include ManipulateVowelsGetIngredientsProc.praat
include CloneIntensityProc.praat

##Recommended values of the following input parameters:
# buffer = 0.05
# timeStep = 0.005
# maxIntensity = 100

procedure manipulateToken: oldToken, maxFreq, numForms, manipType$, f1_manip, f2_manip, f3_manip, f4_manip, f5_manip, start_with_highest_formant, measPoint, manipulation_interval, buffer, minPitch, timeStep, maxIntensity, print_information_on_tokens$
	manipType$ = replace_regex$(manipType$, "(.)", "\l\1", 0)
	if not (manipType$ = "absolute" or manipType$ = "abs" or manipType$ = "relative" or manipType$ = "rel") 
		exitScript: "Invalid manipType$ value. Must be 'abs[olute]' or 'rel[ative]'."
	endif
	manipCt = 1
	token[manipCt] = oldToken
	
	##Print verbose monitor details
	if print_information_on_tokens$ = "verbose"
		appendInfoLine: "Formant", tab$, "Manip#", tab$, "Current", tab$, "Target", tab$, "Diff", tab$, "Intvl"
	endif
	
	##Iterate manipulation over each formant
	for fmt from 1 to 5
		##If starting with highest formant, iterate from F5 to F1; otherwise, F1 to F5
		if start_with_highest_formant
			manipFmt = 6 - fmt
		else
			manipFmt = fmt
		endif
		
		##Manipulate only if desired increase is nonzero
		if not f'manipFmt'_manip = undefined
			manipCtFmt[manipFmt] = 1
			
			##Get measurement points
			@getIngredients: token[manipCt], maxFreq, numForms, buffer, measPoint
			selectObject: formantObj
			origF'manipFmt' = Get value at time: manipFmt, vowelMeasPoint, "Hertz", "Linear"
			
			if manipType$ = "absolute" or manipType$ = "abs"
				desired_F'manipFmt' = f'manipFmt'_manip
				f'manipFmt'_increase = desired_F'manipFmt' - origF'manipFmt'
			elsif manipType$ = "relative" or manipType$ = "rel"
				f'manipFmt'_increase = f'manipFmt'_manip
				desired_F'manipFmt' = origF'manipFmt' + f'manipFmt'_increase
			endif
			newF'manipFmt'[manipCt] = origF'manipFmt'
			
			##Track remaining increase, initialized as overall desired increase
			remainingIncr = f'manipFmt'_increase
			##While loop runs as long as the remaining formant increase is
			##larger in magnitude than the manipulation interval (JND)
			while abs(remainingIncr) >= manipulation_interval
				if print_information_on_tokens$ = "verbose"
					appendInfoLine: manipFmt, tab$, manipCtFmt[manipFmt], tab$, fixed$(newF'manipFmt'[manipCt],2), tab$, fixed$(desired_F'manipFmt',2), tab$, fixed$(remainingIncr,2), tab$, fixed$(manipulation_interval,2)
				endif
				##Determine magnitude and sign of manipulation and perform manipulation
				manip = manipulation_interval * (remainingIncr/abs(remainingIncr))
				selectObject: formantObj
				Formula (frequencies): "if row = " + string$(manipFmt) + " then self + " + string$(manip) + " else self fi"
				newObjValue = Get value at time: manipFmt, vowelMeasPoint, "Hertz", "Linear"
				selectObject: source, formantObj
				manipCt += 1
				manipCtFmt[manipFmt] += 1
				sourceFilter = Filter
				Rename: "sourceFilter"
				token[manipCt] = Resample: sampFreq, 50
				Rename: "token_'manipCt'"
				Scale intensity: loudnessLow
				##Determine remaining formant increase.
				selectObject: token[manipCt]
				formant = To Formant (burg): 0, numForms, maxFreq, 0.025, 50
				newF'manipFmt'[manipCt] = Get value at time: manipFmt, vowelMeasPoint, "Hertz", "Linear"
				remainingIncr = desired_F'manipFmt' - newF'manipFmt'[manipCt]
				removeObject: formant, sourceFilter
				if token[manipCt-1] <> oldToken
					removeObject: token[manipCt-1]
				endif
			endwhile
			
			##Once remaining formant increase is smaller in magnitude than
			##the manipulation interval (JND), get the rest of the way.
			if print_information_on_tokens$ = "verbose"
				appendInfoLine: manipFmt, tab$, manipCtFmt[manipFmt], tab$, fixed$(newF'manipFmt'[manipCt],2), tab$, fixed$(desired_F'manipFmt',2), tab$, fixed$(remainingIncr,2), tab$, fixed$(manipulation_interval,2)
			endif
			selectObject: formantObj
			Formula (frequencies): "if row = " + string$(manipFmt) + " then self + " + string$(remainingIncr) + " else self fi"
			newObjValue = Get value at time: manipFmt, vowelMeasPoint, "Hertz", "Linear"
			selectObject: source, formantObj
			sourceFilter = Filter
			Rename: "sourceFilter"
			newToken = Resample: sampFreq, 50
			Rename: "newToken"
			Scale intensity: loudnessLow
			manipCt += 1
			manipCtFmt[manipFmt] += 1
			selectObject: newToken
			formant = To Formant (burg): 0, numForms, maxFreq, 0.025, 50
			newF'manipFmt'[manipCt] = Get value at time: manipFmt, vowelMeasPoint, "Hertz", "Linear"
			remainingIncr = desired_F'manipFmt' - newF'manipFmt'[manipCt]
			if print_information_on_tokens$ = "verbose"
				appendInfoLine: manipFmt, tab$, manipCtFmt[manipFmt], tab$, fixed$(newF'manipFmt'[manipCt],2), tab$, fixed$(desired_F'manipFmt',2), tab$, fixed$(remainingIncr,2), tab$, fixed$(manipulation_interval,2)
			endif
			##In case the latest version of the vowel is actually further off-target
			##than the previous version, discard the latest version in favor of the
			##penultimate version.
			
			
			removeObject: formant, sourceFilter
			if abs(desired_F'manipFmt' - newF'manipFmt'[manipCt]) > abs(desired_F'manipFmt' - newF'manipFmt'[manipCt-1])
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
			remainingIncr = desired_F'manipFmt' - newF'manipFmt'[manipCt]

			
			
			##Add high-frquency portion of the signal back in
			selectObject: token[manipCt]
			Formula: "self[col] + Sound_highFreq[col]"
			
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
		##if not f'manipFmt'_manip = undefined
		endif
	##for fmt from 1 to 5
	endfor
	
	##Measure output tokens
	selectObject: token[manipCt]
	newFormantObj = To Formant (burg): 0, numForms, maxFreq, 0.025, 50
	newF1 = Get value at time: 1, vowelMeasPoint, "Hertz", "Linear"
	newF2 = Get value at time: 2, vowelMeasPoint, "Hertz", "Linear"
	newF3 = Get value at time: 3, vowelMeasPoint, "Hertz", "Linear"
	newF4 = Get value at time: 4, vowelMeasPoint, "Hertz", "Linear"
	newF5 = Get value at time: 5, vowelMeasPoint, "Hertz", "Linear"
	
	##Print monitor details on final manip
	if print_information_on_tokens$ = "verbose" or print_information_on_tokens$ = "succinct"
		appendInfoLine: "Formant", tab$, "#Manips", tab$, "Orig", tab$, "Final", tab$, "Diff", tab$, "Target", tab$, "Off-Target"
		
		for fmt from 1 to 5
			if start_with_highest_formant
				manipFmt = 6 - fmt
			else
				manipFmt = fmt
			endif
			
			if not f'manipFmt'_manip = undefined
				appendInfoLine: manipFmt, tab$, manipCtFmt[manipFmt], tab$, fixed$(origF'manipFmt',2), tab$, fixed$(newF'manipFmt',2), tab$, fixed$(newF'manipFmt'-origF'manipFmt',2), tab$, fixed$(desired_F'manipFmt',2), tab$, fixed$(desired_F'manipFmt'-newF'manipFmt',2)
			endif
		endfor
	endif
	
	
	
	removeObject: newFormantObj
endproc
