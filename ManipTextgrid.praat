####
#### Praat script ManipulateVowelsTGUI
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

stopwatch

selectObject: 1, 2

include ManipToken.praat
include SmoothTransitionsProc.praat

if numberOfSelected("Sound") <> 1 or numberOfSelected("TextGrid") <> 1
	exitScript: "You must select one Sound and one TextGrid to run this script.'newline$'Select one Sound and one TextGrid, and try again.'newline$'"
endif

origStim = selected("Sound")
origTG = selected("TextGrid")
soundName$ = selected$("Sound")
tgName$ = selected$("TextGrid")

beginPause: "Manipulate vowels"
	comment: "Choose the tier that has nonempty intervals denoting the vowels to be manipulated."
	natural: "Segment tier", 1
	comment: "How are segments to be manipulated labeled? If only manipulated segments are labeled, use .+"
	word: "Manipulation label", ".+"
	comment: "Note: An improper choice for maximum frequency and number of formants will result in weird sounds."
	natural: "Maximum frequency (Hz)", 5000
	positive: "Number of formants", 5
	choice: "Manipulation method", 1
		option: "Relative (set desired increase/decrease)"
		option: "Absolute (set desired formant target)"
	comment: "Choose the formants to manipulate:"
	boolean: "F1", 1
	boolean: "F2", 0
	boolean: "F3", 0
	boolean: "F4", 0
	boolean: "F5", 0
	comment: "Note: It's recommended to set a small manipulation interval (e.g., one JND); to override, set to 10000."
	positive: "Manipulation interval", 21.86
	boolean: "Start with highest formant", 1
	positive: "Minimum pitch (Hz)", 75
clicked = endPause: "Continue", "Advanced settings", 1

##Advanced settings: default values
##time_buffer: How much time to extract before/after tokens?
time_buffer = 0.05
##smoothing_window: Size of window to perform formant smoothing over (0 for no smoothing)
smoothing_window = 0.02
##final_intensity: Average intensity of output files
final_intensity = 65
##time_step: Time step for intensity cloning (0 for no cloning)
time_step = 0.005
##maximum_intensity: Maximum intensity for intensity cloning
maximum_intensity = 100
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

##Advanced settings: user-set values
if clicked = 2
	beginPause: "Advanced settings"
		comment: "How much time to extract before/after tokens?"
		positive: "Time buffer", 0.05
		comment: "Size of window to perform formant smoothing over (0 for no smoothing)"
		positive: "Smoothing window", 0.02
		comment: "Average intensity of output files"
		positive: "Final intensity", 65
		comment: "Time step for intensity cloning (0 for no cloning)"
		positive: "Time step", 0.005
		comment: "Maximum intensity for intensity cloning"
		positive: "Maximum intensity", 100
		comment: "Print information on tokens?"
		boolean: "Monitor", 1
		comment: "Print timing information?"
		boolean: "Keep time", 1
		comment: "Keep individual tokens in Praat Objects list?"
		boolean: "Keep all tokens in objects", 0
		comment: "Keep intermediary stimuli in Praat Objects list?"
		boolean: "Keep intermediary stimuli", 0
		comment: "Smooth formant transitions?"
		boolean: "Smooth transitions", 1
	endPause: "Continue", 1
endif

##Check the number of nonempty intervals on segment_tier and warn the user if it's more than a large number.
selectObject: origTG
numManip = Count intervals where: segment_tier, "matches (regex)", ".+"
if numManip > 100
	beginPause: "Large number of manipulations"
		comment: "There are 'numManip' nonempty intervals on tier 'segment_tier'."
		comment: "This manipulation might take a while. Do you want to proceed?"
	endPause: "Yes", 1
endif

##Initialize manipulation values
f1_increase = undefined
f2_increase = undefined
f3_increase = undefined
f4_increase = undefined
f5_increase = undefined
f1_target = undefined
f2_target = undefined
f3_target = undefined
f4_target = undefined
f5_target = undefined

