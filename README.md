# Perceptual_tSNE

Code to make perceptual embedding plots


## Dependencies
* Python 3.5
* R 3.5

## Quick Start
* run `python Perceptual_tSNE.py -h` to view help and test that all dependencies are installed correctly 
* run `python Perceptual_tSNE.py` from the directory it is located and use options `-i` to specify the name & location of the input image directory and `-n` to specify the base name to use for program outputs. Use `-s` to specify the random seed to use for the random number generator. 

To produce the example output files run:
`python3 Perceptual_tSNE.py -i "./input_images/females" -n females_1 -s 1`
