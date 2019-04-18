####
#### Praat script ManipTextgrid
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

##TODO: save files, option to save monitor to text file, condense pause windows (perhaps formants to manipulate could be less verbose, like a single text field)

stopwatch

selectObject: 1, 2

include ManipToken.praat
include SmoothTransitionsProc.praat

if numberOfSelected("Sound") <> 1 or numberOfSelected("TextGrid") <> 1
	exitScript: "You must select one Sound and one TextGrid to run this script.'newline$'Select one Sound and one TextGrid, and try again.'newline$'"
endif

origStim = selected("Sound")
origTG = selected("TextGrid")
origSoundName$ = selected$("Sound")
tgName$ = selected$("TextGrid")

beginPause: "Manipulate vowels"
	# comment: "Choose the tier that has nonempty intervals denoting the vowels to be manipulated."
	natural: "Segment tier", 1
	# comment: "How are segments to be manipulated labeled? If only manipulated segments are labeled, use .+"
	word: "Manipulation label", ".+"
	# comment: "Note: An improper choice for maximum frequency and number of formants will result in weird sounds."
	natural: "Maximum frequency (Hz)", 5000
	positive: "Number of formants", 5
	optionMenu: "Manipulation method", 1
		option: "Relative (set desired increase/decrease)"
		option: "Absolute (set desired formant target)"
	comment: "Choose the formants to manipulate:"
	boolean: "F1", 1
	boolean: "F2", 0
	boolean: "F3", 0
	boolean: "F4", 0
	boolean: "F5", 0
	# comment: "Note: It's recommended to set a small manipulation interval (e.g., one JND); to override, set to 10000."
	positive: "Manipulation interval", 21.86
	boolean: "Start with highest formant", 1
	positive: "Minimum pitch (Hz)", 75
clicked = endPause: "Continue", "Advanced settings", 1
manipulation_method$ = replace_regex$(manipulation_method$, "^([A-Za-z]+) .*", "\1", 0)
manipulation_method$ = replace_regex$(manipulation_method$, "(.)", "\l\1", 0)

##Advanced settings: default values
##time_buffer: How much time to extract before/after tokens?
time_buffer = 0.05
##smoothing_window: Size of window to perform formant smoothing over (0 for no smoothing)
smoothing_window = 0.02
##output_intensity: Average intensity of output files
output_intensity = 65
##time_step: Time step for intensity cloning (0 for no cloning)
time_step = 0.005
##maximum_intensity: Maximum intensity for intensity cloning
maximum_intensity = 100
##monitor: Print information on tokens? ("verbose", "succinct","none")
# monitor = 1
print_information_on_tokens$ = "verbose"
##token_information_output: Filename for csv output of token information (blank for no save)
##Will need to validate file extension
token_information_output$ = "" 
##keep_individual_tokens: Keep individual tokens in Praat Objects list?
keep_individual_tokens = 0
##keep_intermediary_stimuli: Keep intermediary stimuli in Praat Objects list?
keep_intermediary_stimuli = 0
##save: Save manipulated stimuli in saveDir$ (provided it exists)?
##Could also do this as providing manipulation suffix and/or prefix (prefix would need to be validated for directory existence)
save = 0 

##Advanced settings: user-set values
if clicked = 2
	beginPause: "Advanced settings"
		positive: "Time buffer", 0.05
		positive: "Output intensity", 65
		comment: "Time step for intensity cloning (0 for no cloning)"
		positive: "Time step", 0.005
		comment: "Maximum intensity for intensity cloning"
		positive: "Maximum intensity", 100
		comment: "Size of window to perform formant smoothing over (0 for no smoothing)"
		positive: "Smoothing window", 0.02		
		comment: "Monitor manipulation"
		boolean: "Keep individual tokens (in Objects list)", 0
		boolean: "Keep intermediary stimuli (in Objects list)", 0
		# boolean: "Monitor", 1
		optionMenu: "Print information on tokens", 1
			option: "Verbose (info on each manipulation step for each token)"
			option: "Succinct (info on each token)"
			option: "None"
	endPause: "Continue", 1
