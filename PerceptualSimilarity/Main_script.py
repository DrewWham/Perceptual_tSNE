# import sys; sys.path += ['models']
import torch
import csv
import pandas as pd
from util import util
from models import dist_model as dm
from IPython import embed
from os import listdir
from skimage import transform
from skimage import io

#imgs=listdir("./males")

imgs=listdir("/mnt/wham/ImageSim/females64")
data=pd.read_csv("/mnt/wham/ImageSim/female_data.csv")

for image in imgs:
     img=skimage.io.imread('./imgs/%s' % image)
     img2=transform.resize(img,(64,64))
     skimage.io.imsave('./imgs64/%s' % image, img2)

use_gpu = True         # Whether to use GPU
spatial = False         # Return a spatial map of perceptual distance.
                       # Optional args spatial_shape and spatial_order control output shape and resampling filter: see DistModel.initialize() for details.

## Initializing the model
model = dm.DistModel()

# Linearly calibrated models
#model.initialize(model='net-lin',net='squeeze',use_gpu=use_gpu,spatial=spatial)
model.initialize(model='net-lin',net='alex',use_gpu=use_gpu,spatial=spatial)
#model.initialize(model='net-lin',net='vgg',use_gpu=use_gpu,spatial=spatial)

# Off-the-shelf uncalibrated networks
#model.initialize(model='net',net='squeeze',use_gpu=use_gpu)
#model.initialize(model='net',net='alex',use_gpu=use_gpu)
#model.initialize(model='net',net='vgg',use_gpu=use_gpu)

# Low-level metrics
# model.initialize(model='l2',colorspace='Lab')
# model.initialize(model='ssim',colorspace='RGB')
print('Model [%s] initialized'%model.name())

## Example usage with images
dist=[]

for index, row in data.iterrows():

    img_1=util.load_image('/mnt/wham/ImageSim/females64/%s' % row['img1'])
    img_2=util.load_image('/mnt/wham/ImageSim/females64/%s' % row['img2'])

    ex_ref = util.im2tensor(img_1)
    ex_p1 = util.im2tensor(img_2)

    ex_d0 = model.forward(ex_ref,ex_p1)
    dist.append(ex_d0)
    print(ex_d0)

data.distance=dist
data.to_csv("/mnt/wham/ImageSim/output_females_data.csv")
