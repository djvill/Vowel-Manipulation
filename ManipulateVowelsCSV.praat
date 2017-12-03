####
#### Praat script ManipulateVowelsCSV
#### Version 1.2a
#### Version date: December 3, 2017
#### Dan Villarreal
####
#### Reads TokenMeasurements.csv to determine how to manipulate 
#### vowels in Sound files to two guises based on user-specified parameters. 
#### Forthe purposes of this script, a token is defined as a vowel
#### plus any preceding and/or following sonorant (except /r/) 
#### within the same word; the script manipulates the formants for
#### the entire token but defines formant targets relative to just
#### the vowel. (Users may ignore this behavior by using identical
#### timing values for the token and vowel in the csv file.) Also
#### adds columns to the csv file with info on the manipulation.
####
#### This is a lightly modified version of 1.2 for sharing.
####

stopwatch

include ManipulateVowelsJNDProc.praat
include SmoothTransitionsProc.praat

##Set stimuli to manipulate
startStim = 23
endStim = 24

##"Flag" variables (boolean-valued)
##monitor: Print information on tokens?
monitor = 1
##keep_all_tokens_in_objects: Keep individual tokens in Praat Objects list?
keep_all_tokens_in_objects = 0
##keep_intermediary_stimuli: Keep intermediary stimuli in Praat Objects list?
keep_intermediary_stimuli = 0
##smoothTrans: Smooth formant transitions?
smoothTrans = 1
##keepTime: Print timing information?
keepTime = 1
##save: Save manipulated stimuli in saveDir$ (provided it exists)?
save = 0

##File info
dirName$ = ""
origDirName$ = "Original/"
manipDirName$ = "Manipulated/"
tableName$ = "TokenMeasurements.csv"

##Other variables
buffer = 0.05
smoothWindow = 0.02
jnd_TRAP = 33.09
jnd_GOOSE = 21.86
finalIntensity = 65
timeStep = 0.005
maxIntensity = 100
##Headers for columns in the csv file that include target formants for
##each token and guise. The example csv file includes 3 sets of Cons 
##and Cali targets, calculated slightly different ways; specifying 
##"TargetA" vs. "TargetB" vs. "TargetC" (the one used in the 
##dissertation) as the targetSuffix$ allows for a comparison of 
##different target-calculation methods. 
targetSuffix$ = "TargetC"
f1ConsTargetCol$ = "F1Cons" + targetSuffix$
f1CaliTargetCol$ = "F1Cali" + targetSuffix$
f2ConsTargetCol$ = "F2Cons" + targetSuffix$
f2CaliTargetCol$ = "F2Cali" + targetSuffix$
f3ConsTargetCol$ = "F3Cons" + targetSuffix$
f3CaliTargetCol$ = "F3Cons" + targetSuffix$

##Read table and add columns
table = Read Table from comma-separated file: dirName$ + tableName$
Append column: "ManipCountCons"
Append column: "ManipCountCali"
Append column: "NewF1Cons"
Append column: "NewF1Cali"
Append column: "NewF2Cons"
Append column: "NewF2Cali"
Append column: "NewF3Cons"
Append column: "NewF3Cali"

##Set up files
for i from startStim to endStim
	##Get table rows for each stimulus
	selectObject: table
	startRow[i] = Search column: "Stimulus", string$(i)
	miniTable = Extract rows where column (number): "Stimulus", "equal to", i
	miniRows = Get number of rows
	endRow[i] = startRow[i] + miniRows - 1
	# if i = endStim
		# endRow[i] = Get number of rows
	# else
		# endRow[i] = Search column: "Stimulus", string$(i+1)
		# endRow[i] -= 1
	# endif
	
	##Load Sound and TextGrid files
	stimName$[i] = "Stim" + string$(i)
	soundName$[i] = stimName$[i] + ".wav"
	tgName$[i] = stimName$[i] + ".TextGrid"
	sound[i] = Read from file: dirName$ + origDirName$ + soundName$[i]
	tg[i] = Read from file: dirName$ + origDirName$ + tgName$[i]
endfor

if monitor
	writeInfoLine: "STIMULI"
endif

if keepTime
	initTime = stopwatch
endif