endif
print_information_on_tokens$ = replace_regex$(print_information_on_tokens$, "^([A-Za-z]+) .*", "\1", 0)
print_information_on_tokens$ = replace_regex$(print_information_on_tokens$, "(.)", "\l\1", 0)

##Check the number of nonempty intervals on segment_tier and warn the user if it's more than a large number.
selectObject: origTG
numManipTokens = Count intervals where: segment_tier, "matches (regex)", manipulation_label$
if numManipTokens > 100
	beginPause: "Large number of manipulations"
		comment: "There are 'numManip' nonempty intervals on tier 'segment_tier'."
		comment: "This manipulation might take a while. Do you want to proceed?"
	endPause: "Yes", 1
endif

##Initialize manipulation values
f1_manip = undefined
f2_manip = undefined
f3_manip = undefined
f4_manip = undefined
f5_manip = undefined

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

if manipulation_method$ = "relative"
	for fmt from 1 to 5
		if f'fmt'
			f'fmt'_manip = f'fmt'_increase
		else
			f'fmt'_manip = undefined
		endif
	endfor
elsif manipulation_method$ = "absolute"
	for fmt from 1 to 5
		if f'fmt'
			f'fmt'_manip = f'fmt'_target
		else
			f'fmt'_manip = undefined
		endif
	endfor
endif


##Print monitor header
if print_information_on_tokens$ = "verbose" or print_information_on_tokens$ = "succinct"
	writeInfoLine: "MANIPULATION"
	numManipForms = f1 + f2 + f3 + f4 + f5
	# manipForms$ = ""
	# ctr = 0
	# for fmt from 1 to 5
		# if f'fmt'
			# ctr += 1
			# manipForms$ = manipForms$ + "F'fmt'"
			# if ctr < numManipForms
				# manipForms$ = manipForms$ + ", "
			# endif
		# endif
	# endfor
	# appendInfoLine: manipForms$
	ctr = 0
	if manipulation_method$ = "relative"
		appendInfo: "Formant increases: "
		for fmt from 1 to 5
			if f'fmt'
				ctr += 1
				appendInfo: "F", fmt, " ", fixed$(f'fmt'_manip, 0), "Hz"
				if ctr < numManipForms
					appendInfo: ", "
				endif
			endif
		endfor
	elsif manipulation_method$ = "absolute"
		appendInfo: "Formant targets: "
	endif
	appendInfoLine: ""
endif

##Create versions of origStim and origTG to be manipulated
selectObject: origStim
Shift times to: "start time", 0
stimStart = 0
stimEnd = Get end time
manipStim = Copy: origSoundName$ + "_manip"
selectObject: origTG
numPhones = Get number of intervals: segment_tier
Shift times to: "start time", 0
manipTG = Copy: tgName$ + "_manip"
adjustStart = 0

##Counter, timer
tokenCt = 0
initTime = stopwatch

