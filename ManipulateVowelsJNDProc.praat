####
#### Praat script ManipulateVowelsJNDProc
#### Version 1.1a
#### Version date: December 3, 2017
#### Dan Villarreal
####
#### This script hosts a function that manipulates a single token
#### to a specified F1, F2, and/or F3 targets. It iterates formant
#### increases by small formant steps (just noticeable differences or
#### JNDs) specified by the user. This JND approach drastically improves
#### accuracy of the manipulation process. It also necessitates doing
#### the manipulation formant-by-formant rather than all at once.
####
#### Improves upon an earlier version by iterating the manipulation
#### of just the filter (i.e., the Formant object) rather than both 
#### the source and the filter.
####
#### This is a lightly modified version of 1.2 for sharing.
####

include ManipulateVowelsGetIngredientsProc.praat
include CloneIntensityProc.praat

##Recommended values of the following input parameters:
# buffer = 0.05
# timeStep = 0.005
# maxIntensity = 100

procedure manipulateVowels: oldToken, maxFreq, numForms, f1_increase,
... f2_increase, f3_increase, jnd, buffer, minPitch, timeStep, maxIntensity
	manipCt = 1
	token[manipCt] = oldToken
	
	##Iterate manipulation over each formant
	for fmt from 1 to 3
		manipFmt = 4 - fmt
		manipFCt = 1
		desired_F'manipFmt' = midpointF'manipFmt' + f'manipFmt'_increase
		
		##Set counters that will decrease in magnitude as manipulation proceeds.
		remainingIncr = f'manipFmt'_increase
		if abs(remainingIncr) > 0
			@getIngredients: token[manipCt], maxFreq, numForms, buffer
			newF'manipFmt'[manipCt] = midpointF'manipFmt'
			##While loop runs as long as the remaining formant increase is
			##larger in magnitude than the JND
			while abs(remainingIncr) >= jnd
				##Determine magnitude and sign of manipulation and perform manipulation
				manip = jnd * (remainingIncr/abs(remainingIncr))
				selectObject: formantObj
				Formula (frequencies): "if row = " + string$(manipFmt) + " then self + " + string$(manip) + " else self fi"
				newObjValue = Get value at time: manipFmt, vowelMid, "Hertz", "Linear"
				selectObject: source, formantObj
				manipCt += 1
				manipFCt += 1
				sourceFilter = Filter
				Rename: "sourceFilter"
				token[manipCt] = Resample: sampFreq, 50
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
			##the JND, get the rest of the way.
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
			manipFCt += 1
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
			@cloneIntensity: loudnessToken, token[manipCt], minPitch, timeStep, maxIntensity
			removeObject: loudnessToken
			if token[manipCt] <> oldToken
				removeObject: token[manipCt]
			endif
			token[manipCt] = endSound
	
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
	removeObject: newFormantObj
endproc
