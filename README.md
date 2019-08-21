# Perceptual_tSNE

Code to make perceptual embedding plots

## With Docker
### Installation
1. Install `docker` and `docker-compose` on the host machine.
2. Run the follow commands:
```
git clone https://github.com/tsankuanglee/Perceptual_tSNE
cd Perceptual_tSNE
./run
```
This will take a while while it installs all R packages and Python packages. The subsequent runs will take shorter.
3. Edit `command.sh` as needed (see Usage below)

## Without Docker

### Dependencies
* Python 3.5 or later
* R 3.5 or later

### Quick Start

 -open a terminal and `git clone` this repo  

 -then change your working directory to the repo with: `cd Perceptual_tSNE`  

 -install the required python 3 packages with: `pip install -r ./required/requirements.txt`  

 -install the required R packages with: `Rscript ./required/requirements.R`  

 -run `python Perceptual_tSNE.py -h` to view help and test that all dependencies are installed correctly.

## Usage

 run `python Perceptual_tSNE.py` from the directory it is located.

The following options are required:  
`-i` specifies the name & location of the input image directory  
`-n` specifies the base name to use for program outputs
`-p` specifies the perplexity parameter to be used in t-SNE analysis
`-g` allows the use of a GPU, pass `-use_gpu TRUE` if you have a CUDA enabled GPU available on the system with gpu relevent dependencies installed.

The following options are available:  
`-s` specifies the random seed to use for the random number generator.    

To produce the example output files run:  

`python Perceptual_tSNE.py -i "./input_images/females" -n females_1 -s 1 -p 30 -g FALSE`



Please credit:  
Our methods paper for the use of this repo and the application of this technique for quantifying perceptual distance in biological systems:Measuring Perceptual Distance of Organismal Color Pattern using the Features of Deep Neural Networks. (2019) Drew C Wham, Briana D Ezray, Heather M Hines. https://doi.org/10.1101/736306

Our application paper for the use of this technique in quantifying bumblebee mimicry: Müllerian mimicry in bumble bees is a transient continuum. (2019) Briana D. Ezray, Drew C. Wham, Carrie Hill, Heather M. Hines https://doi.org/10.1101/513275

Zhang et al. (2018)'s paper for the base machine learning technique for quantifying perceptual distance of images:
https://github.com/richzhang/PerceptualSimilarity https://richzhang.github.io/PerceptualSimilarity/ Zhang et al. 2018 for perceptual similarity code.
