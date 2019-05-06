####
#### Praat script SmoothTransitionsProc
#### Dan Villarreal
####
#### Hosts a procedure, smoothTransitions, that smooths (smoothens?)
#### a formant into a linear contour. Ideal for dealing with formant
#### transitions that have been made discontinuous by formant manipulation.
#### The maximum frequency and number of formants must be specified for
#### segment preceding and following the break time, even if they are
#### the same as the token itself.
####

include ManipulateVowelsGetIngredientsProc.praat
include CloneIntensityProc.praat

procedure smoothTransitions: sound, time, smoothWindow, smoothFormant, maxFreq1, numFormants1, maxFreq2, numFormants2, buffer, minPitch
	##Get info on Sound
	selectObject: sound	
	soundName$ = selected$("Sound")
	soundStart = Get start time
	soundEnd = Get end time
	.monitorSmooth = 0
	if .monitorSmooth
		writeInfoLine: "SMOOTHING FORMANT 'smoothFormant'"
		appendInfoLine: "Start" + tab$ + "Frame" + tab$ + "F'smoothFormant'" + tab$ + "End" + tab$ + "Frame" + tab$ + "F'smoothFormant'"
	endif
	
	##Extract beforeToken
	selectObject: sound
	beforeToken = Extract part: soundStart, time - smoothWindow, "rectangular", 1.0, "yes"
	Rename: "beforeToken"
	
	##If max frequency and number of formants are the same for both segments, treat them as one segment.
	##Otherwise, manipulate the two segments separately.
	if (maxFreq1 = maxFreq2) and (numFormants1 = numFormants2)
		##Get formant measurements to determine slope and intercept of output formant contour
		@smoothMeasure: time - smoothWindow, time + smoothWindow, maxFreq1, numFormants1, smoothFormant, buffer, 1
		slope = (endFormant1-startFormant1)/(smoothWindow*2) * 0.005
		intercept = startFormant1 - slope*startFrame1
		if .monitorSmooth
			appendInfoLine: fixed$(time - smoothWindow,5) + tab$ + fixed$(startFrame1,4) + tab$ + fixed$(startFormant1,2) + tab$ + fixed$(time + smoothWindow,5) + tab$ + fixed$(endFrame1,4) + tab$ + fixed$(endFormant1,2)
			appendInfoLine: newline$ + "Slope: 'slope' Hz/frame"
			appendInfoLine: "Intercept: 'intercept' Hz"
		endif
		##Smooth out formant contour
		@smooth: time - smoothWindow, time + smoothWindow, smoothFormant, slope, intercept, minPitch, 1
	else
		##Get formant measurements to determine slope and intercepts of output formant contours
		@smoothMeasure: time - smoothWindow, time, maxFreq1, numFormants1, smoothFormant, buffer, 1
		@smoothMeasure: time, time + smoothWindow, maxFreq2, numFormants2, smoothFormant, buffer, 2
		slope = (endFormant2-startFormant1)/(smoothWindow*2) * 0.005
		intercept1 = startFormant1 - slope*startFrame1
		midFormant = slope*endFrame1 + intercept1
		intercept2 = midFormant - slope*startFrame2
		if .monitorSmooth
			appendInfoLine: fixed$(time - smoothWindow,5) + tab$ + fixed$(startFrame1,4) + tab$ + fixed$(startFormant1,2) + tab$ + fixed$(time,5) + tab$ + fixed$(endFrame1,4) + tab$ + fixed$(endFormant1,2)
			appendInfoLine: fixed$(time,5) + tab$ + fixed$(startFrame2,4) + tab$ + fixed$(startFormant2,2) + tab$ + fixed$(time + smoothWindow,5) + tab$ + fixed$(endFrame2,4) + tab$ + fixed$(endFormant2,2)
			appendInfoLine: newline$ + "Slope: 'slope' Hz/frame"
			appendInfoLine: "Intercept1: 'intercept1' Hz"
			appendInfoLine: "Intercept2: 'intercept2' Hz"
		endif
		##Smooth out formant contours
		@smooth: time - smoothWindow, time, smoothFormant, slope, intercept1, minPitch, 1
		@smooth: time, time + smoothWindow, smoothFormant, slope, intercept2, minPitch, 2
	endif
	
	##Extract afterToken and concatenate
	selectObject: sound
	afterToken = Extract part: time + smoothWindow, soundEnd, "rectangular", 1.0, "yes"
	Rename: "afterToken"
	plusObject: beforeToken, finalToken1
	if (maxFreq1 <> maxFreq2) or (numFormants1 <> numFormants2)
		plusObject: finalToken2
	endif
	smoothedSound = Concatenate
	if index_regex(soundName$, "smoothedF[1-5]+$") = 0
		Rename: soundName$ + "_smoothedF'smoothFormant'"
	else
		Rename: soundName$ + string$(smoothFormant)
	endif
	
	##Clean up created objects
	removeObject: beforeToken, finalToken1, afterToken
	if (maxFreq1 <> maxFreq2) or (numFormants1 <> numFormants2)
		removeObject: finalToken2
	endif
endproc

procedure smoothMeasure: start, end, maxFreq, numFormants, smoothFormant, buffer, count
	##Extract token for manipulation
	selectObject: sound
	token'count' = Extract part: start - buffer, end + buffer, "rectangular", 1.0, "yes"
	Rename: "token'count'"
	##Get manipulation ingredients
	@getIngredients: token'count', maxFreq, numFormants, buffer, 0.5
	removeObject: lowFreq, lpc, loudnessTokenNarrow, loudnessTokenLow
	highFreq'count' = highFreq
	selectObject: highFreq'count'
	Rename: "highFreq'count'"
	source'count' = source
	filter'count' = formantObj
	loudnessNarrow'count' = loudnessNarrow
	loudnessLow'count' = loudnessLow
	loudness'count' = loudness
	loudnessToken'count' = loudnessToken
	##Measure formant values
	selectObject: filter'count'
	startFormant'count' = Get value at time: smoothFormant, start, "Hertz", "Linear"
	endFormant'count' = Get value at time: smoothFormant, end, "Hertz", "Linear"
	startFrame'count' = Get frame number from time: start
	endFrame'count' = Get frame number from time: end
endproc

procedure smooth: start, end, smoothFormant, slope, intercept, minPitch, count
	##Manipulate Formant object, filter, resample, add high-frequency component back in
	selectObject: filter'count'
	Formula: start, end, smoothFormant, smoothFormant, "if row = " + string$(smoothFormant*2 - 1) + " then 'intercept' + 'slope'*col else self fi"
	selectObject: source'count', filter'count'
	sourceFilter = Filter
	Rename: "sourceFilter"
	newToken = Resample: 44100, 50
	Rename: "newToken"
	Scale intensity: loudnessLow'count'
	Formula: "self[col] + Sound_highFreq'count'[col]"
	##Clone Intensity
	timeStep = 0.005
	maxIntensity = 100
	@cloneIntensity: loudnessToken'count', newToken, minPitch, timeStep, maxIntensity
	##Trim buffer
	selectObject: endSound
	finalToken'count' = Extract part: start, end, "rectangular", 1.0, "yes"
	Scale intensity: loudnessNarrow'count'
	##Clean up created objects
	removeObject: token'count', highFreq'count', source'count', filter'count', sourceFilter, loudnessToken'count', newToken, endSound
endproc
