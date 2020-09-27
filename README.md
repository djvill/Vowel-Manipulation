# Vowel-Manipulation
Dan Villarreal (University of Pittsburgh)

d.vill@pitt.edu | https://www.researchgate.net/profile/Dan_Villarreal


This folder contains files useful for replicating the vowel manipulation methods used in my [2016 dissertation](https://www.academia.edu/30182487). If citing these scripts, please cite my [2018 *Journal of English Linguistics* article](http://journals.sagepub.com/doi/full/10.1177/0075424217753520): Villarreal, Dan. 2018. The construction of social meaning: A matched-guise investigation of the California Vowel Shift. *Journal of English Linguistics* 46.1.52-78. doi:10.1177/0075424217753520

The contents are:
- Praat scripts for running a manipulation. The main script is `ManipulateVowelsCSV.praat`, and the other scripts are subroutines for the main script. Together, these scripts should work 'out of the  box'.
- `TokenMeasurements.csv`, a file with inputs for the manipulation script. `ManipulateVowelsCSV.praat` depends on pulling data (on vowel timing, formant measurements, and other relevant measurements) from a csv formatted like `TokenMeasurements.csv`, though I’m working on a friendlier UI version with a Praat menu.
- Sections from my dissertation explaining in narrative form how the manipulation worked (see the first section for overview, second for gory detail).

Not present here but also necessary for running the script are **sounds** and **textgrid files**. You can access these either by [emailing me](daniel.villarreal@canterbury.ac.nz) for them, or via the [supplementary files](http://journals.sagepub.com/doi/suppl/10.1177/0075424217753520) on my [2018 JEngL article](http://journals.sagepub.com/doi/full/10.1177/0075424217753520). The stimuli I chose for this demonstration illustrate some of the pitfalls in the vowel manipulation process that the script is designed to circumvent:
- Stim5, Stim23, and Stim24 have nasty transitions between the manipulated token and a neighboring sonorant. The script automatically smooths out these transitions to make the resultant stimuli sound more natural, but you can set `smoothTrans` to `0` (line 37 of `ManipulateVowelsCSV.praat`) to see what they look like without smoothing.
- Stim5 and Stim18 have some tokens with F3s low enough such that, if nothing is done to F3, a manipulated raised F2 crashes into the F3, producing unnatural sounds (a ‘garbled’ sound for the first Stu token in Stim5, a ‘chirp’ at the end of food in Stim18). For these tokens, `TokenMeasurements.csv` specifies that F3 should be raised before manipulating F2, but you can set the last two columns of the csv to all 0s to see what happens when F3 is left alone.
- In Stim5, Stim18, and Stim24, the first manipulated token starts at the left edge of the stimulus; since the manipulation process requires a 50ms buffer on each side of the token (due to how Praat finds formant tracks), the timings need to be adjusted for all of the following tokens in these stimuli. The script automatically handles this situation by adjusting these timings, but you can set the second column of `TokenMeasurements.csv` to all `0`s to see what happens when start times aren’t adjusted.
- In addition, Figure 3 from the JEngL article comes from Stim5, so readers can replicate the results shown in Figure 3 themselves.

Finally, if there's anything that can be made clearer about the scripts and how they operate, please don't hesitate to email me at d.vill@pitt.edu.