manipulation_method$ = replace_regex$(manipulation_method$, "^([A-Za-z]+) .*", "\1", 0)
manipulation_method$ = replace_regex$(manipulation_method$, "(.)", "\l\1", 0)

if manipulation_method$ = "relative"
	if f1
		if f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F2 increase (negative for decrease)", 200
						endPause: "Continue", 1
					endif
				endif
			endif
		elsif not f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F3 increase (negative for decrease)", 300
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F3 increase (negative for decrease)", 300
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F1 increase (negative for decrease)", 100
						endPause: "Continue", 1
					endif
				endif
			endif
		endif
	elsif not f1 
		if f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F3 increase (negative for decrease)", 300
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F2 increase (negative for decrease)", 200
						endPause: "Continue", 1
					endif
				endif
			endif
		elsif not f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F3 increase (negative for decrease)", 300
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F3 increase (negative for decrease)", 300
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F3 increase (negative for decrease)", 300
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							real: "F4 increase (negative for decrease)", 400
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							real: "F4 increase (negative for decrease)", 400
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							real: "F5 increase (negative for decrease)", 500
						endPause: "Continue", 1
					elsif not f5
						exitScript: "You must select at least one formant to manipulate."
					endif
				endif
			endif
		endif
	endif
elsif manipulation_method$ = "absolute"
	if f1
		if f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F3 target", 3000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F3 target", 3000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F3 target", 3000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F3 target", 3000
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F2 target", 2000
						endPause: "Continue", 1
					endif
				endif
			endif
		elsif not f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F3 target", 3000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F3 target", 3000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F3 target", 3000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F3 target", 3000
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F1 target", 1000
						endPause: "Continue", 1
					endif
				endif
			endif
		endif
	elsif not f1 
		if f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F3 target", 3000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F3 target", 3000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F3 target", 3000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F3 target", 3000
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F2 target", 2000
						endPause: "Continue", 1
					endif
				endif
			endif
		elsif not f2
			if f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F3 target", 3000
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F3 target", 3000
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F3 target", 3000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F3 target", 3000
						endPause: "Continue", 1
					endif
				endif
			elsif not f3
				if f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F4 target", 4000
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						beginPause: "Manipulate formants"
							positive: "F4 target", 4000
						endPause: "Continue", 1
					endif
				elsif not f4
					if f5
						beginPause: "Manipulate formants"
							positive: "F5 target", 5000
						endPause: "Continue", 1
					elsif not f5
						exitScript: "You must select at least one formant to manipulate."
					endif
				endif
			endif
		endif
	endif
endif

if monitor
	writeInfoLine: "MANIPULATION"
	# if manipulation_method$ = "relative"
		# appendInfoLine: ""
endif

if keepTime
	initTime = stopwatch
endif

selectObject: origStim
Shift times to: "start time", 0
stimStart = 0
stimEnd = Get end time
manipStim = Copy: soundName$ + "_manip"

selectObject: origTG
numPhones = Get number of intervals: segment_tier
Shift times to: "start time", 0
manipTG = Copy: tgName$ + "_manip"
adjustStart = 0

tokenCt = 0

