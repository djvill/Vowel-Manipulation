####
#### Praat script CloneIntensityProc
#### Version 1.0
#### Version date: 3/29/15
#### Dan Villarreal
####
#### Hosts a procedure, cloneIntensity, that makes the intensity contour
#### of soundNew match that of soundOrig. First flattens the intensity 
#### of soundNew by multiplying it by the difference of a maximum pitch
#### and its original intensity contour, then multiplies soundNew by the
#### time-transformed IntensityTier of soundOrig.
####

##Default values
# minPitch = 100
# step = 0.005
# maxIntensity = 100

procedure cloneIntensity: soundOrig, soundNew, minPitch, step, maxIntensity
	##Get info on soundNew
	selectObject: soundNew
	soundNewName$ = selected$("Sound")
	startNew = Get start time
	endNew = Get end time
	durNew = endNew - startNew
	meas = durNew div step

	##Get IntensityTier of soundNew and clear all points
	intensityNew = To Intensity: minPitch, step, "yes"
	intensityTierNew = Down to IntensityTier
	Remove points between: startNew, endNew

	##Add difference points to intensityTierNew 
	.time = startNew
	for counter from 0 to meas
		selectObject: intensityNew
		intensity = Get value at time: .time, "Cubic"
		if intensity != undefined
			selectObject: intensityTierNew
			scale = maxIntensity - intensity
			Add point: .time, scale
		endif
		.time += step
	endfor

	##Multiply soundNew by intensityTierNew to flatten intensities
	selectObject: soundNew, intensityTierNew
	newSound = Multiply: "yes"

	##Get IntensityTier of soundOrig and time-scale it to match soundNew
	selectObject: soundOrig
	meanOrig = Get intensity (dB)
	intensityOrig = To Intensity: minPitch, step, "yes"
	intensityTierOrig = Down to IntensityTier
	Scale times to: startNew, endNew

	##Multiply soundNew by intensityTierOrig to clone intensities, and scale mean
	selectObject: newSound, intensityTierOrig
	endSound = Multiply: "yes"
	Scale intensity: meanOrig
	meanNew = Get intensity (dB)
	Rename: soundNewName$ + "_intensityCloned"
	removeObject: intensityNew, intensityTierNew, intensityOrig, intensityTierOrig, newSound
endproc
