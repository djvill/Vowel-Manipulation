####
#### Praat script ManipulateVowelsGetIngredientsProc
#### Version 1.0a
#### Version date: December 3, 2017
#### Dan Villarreal
####
#### Hosts the getIngredients procedure that is utilized by 
#### ManipulateVowelsJNDProc.praat. Provides several objects that are needed
#### for acoustic manipulation, but does not actually perform the 
#### manipulation.
####
#### This is a lightly modified version of 1.0 for sharing.
####

procedure getIngredients: tokenID, maxFreq, numForms, buffer, measPoint
	selectObject: tokenID
	.start = Get start time
	.end = Get end time
	vowelMeasPoint = .start + measPoint * (.end - .start)
	##Determine sampling frequency of original token
	sampFreq = Get sampling frequency
	##Get the high-frequency portion of the signal
	selectObject: tokenID
	highFreq = Filter (pass Hann band): maxFreq, sampFreq, 1
	Rename: "highFreq"
	##Get info on the loudness of the original token
	selectObject: tokenID
	loudnessTokenNarrow = Extract part: .start + buffer, .end - buffer,
	... "rectangular", 1.0, "yes"
	Rename: "loudnessTokenNarrow"
	loudnessNarrow = Get intensity (dB)
	##Resample the token to 2 times the user-specified max frequency
	selectObject: tokenID
	lowFreq = Resample: maxFreq*2, 50
	Rename: "lowFreq"
	##Get info on the loudness of the original token
	loudnessTokenLow = Extract part: .start + 0.025, .end - 0.025,
	... "rectangular", 1.0, "yes"
	Rename: "loudnessTokenLow"
	loudnessLow = Get intensity (dB)
	##Compute the LPC and get the glottal source by inverse-filtering
	##through the LPC object
	selectObject: lowFreq
	lpc = To LPC (burg): numForms*2, 0.025, 0.005, 50
	Rename: "lpc"
	selectObject: lowFreq, lpc
	source = Filter (inverse)
	Rename: "source"
	##Get the Formant object from the LPC
	selectObject: lpc
	formantObj = To Formant
	Rename: "formantObj"
	##Create loudnessToken by zeroing out 25ms edges, resampling to 44100,
	##and adding the high-frequency component (with buffer) back in.
	##This is more accurate than the previous method of using just the 
	##buffer-less token (loudnessTokenNarrow) as the loudnessToken
	selectObject: lowFreq
	Set part to zero: .start, .start + 0.025, "at exactly these times"
	Set part to zero: .end - 0.025, .end, "at exactly these times"
	loudnessToken = Resample: sampFreq, 50
	Rename: "loudnessToken"
	Formula: "self[col] + Sound_highFreq[col]"
	loudness = Get intensity (dB)
endproc