for phone from 1 to numPhones
	selectObject: manipTG
	phoneLabel$ = Get label of interval: segment_tier, phone
	
	if index_regex(phoneLabel$, manipulation_label$) > 0
		tokenCt += 1
		
		##Here, "phone" refers to the segment, "token" to the segment plus left and/or right buffer
		phoneStart = Get start time of interval: segment_tier, phone
		phoneEnd = Get end time of interval: segment_tier, phone
		
		##Extract part of Sound before phone (if applicable), and set token start time
		if phoneStart <= time_buffer
			##If not enough time before phone, no beforeToken
			adjustStart = 1
			tokenStart = 0
			##Update TextGrid timing
			stimEnd -= time_buffer
			selectObject: manipTG
			tgNewer = Extract part: time_buffer, stimEnd, "no"
			removeObject: manipTG
			manipTG = tgNewer
		else
			selectObject: manipStim
			beforeToken = Extract part: 0, phoneStart, "rectangular", 1.0, "yes"
			Rename: soundName$ + "_beforeToken'tokenCt'"
			tokenStart = phoneStart - time_buffer
		endif
		
		##Set token end time
		if stimEnd - phoneEnd <= time_buffer
			##If not enough time after phone, set token end to stimulus end
			tokenEnd = stimEnd
			##Update TextGrid timing
			selectObject: manipTG
			tgNewer = Extract part: 0, stimEnd - time_buffer, "no"
			removeObject: manipTG
			manipTG = tgNewer
		else
			tokenEnd = phoneEnd + time_buffer
		endif
		
		##Extract token
		selectObject: manipStim
		oldToken = Extract part: tokenStart, tokenEnd, "rectangular", 1.0, "yes"
		Rename: soundName$ + "_oldToken'tokenCt'"
		
		##Print monitor details
		if monitor
			appendInfoLine: "Token #'tokenCt' (label 'phoneLabel$'):"
			appendInfoLine: tab$, "Manip count", tab$, "Formant", tab$, "Midpt", tab$, "Target", tab$, "Intvl", tab$, "Remaining increase"
		endif
		
		##Extract and manipulate token, formant by formant
		if manipulation_method$ = "relative"
			@manipulateToken: oldToken, maximum_frequency, number_of_formants, manipulation_method$, f1_increase, f2_increase, f3_increase, f4_increase, f5_increase, start_with_highest_formant, manipulation_interval, time_buffer, minimum_pitch, time_step, maximum_intensity, monitor
		elsif manipulation_method$ = "absolute"
			@manipulateToken: oldToken, maximum_frequency, number_of_formants, manipulation_method$, f1_target, f2_target, f3_target, f4_target, f5_target, start_with_highest_formant, manipulation_interval, time_buffer, minimum_pitch, time_step, maximum_intensity, monitor
		endif
		selectObject: token[manipCt]
		newToken = Extract part: phoneStart, phoneEnd, "rectangular", 1.0, "yes"
		Scale intensity: loudnessNarrow
		Rename: soundName$ + "_token'tokenCt'"
		if oldToken <> token[manipCt]
			removeObject: token[manipCt]
		endif
		
		##Add manipulated token back into the larger stimulus and rename
		if stimEnd - phoneEnd > time_buffer
			selectObject: manipStim
			afterToken = Extract part: phoneEnd, stimEnd, "rectangular", 1.0, "yes"
			Rename: soundName$ + "_afterToken'tokenCt'"
		endif
		if not keep_intermediary_stimuli
			removeObject: manipStim
		endif
		if stimEnd - phoneEnd > time_buffer
			selectObject: afterToken
		endif
		if phoneStart > buffer
			plusObject: beforeToken
		endif
		plusObject: newToken
		manipStim = Concatenate
		Rename: soundName$ + "_'tokenCt'_tokens_manipulated"
		
		##Clean up created objects
		removeObject: beforeToken, afterToken
		if not keep_all_tokens_in_objects
			removeObject: oldToken, newToken
		endif
		
		##Smooth formant transitions
	endif
endfor

selectObject: manipStim
finalStim = Copy: soundName$ + "_manip"
if not keep_intermediary_stimuli
	removeObject: manipStim
endif
selectObject: manipTG
finalTG = Copy: tgName$ + "_manip"
removeObject: manipTG
selectObject: finalStim, finalTG