##Manipulation loop
for phone from 1 to numPhones
	selectObject: manipTG
	phoneLabel$ = Get label of interval: segment_tier, phone
	
	##Manipulate if the phone label matches the manipulation label
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
			Rename: origSoundName$ + "_beforeToken'tokenCt'"
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
		Rename: origSoundName$ + "_oldToken'tokenCt'"
		
		##Print monitor details
		if print_information_on_tokens$ = "verbose"
			appendInfoLine: newline$, "Token #", tokenCt, " (label ""'phoneLabel$'"" on tier ", segment_tier, ", ", fixed$(phoneStart,3), "-", fixed$(phoneEnd,3), "s)"
		elsif print_information_on_tokens$ = "succinct"
			appendInfoLine: newline$, "Token #'tokenCt' (label ""'phoneLabel$'"")"
		endif
		
		##Extract and manipulate token, formant by formant
		@manipulateToken: oldToken, maximum_frequency, number_of_formants, manipulation_method$, f1_manip, f2_manip, f3_manip, f4_manip, f5_manip, start_with_highest_formant, manipulation_interval, time_buffer, minimum_pitch, time_step, maximum_intensity, print_information_on_tokens$
		selectObject: token[manipCt]
		newToken = Extract part: phoneStart, phoneEnd, "rectangular", 1.0, "yes"
		Scale intensity: loudnessNarrow
		Rename: origSoundName$ + "_token'tokenCt'"
		if oldToken <> token[manipCt]
			removeObject: token[manipCt]
		endif
		
		##Add manipulated token back into the larger stimulus and rename
		if stimEnd - phoneEnd > time_buffer
			selectObject: manipStim
			afterToken = Extract part: phoneEnd, stimEnd, "rectangular", 1.0, "yes"
			Rename: origSoundName$ + "_afterToken'tokenCt'"
		endif
		if not keep_intermediary_stimuli
			removeObject: manipStim
		endif
		if stimEnd - phoneEnd > time_buffer
			selectObject: afterToken
		endif
		if phoneStart > time_buffer
			plusObject: beforeToken
		endif
		plusObject: newToken
		manipStim = Concatenate
		Rename: origSoundName$ + "_'tokenCt'_tokens_manipulated"
		
		##Clean up created objects
		removeObject: beforeToken, afterToken
		if not keep_individual_tokens
			removeObject: oldToken, newToken
		endif
		
		##Smooth formant transitions
		##	N.B. This makes a few assumptions, namely that all manipulated formants
		##	at both the left and right edges need to be smoothed. This might be too
		##	much manipulation, so take care with this.
		if smoothing_window > 0
			if print_information_on_tokens$ = "verbose"
				appendInfo: "Smoothing transitions for: "
			endif
			##Assume that preceding and following max frequency and number of formants are the same as the token
			prec_maximum_frequency = maximum_frequency
			prec_number_of_formants = number_of_formants
			foll_maximum_frequency = maximum_frequency
			foll_number_of_formants = number_of_formants
			
			##Set time to smooth around
			if phoneStart <= time_buffer
				smoothTime = phoneStart - time_buffer
			else
				smoothTime = phoneStart
			endif
			
			##Smooth formant by formant
			for fmt from 1 to 5
				if start_with_highest_formant
					manipFmt = 6 - fmt
				else
					manipFmt = fmt
				endif
				
				##If formant was set to be manipulated
				if f'manipFmt'
					if print_information_on_tokens$ = "verbose"
						appendInfo: "F'manipFmt' "
						if fmt = 5
							appendInfoLine: ""
						endif
					endif
					##Smooth left-edge transition
					@smoothTransitions: manipStim, smoothTime, smoothing_window, 2, prec_maximum_frequency, prec_number_of_formants, maximum_frequency, number_of_formants, time_buffer, minimum_pitch
					smoothedSoundLeft = smoothedSound
					if not keep_intermediary_stimuli
						removeObject: manipStim
					endif
					
					##Smooth right-edge transition
					@smoothTransitions: smoothedSoundLeft, smoothTime, smoothWindow, 2, maximum_frequency, number_of_formants, foll_maximum_frequency, foll_number_of_formants, time_buffer, minimum_pitch
					manipStim = smoothedSound
					
					removeObject: smoothedSoundLeft
				endif
			endfor
		##if smoothing_window > 0
		endif
	##if index_regex(phoneLabel$, manipulation_label$) > 0
	endif
##Manipulation loop: for phone from 1 to numPhones
endfor

manipTime = stopwatch

if print_information_on_tokens$ = "verbose" or print_information_on_tokens$ = "succinct"
	appendInfoLine: newline$, "Initialization:", tab$, fixed$(initTime,3), "s"
	appendInfoLine: "Manipulation:", tab$, fixed$(manipTime,3), "s"
endif

##Select final versions of objects
selectObject: manipStim
finalStim = Copy: origSoundName$ + "_manip"
Scale intensity: output_intensity
if not keep_intermediary_stimuli
	removeObject: manipStim
endif
selectObject: manipTG
finalTG = Copy: tgName$ + "_manip"
removeObject: manipTG
selectObject: finalStim, finalTG
