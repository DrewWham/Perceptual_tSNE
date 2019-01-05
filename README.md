# Perceptual_tSNE

Code to make perceptual embedding plots


## Dependencies
* Python 3.5 or later
* R 3.5 or later

## Quick Start

 open a terminal and `git clone` this repo
 then change your working directory to the repo with: `cd Perceptual_tSNE`  
 install the required python 3 packages with: `pip install -r ./required/requirements.txt`  
 install the required R packages with: `Rscript ./required/requirements.R`  

 run `python Perceptual_tSNE.py -h` to view help and test that all dependencies are installed correctly.

## Usage

 run `python Perceptual_tSNE.py` from the directory it is located. The first time this script is run the script will trigger a download of the machine learning model itself. This may take several minutes but will only occur on the first use. Subsequent runs will complete in a significantly shorter period of time.

The following options are required:  
`-i` specifies the name & location of the input image directory  
`-n` specifies the base name to use for program outputs

The following options are available:  
`-s` specifies the random seed to use for the random number generator.  
`-use_gpu` allows the use of a GPU, the script defaults to CPU. Pass `-use_gpu TRUE` if you have a GPU available on the system.  

To produce the example output files run:  

`python Perceptual_tSNE.py -i "./input_images/females" -n females_1 -s 1`



Please credit:
Our methods paper for the use of this repo and the application of this technique for quantifying perceptual distance in biological systems:

Our application paper for the use of this technique in quantifying bumblebee mimicry:

Zhang et al. (2018)'s paper for the base machine learning technique for quantifying perceptual distance of images:
https://github.com/richzhang/PerceptualSimilarity https://richzhang.github.io/PerceptualSimilarity/ Zhang et al. 2018 for perceptual similarity code.