##For each stimulus, for each TRAP and GOOSE token, read info from
##table and, using preset formant targets above, manipulate tokens
##to create a conservative guise and a California-shifted guise.
# for i from startStim to endStim
	#Initialize stimuli
	# selectObject: sound[i]
	# stimEnd = Get end time
	# stimCons = sound[i]
	# stimCali = sound[i]
	# selectObject: tg[i]
	# tgNew = Copy: stimName$[i]
	# tokenCt = 0
	# adjustStart = 0
	
	#Set minimum pitch based on gender
	# selectObject: table
	# gender$ = Get value: startRow[i], "Gender"
	# if gender$ = "F"
		# minPitch = 100
	# else
		# minPitch = 75
	# endif
	
	#Print header line, if the user chooses
	# if monitor
		# appendInfoLine: stimName$[i]
		# appendInfoLine: "Token", tab$, "Word", tab$, tab$, "origF2", tab$, "consTar", tab$, "consF2", tab$, "consOff", tab$, "caliTar", tab$, "caliF2", tab$, "caliOff"
	# endif
	
	#Manipulate each token in stimulus i
	# for tkn from startRow[i] to endRow[i]
		#Do not modify TRAP-N tokens
		# selectObject: table
		# feature$ = Get value: tkn, "Feature"
		# if feature$ = "TRAP" or feature$ = "GOOSE"
			#PRELIMINARIES
			#Increment token count
			# tokenCt += 1
			
			#Get appropriate JND
			# jnd = jnd_'feature$'
			
			#Get values from Table
			# word$ = Get value: tkn, "Word"
			# tokenStart = Get value: tkn, "TokenStart"
			# tokenEnd = Get value: tkn, "TokenEnd"
			# vowelStart = Get value: tkn, "VowelStart"
			# vowelEnd = Get value: tkn, "VowelEnd"
			# maxFreq = Get value: tkn, "MaxFrequency"
			# numForms = Get value: tkn, "NumFormants"
			# midpointF1 = Get value: tkn, "F1_mid"
			# midpointF2 = Get value: tkn, "F2_mid"
			# midpointF3 = Get value: tkn, "F3_mid"
			
			#Adjust timings if necessary (i.e., if the first token included a buffer
			#that needed to be cut out)
			# if adjustStart
				# tokenStart -= buffer
				# tokenEnd -= buffer
				# vowelStart -= buffer
				# vowelEnd -= buffer
			# endif
			# vowelMid = (vowelEnd-vowelStart)/2 + vowelStart
			
			#Read formant targets from table
			# selectObject: table
			# for fmt from 1 to 3
				# targetF'fmt' = Get column index: f'fmt'ConsTargetCol$
				# incrF'fmt' = Get column index: "F'fmt'IncrCons"
				# if targetF'fmt' > 0
					# desired_F'fmt'Cons = Get value: tkn, f'fmt'ConsTargetCol$
					# desired_F'fmt'Cali = Get value: tkn, f'fmt'CaliTargetCol$
					# f'fmt'_increaseCons = desired_F'fmt'Cons - midpointF'fmt'
					# f'fmt'_increaseCali = desired_F'fmt'Cali - midpointF'fmt'
				# elsif incrF'fmt' > 0
					# f'fmt'_increaseCons = Get value: tkn, "F'fmt'IncrCons"
					# f'fmt'_increaseCali = Get value: tkn, "F'fmt'IncrCali"
				# else
					# f'fmt'_increaseCons = 0
					# f'fmt'_increaseCali = 0
				# endif
			# endfor
			
			#If smoothing, get info on transition issues
			# if smoothTrans
				# problemPrecCons$ = Get value: tkn, "ConsPrecedingTrans"
				# problemFollCons$ = Get value: tkn, "ConsFollowingTrans"
				# problemPrecCali$ = Get value: tkn, "CaliPrecedingTrans"
				# problemFollCali$ = Get value: tkn, "CaliFollowingTrans"
			# endif
			
			#MANIPULATION
			#Extract part of Sound before token and set start/end
			# if tokenStart <= buffer
				# adjustStart = 1
				# start = 0
				# stimEnd -= buffer
				# selectObject: tgNew
				# tgNewer = Extract part: buffer, stimEnd, "no"
				# removeObject: tgNew
				# tgNew = tgNewer
			# else
				# selectObject: stimCons
				# beforeTokenCons = Extract part: 0, tokenStart, "rectangular", 1.0, "yes"
				# Rename: stimName$[i] + "_Cons_beforeToken'tokenCt'"
				# selectObject: stimCali
				# beforeTokenCali = Extract part: 0, tokenStart, "rectangular", 1.0, "yes"
				# Rename: stimName$[i] + "_Cali_beforeToken'tokenCt'"
				# start = tokenStart - buffer
			# endif
			
			#Trim buffer from end of TextGrid, if necessary
			# if stimEnd - tokenEnd <= buffer
				# end = stimEnd
				# selectObject: tgNew
				# tgNewer = Extract part: 0, stimEnd - buffer, "no"
				# removeObject: tgNew
				# tgNew = tgNewer
			# else
				# end = tokenEnd + buffer
			# endif
			
			#Extract token plus buffer
			# selectObject: stimCons
			# oldToken = Extract part: start, end, "rectangular", 1.0, "yes"
			# Rename: stimName$[i] + "_oldToken'tokenCt'"
			
			#Call ManipulateVowels procedure for conservative
			#target, trim buffer, scale intensity, and rename
			# @manipulateVowels: oldToken, maxFreq, numForms, f1_increaseCons, f2_increaseCons, f3_increaseCons, jnd, buffer, minPitch, timeStep, maxIntensity
			# selectObject: token[manipCt]
			# newTokenCons = Extract part: start + buffer, end - buffer, "rectangular", 1.0, "yes"
			# Scale intensity: loudnessNarrow
			# Rename: stimName$[i] + "_Cons_token'tokenCt'"
			
			#Remove token with buffer, unless it's the original token
			#(i.e., there was no manipulation)
			# if oldToken <> token[manipCt]
				# removeObject: token[manipCt]
			# endif
			
			#Add info on conservative token to table
			# selectObject: table
			# Set numeric value: tkn, "ManipCountCons", manipCt
			# Set numeric value: tkn, "NewF1Cons", newF1
			# Set numeric value: tkn, "NewF2Cons", newF2
			# Set numeric value: tkn, "NewF3Cons", newF3
			# newF2Cons = newF2
			# offF2Cons = newF2Cons - desired_F2Cons
			
			#Call ManipulateVowels procedure for Californian target,
			#trim buffer, scale intensity, and rename
			# @manipulateVowels: oldToken, maxFreq, numForms, f1_increaseCali, f2_increaseCali, f3_increaseCali, jnd, buffer, minPitch, timeStep, maxIntensity
			# selectObject: token[manipCt]
			# newTokenCali = Extract part: start + buffer, end - buffer, "rectangular", 1.0, "yes"
			# Scale intensity: loudnessNarrow
			# Rename: stimName$[i] + "_Cali_token'tokenCt'"
			
			#Remove token with buffer, unless it's the original token
			#(i.e., there was no manipulation)
			# if oldToken <> token[manipCt]
				# removeObject: token[manipCt]
			# endif
			
			#Add info on Californian token to table
			# selectObject: table
			# Set numeric value: tkn, "ManipCountCali", manipCt
			# Set numeric value: tkn, "NewF1Cali", newF1
			# Set numeric value: tkn, "NewF2Cali", newF2
			# Set numeric value: tkn, "NewF3Cali", newF3
			# newF2Cali = newF2
			# offF2Cali = newF2Cali - desired_F2Cali
			
			#PUTTING STIMULUS BACK TOGETHER
			#Extract afterTokens and add manipulated conservative
			#token back into stimulus
			# if stimEnd - tokenEnd > buffer
				# selectObject: stimCons
				# afterTokenCons = Extract part: tokenEnd, stimEnd, "rectangular", 1.0, "yes"
				# Rename: stimName$[i] + "_Cons_afterToken'tokenCt'"
				# selectObject: stimCali
				# afterTokenCali = Extract part: tokenEnd, stimEnd, "rectangular", 1.0, "yes"
				# Rename: stimName$[i] + "_Cali_afterToken'tokenCt'"
				# selectObject: afterTokenCons
			# endif
			# if tokenStart > buffer
				# plusObject: beforeTokenCons
			# endif
			# plusObject: newTokenCons
			# newStimCons = Concatenate
			# Rename: stimName$[i] + "_Cons_'tokenCt'"
			
			#If a transition issue is identified in the data table,
			#run the smoothTransitions procedure on conservative
			#stimulus
			# if smoothTrans
				# if problemPrecCons$ = "Bad"
					#Get info from table and adjust timing if needed
					# selectObject: table
					# precNyquist = Get value: tkn, "PrecNyquist"
					# precFormants = Get value: tkn, "PrecFormants"
					# if tokenStart <= buffer
						# smoothTime = tokenStart - buffer
					# else
						# smoothTime = tokenStart
					# endif
					
					#Run smoothTransitions procedure and replace
					#old stimulus with smoothed stimulus
					# @smoothTransitions: newStimCons, smoothTime, smoothWindow, 2, precNyquist, precFormants, maxFreq, numForms, buffer, minPitch
					# removeObject: newStimCons
					# newStimCons = newSound
				# endif
				# if problemFollCons$ = "Bad"
					#Get info from table and adjust timing if needed
					# selectObject: table
					# follNyquist = Get value: tkn, "FollNyquist"
					# follFormants = Get value: tkn, "FollFormants"
					# if tokenStart <= buffer
						# smoothTime = tokenEnd - buffer
					# else
						# smoothTime = tokenEnd
					# endif
					
					#Run smoothTransitions procedure and replace
					#old stimulus with smoothed stimulus
					# @smoothTransitions: newStimCons, smoothTime, smoothWindow, 2, maxFreq, numForms, follNyquist, follFormants, buffer, minPitch
					# removeObject: newStimCons
					# newStimCons = newSound
				# endif
			# endif
			
			#Add manipulated Californian token back into stimulus
			# if stimEnd - tokenEnd > buffer
				# selectObject: afterTokenCali
			# endif
			# if tokenStart > buffer
				# plusObject: beforeTokenCali
			# endif
			# plusObject: newTokenCali
			# newStimCali = Concatenate
			# Rename: stimName$[i] + "_Cali_'tokenCt'"
			
			#If a transition issue is identified in the data table,
			#run the smoothTransitions procedure on Californian
			#stimulus
			# if smoothTrans
				# if problemPrecCali$ = "Bad"
					#Get info from table and adjust timing if needed
					# selectObject: table
					# precNyquist = Get value: tkn, "PrecNyquist"
					# precFormants = Get value: tkn, "PrecFormants"
					# if tokenStart <= buffer
						# smoothTime = tokenStart - buffer
					# else
						# smoothTime = tokenStart
					# endif
					
					#Run smoothTransitions procedure and replace
					#old stimulus with smoothed stimulus
					# @smoothTransitions: newStimCali, smoothTime, smoothWindow, 2, precNyquist, precFormants, maxFreq, numForms, buffer, minPitch
					# removeObject: newStimCali
					# newStimCali = newSound
				# endif
				# if problemFollCali$ = "Bad"
					#Get info from table and adjust timing if needed
					# selectObject: table
					# follNyquist = Get value: tkn, "FollNyquist"
					# follFormants = Get value: tkn, "FollFormants"
					# if tokenStart <= buffer
						# smoothTime = tokenEnd - buffer
					# else
						# smoothTime = tokenEnd
					# endif
					
					#Run smoothTransitions procedure and replace
					#old stimulus with smoothed stimulus
					# @smoothTransitions: newStimCali, smoothTime, smoothWindow, 2, maxFreq, numForms, follNyquist, follFormants, buffer, minPitch
					# removeObject: newStimCali
					# newStimCali = newSound
				# endif
			# endif
			
			#FINAL BITS
			#Clean up beforeToken and afterToken objects
			# if stimEnd - tokenEnd > buffer
				# removeObject: afterTokenCons, afterTokenCali
			# endif
			# if tokenStart > buffer
				# removeObject: beforeTokenCons, beforeTokenCali
			# endif
			#Clean up created objects
			# if not keep_all_tokens_in_objects
				# removeObject: oldToken, newTokenCons, newTokenCali
			# endif
			# if not (keep_intermediary_stimuli or tokenCt = 1)
				# removeObject: stimCons, stimCali
			# endif
			
			#Reassign stimulus labels
			# stimCons = newStimCons
			# stimCali = newStimCali
			
			#Print info on tokens, if the user chooses
			# if monitor
				# if length(word$) < 8
					# wordtab$ = word$ + tab$ + tab$
				# else
					# wordtab$ = word$ + tab$
				# endif
				# appendInfoLine: "'tokenCt'", tab$, wordtab$, "'midpointF2:0'", tab$, "'desired_F2Cons:0'", tab$, "'newF2Cons:0'", tab$, "'offF2Cons:0'", tab$, "'desired_F2Cali:0'", tab$, "'newF2Cali:0'", tab$, "'offF2Cali:0'"
			# endif
		# endif
	# endfor
	
	#Scale intensity to final
	# selectObject: stimCons, stimCali
	# Scale intensity: finalIntensity
	
	#Copy original files so they're all in one place
	# selectObject: sound[i]
	# soundNew[i] = Copy: stimName$[i]
	# removeObject: sound[i]
	# selectObject: tg[i]
	# tgCopy[i] = Copy: stimName$[i]
	# removeObject: tg[i]
	# selectObject: stimCons
	# stimConsNew[i] = Copy: stimName$[i] + "_Cons"
	# removeObject: stimCons
	# selectObject: tgNew
	# tgCons[i] = Copy: stimName$[i] + "_Cons"
	# selectObject: stimCali
	# stimCaliNew[i] = Copy: stimName$[i] + "_Cali"
	# removeObject: stimCali
	# selectObject: tgNew
	# tgCali[i] = Copy: stimName$[i] + "_Cali"
	# removeObject: tgNew
	
	# if keepTime
		# stopTime[i] = stopwatch
	# endif