##For each stimulus, for each TRAP and GOOSE token, read info from
##table and, using preset formant targets above, manipulate tokens
##to create a conservative guise and a California-shifted guise.
for i from startStim to endStim
	##Initialize stimuli
	selectObject: sound[i]
	stimEnd = Get end time
	stimCons = sound[i]
	stimCali = sound[i]
	selectObject: tg[i]
	tgNew = Copy: stimName$[i]
	tokenCt = 0
	adjustStart = 0
	
	##Set minimum pitch based on gender
	selectObject: table
	gender$ = Get value: startRow[i], "Gender"
	if gender$ = "F"
		minPitch = 100
	else
		minPitch = 75
	endif
	
	##Print header line, if the user chooses
	if monitor
		appendInfoLine: stimName$[i]
		appendInfoLine: "Token", tab$, "Word", tab$, tab$, "origF2", tab$, "consTar", tab$, "consF2", tab$, "consOff", tab$, "caliTar", tab$, "caliF2", tab$, "caliOff"
	endif
	
	##Manipulate each token in stimulus i
	for tkn from startRow[i] to endRow[i]
		##Do not modify TRAP-N tokens
		selectObject: table
		feature$ = Get value: tkn, "Feature"
		if feature$ = "TRAP" or feature$ = "GOOSE"
			##PRELIMINARIES
			##Increment token count
			tokenCt += 1
			
			##Get appropriate JND
			jnd = jnd_'feature$'
			
			##Get values from Table
			word$ = Get value: tkn, "Word"
			tokenStart = Get value: tkn, "TokenStart"
			tokenEnd = Get value: tkn, "TokenEnd"
			vowelStart = Get value: tkn, "VowelStart"
			vowelEnd = Get value: tkn, "VowelEnd"
			maxFreq = Get value: tkn, "MaxFrequency"
			numForms = Get value: tkn, "NumFormants"
			midpointF1 = Get value: tkn, "F1_mid"
			midpointF2 = Get value: tkn, "F2_mid"
			midpointF3 = Get value: tkn, "F3_mid"
			
			##Adjust timings if necessary (i.e., if the first token included a buffer
			##that needed to be cut out)
			if adjustStart
				tokenStart -= buffer
				tokenEnd -= buffer
				vowelStart -= buffer
				vowelEnd -= buffer
			endif
			vowelMid = (vowelEnd-vowelStart)/2 + vowelStart
			
			##Read formant targets from table
			selectObject: table
			for fmt from 1 to 3
				targetF'fmt' = Get column index: f'fmt'ConsTargetCol$
				incrF'fmt' = Get column index: "F'fmt'IncrCons"
				if targetF'fmt' > 0
					desired_F'fmt'Cons = Get value: tkn, f'fmt'ConsTargetCol$
					desired_F'fmt'Cali = Get value: tkn, f'fmt'CaliTargetCol$
					f'fmt'_increaseCons = desired_F'fmt'Cons - midpointF'fmt'
					f'fmt'_increaseCali = desired_F'fmt'Cali - midpointF'fmt'
				elsif incrF'fmt' > 0
					f'fmt'_increaseCons = Get value: tkn, "F'fmt'IncrCons"
					f'fmt'_increaseCali = Get value: tkn, "F'fmt'IncrCali"
				else
					f'fmt'_increaseCons = 0
					f'fmt'_increaseCali = 0
				endif
			endfor
			
			##If smoothing, get info on transition issues
			if smoothTrans
				problemPrecCons$ = Get value: tkn, "ConsPrecedingTrans"
				problemFollCons$ = Get value: tkn, "ConsFollowingTrans"
				problemPrecCali$ = Get value: tkn, "CaliPrecedingTrans"
				problemFollCali$ = Get value: tkn, "CaliFollowingTrans"
			endif
			
			##MANIPULATION
			##Extract part of Sound before token and set start/end
			if tokenStart <= buffer
				adjustStart = 1
				start = 0
				stimEnd -= buffer
				selectObject: tgNew
				tgNewer = Extract part: buffer, stimEnd, "no"
				removeObject: tgNew
				tgNew = tgNewer
			else
				selectObject: stimCons
				beforeTokenCons = Extract part: 0, tokenStart, "rectangular", 1.0, "yes"
				Rename: stimName$[i] + "_Cons_beforeToken'tokenCt'"
				selectObject: stimCali
				beforeTokenCali = Extract part: 0, tokenStart, "rectangular", 1.0, "yes"
				Rename: stimName$[i] + "_Cali_beforeToken'tokenCt'"
				start = tokenStart - buffer
			endif
			
			##Trim buffer from end of TextGrid, if necessary
			if stimEnd - tokenEnd <= buffer
				end = stimEnd
				selectObject: tgNew
				tgNewer = Extract part: 0, stimEnd - buffer, "no"
				removeObject: tgNew
				tgNew = tgNewer
			else
				end = tokenEnd + buffer
			endif
			
			##Extract token plus buffer
			selectObject: stimCons
			oldToken = Extract part: start, end, "rectangular", 1.0, "yes"
			Rename: stimName$[i] + "_oldToken'tokenCt'"
			
			##Call ManipulateVowels procedure for conservative
			##target, trim buffer, scale intensity, and rename
			@manipulateVowels: oldToken, maxFreq, numForms, f1_increaseCons, f2_increaseCons, f3_increaseCons, jnd, buffer, minPitch, timeStep, maxIntensity
			selectObject: token[manipCt]
			newTokenCons = Extract part: start + buffer, end - buffer, "rectangular", 1.0, "yes"
			Scale intensity: loudnessNarrow
			Rename: stimName$[i] + "_Cons_token'tokenCt'"
			
			##Remove token with buffer, unless it's the original token
			##(i.e., there was no manipulation)
			if oldToken <> token[manipCt]
				removeObject: token[manipCt]
			endif
			
			##Add info on conservative token to table
			selectObject: table
			Set numeric value: tkn, "ManipCountCons", manipCt
			Set numeric value: tkn, "NewF1Cons", newF1
			Set numeric value: tkn, "NewF2Cons", newF2
			Set numeric value: tkn, "NewF3Cons", newF3
			newF2Cons = newF2
			offF2Cons = newF2Cons - desired_F2Cons
			
			##Call ManipulateVowels procedure for Californian target,
			##trim buffer, scale intensity, and rename
			@manipulateVowels: oldToken, maxFreq, numForms, f1_increaseCali, f2_increaseCali, f3_increaseCali, jnd, buffer, minPitch, timeStep, maxIntensity
			selectObject: token[manipCt]
			newTokenCali = Extract part: start + buffer, end - buffer, "rectangular", 1.0, "yes"
			Scale intensity: loudnessNarrow
			Rename: stimName$[i] + "_Cali_token'tokenCt'"
			
			##Remove token with buffer, unless it's the original token
			##(i.e., there was no manipulation)
			if oldToken <> token[manipCt]
				removeObject: token[manipCt]
			endif
			
			##Add info on Californian token to table
			selectObject: table
			Set numeric value: tkn, "ManipCountCali", manipCt
			Set numeric value: tkn, "NewF1Cali", newF1
			Set numeric value: tkn, "NewF2Cali", newF2
			Set numeric value: tkn, "NewF3Cali", newF3
			newF2Cali = newF2
			offF2Cali = newF2Cali - desired_F2Cali
			
			##PUTTING STIMULUS BACK TOGETHER
			##Extract afterTokens and add manipulated conservative
			##token back into stimulus
			if stimEnd - tokenEnd > buffer
				selectObject: stimCons
				afterTokenCons = Extract part: tokenEnd, stimEnd, "rectangular", 1.0, "yes"
				Rename: stimName$[i] + "_Cons_afterToken'tokenCt'"
				selectObject: stimCali
				afterTokenCali = Extract part: tokenEnd, stimEnd, "rectangular", 1.0, "yes"
				Rename: stimName$[i] + "_Cali_afterToken'tokenCt'"
				selectObject: afterTokenCons
			endif
			if tokenStart > buffer
				plusObject: beforeTokenCons
			endif
			plusObject: newTokenCons
			newStimCons = Concatenate
			Rename: stimName$[i] + "_Cons_'tokenCt'"
			
			##If a transition issue is identified in the data table,
			##run the smoothTransitions procedure on conservative
			##stimulus
			if smoothTrans
				if problemPrecCons$ = "Bad"
					##Get info from table and adjust timing if needed
					selectObject: table
					precNyquist = Get value: tkn, "PrecNyquist"
					precFormants = Get value: tkn, "PrecFormants"
					if tokenStart <= buffer
						smoothTime = tokenStart - buffer
					else
						smoothTime = tokenStart
					endif
					
					##Run smoothTransitions procedure and replace
					##old stimulus with smoothed stimulus
					@smoothTransitions: newStimCons, smoothTime, smoothWindow, 2, precNyquist, precFormants, maxFreq, numForms, buffer, minPitch
					removeObject: newStimCons
					newStimCons = newSound
				endif
				if problemFollCons$ = "Bad"
					##Get info from table and adjust timing if needed
					selectObject: table
					follNyquist = Get value: tkn, "FollNyquist"
					follFormants = Get value: tkn, "FollFormants"
					if tokenStart <= buffer
						smoothTime = tokenEnd - buffer
					else
						smoothTime = tokenEnd
					endif
					
					##Run smoothTransitions procedure and replace
					##old stimulus with smoothed stimulus
					@smoothTransitions: newStimCons, smoothTime, smoothWindow, 2, maxFreq, numForms, follNyquist, follFormants, buffer, minPitch
					removeObject: newStimCons
					newStimCons = newSound
				endif
			endif
			
			##Add manipulated Californian token back into stimulus
			if stimEnd - tokenEnd > buffer
				selectObject: afterTokenCali
			endif
			if tokenStart > buffer
				plusObject: beforeTokenCali
			endif
			plusObject: newTokenCali
			newStimCali = Concatenate
			Rename: stimName$[i] + "_Cali_'tokenCt'"
			
			##If a transition issue is identified in the data table,
			##run the smoothTransitions procedure on Californian
			##stimulus
			if smoothTrans
				if problemPrecCali$ = "Bad"
					##Get info from table and adjust timing if needed
					selectObject: table
					precNyquist = Get value: tkn, "PrecNyquist"
					precFormants = Get value: tkn, "PrecFormants"
					if tokenStart <= buffer
						smoothTime = tokenStart - buffer
					else
						smoothTime = tokenStart
					endif
					
					##Run smoothTransitions procedure and replace
					##old stimulus with smoothed stimulus
					@smoothTransitions: newStimCali, smoothTime, smoothWindow, 2, precNyquist, precFormants, maxFreq, numForms, buffer, minPitch
					removeObject: newStimCali
					newStimCali = newSound
				endif
				if problemFollCali$ = "Bad"
					##Get info from table and adjust timing if needed
					selectObject: table
					follNyquist = Get value: tkn, "FollNyquist"
					follFormants = Get value: tkn, "FollFormants"
					if tokenStart <= buffer
						smoothTime = tokenEnd - buffer
					else
						smoothTime = tokenEnd
					endif
					
					##Run smoothTransitions procedure and replace
					##old stimulus with smoothed stimulus
					@smoothTransitions: newStimCali, smoothTime, smoothWindow, 2, maxFreq, numForms, follNyquist, follFormants, buffer, minPitch
					removeObject: newStimCali
					newStimCali = newSound
				endif
			endif
			
			##FINAL BITS
			##Clean up beforeToken and afterToken objects
			if stimEnd - tokenEnd > buffer
				removeObject: afterTokenCons, afterTokenCali
			endif
			if tokenStart > buffer
				removeObject: beforeTokenCons, beforeTokenCali
			endif
			##Clean up created objects
			if not keep_all_tokens_in_objects
				removeObject: oldToken, newTokenCons, newTokenCali
			endif
			if not (keep_intermediary_stimuli or tokenCt = 1)
				removeObject: stimCons, stimCali
			endif
			
			##Reassign stimulus labels
			stimCons = newStimCons
			stimCali = newStimCali
			
			##Print info on tokens, if the user chooses
			if monitor
				if length(word$) < 8
					wordtab$ = word$ + tab$ + tab$
				else
					wordtab$ = word$ + tab$
				endif
				appendInfoLine: "'tokenCt'", tab$, wordtab$, "'midpointF2:0'", tab$, "'desired_F2Cons:0'", tab$, "'newF2Cons:0'", tab$, "'offF2Cons:0'", tab$, "'desired_F2Cali:0'", tab$, "'newF2Cali:0'", tab$, "'offF2Cali:0'"
			endif
		endif
	endfor
	
	##Scale intensity to final
	selectObject: stimCons, stimCali
	Scale intensity: finalIntensity
	
	##Copy original files so they're all in one place
	selectObject: sound[i]
	soundNew[i] = Copy: stimName$[i]
	removeObject: sound[i]
	selectObject: tg[i]
	tgCopy[i] = Copy: stimName$[i]
	removeObject: tg[i]
	selectObject: stimCons
	stimConsNew[i] = Copy: stimName$[i] + "_Cons"
	removeObject: stimCons
	selectObject: tgNew
	tgCons[i] = Copy: stimName$[i] + "_Cons"
	selectObject: stimCali
	stimCaliNew[i] = Copy: stimName$[i] + "_Cali"
	removeObject: stimCali
	selectObject: tgNew
	tgCali[i] = Copy: stimName$[i] + "_Cali"
	removeObject: tgNew
	
	if keepTime
		stopTime[i] = stopwatch
	endif
endfor

##Save stimuli
if save
	for i from startStim to endStim
		selectObject: stimConsNew[i]
		Save as WAV file: dirName$ + manipDirName$ + stimName$[i] + "_Cons.wav"
		selectObject: tgCons[i]
		Save as text file: dirName$ + manipDirName$ + stimName$[i] + "_Cons.TextGrid"
		selectObject: stimCaliNew[i]
		Save as WAV file: dirName$ + manipDirName$ + stimName$[i] + "_Cali.wav"
		selectObject: tgCali[i]
		Save as text file: dirName$ + manipDirName$ + stimName$[i] + "_Cali.TextGrid"
	endfor
endif

##If the user desires, print info on time.
if keepTime
	appendInfoLine: newline$, "Initialization time: 'initTime:3' sec"
	totalTime = initTime
	for i from startStim to endStim
		totalTime += stopTime[i]
		appendInfoLine: "Stimulus 'i' time: ", fixed$(stopTime[i],3), " sec"
	endfor
	appendInfoLine: "Total time: 'totalTime:3' sec"
	perStimTime = (totalTime-initTime)/(endStim-startStim+1)
	appendInfoLine: "Time per stimulus: 'perStimTime:3' sec"
endif