# endfor

##Save stimuli
# if save
	# for i from startStim to endStim
		# selectObject: stimConsNew[i]
		# Save as WAV file: dirName$ + manipDirName$ + stimName$[i] + "_Cons.wav"
		# selectObject: tgCons[i]
		# Save as text file: dirName$ + manipDirName$ + stimName$[i] + "_Cons.TextGrid"
		# selectObject: stimCaliNew[i]
		# Save as WAV file: dirName$ + manipDirName$ + stimName$[i] + "_Cali.wav"
		# selectObject: tgCali[i]
		# Save as text file: dirName$ + manipDirName$ + stimName$[i] + "_Cali.TextGrid"
	# endfor
# endif

#If the user desires, print info on time.
# if keepTime
	# appendInfoLine: newline$, "Initialization time: 'initTime:3' sec"
	# totalTime = initTime
	# for i from startStim to endStim
		# totalTime += stopTime[i]
		# appendInfoLine: "Stimulus 'i' time: ", fixed$(stopTime[i],3), " sec"
	# endfor
	# appendInfoLine: "Total time: 'totalTime:3' sec"
	# perStimTime = (totalTime-initTime)/(endStim-startStim+1)
	# appendInfoLine: "Time per stimulus: 'perStimTime:3' sec"
# endif
