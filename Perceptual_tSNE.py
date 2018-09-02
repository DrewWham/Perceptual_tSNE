# import sys; sys.path += ['models']
import matplotlib
matplotlib.use('Agg')
import torch, csv, getopt, subprocess, os, sys, skimage, cv2, glob
import pandas as pd
import numpy as np
from PerceptualSimilarity.util import util
from PerceptualSimilarity.models import dist_model as dm
from IPython import embed
from os import listdir
from skimage import transform
from skimage.transform import resize
from matplotlib import pyplot as plt
from skimage import io
import matplotlib.pyplot as plt
from matplotlib.offsetbox import OffsetImage, AnnotationBbox
from glob import glob
import matplotlib.cm as cm
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.preprocessing import StandardScaler
import copy
print("v3")


def getArgs(argv):
    #this allows the user to enter some variables, including username and password so that isnt hard coded also returns a usage statement
    input = ''
    project_name = ''
    try:
        opts, args = getopt.getopt(argv,"hi:n:s:",["input=","name=","seed="])
    except getopt.GetoptError:
        print('usage: perceptual_tsne.py -i <input>  -n <name>  -s <seed>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print( 'usage: perceptual_tsne.py -i <input>  -n <name> -s <seed>')
            sys.exit()
        elif opt in ("-i", "--input"):
            input = arg
        elif opt in ("-n", "--name"):
            name = arg
        elif opt in ("-s", "--seed"):
            seed = arg
    #now we return the variables to be passed forward

    return (input,name,seed)

#input="./input_images/males"
#name="males"


def makeModelReadyImages(input,name):
    print(input)
    imgs=listdir(input)
    imgs = [x for x in imgs if not x.startswith('.')]
    output_dir= "./model_ready_images/%s" % (name)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for image in imgs:
         img_path="%s/%s" % (input, image)
         img=skimage.io.imread(img_path)
         img64=transform.resize(img,(64,64))
         output_path="%s/%s" % (output_dir,image)
         skimage.io.imsave(output_path, img64)


def makePairsList(input,name):
    rcall= "Rscript ./scripts/make_pairs_list.r -i %s -n %s" % (input,name)
    subprocess.call(rcall, shell=True)

def makeEmb(name,seed):
    rcall= "Rscript ./scripts/tSNE_perceptual_dist.r -n %s -s %s" % (name,seed)
    subprocess.call(rcall, shell=True)


def load_images(img_names,name):
    images = []
    files = img_names
    for myFile in files:
        print(myFile)
        #image = cv2.imread ('./males64/%s' % myFile)
        image = plt.imread ('./model_ready_images/%s/%s' % (name, myFile))
        #image = image[:,:,::-1]
        #my_cmap = copy.copy(plt.cm.get_cmap('gray')) # get a copy of the gray color map
        #my_cmap.set_bad(alpha=0)
        #image[image< 3.] = np.nan
        images.append (image)
    return images


def visualize_scatter_with_images(name,data, figsize=(45,45), image_zoom=4):
    xycords=data[['X','Y']]
    X_2d_data=xycords.values
    images=load_images(data.image,name)
    fig, ax = plt.subplots(figsize=figsize)
    artists = []
    for xy, i in zip(X_2d_data, images):
        x0, y0 = xy
        img = OffsetImage(i, zoom=image_zoom)
        ab = AnnotationBbox(img, (x0, y0), xycoords='data', frameon=False)
        artists.append(ax.add_artist(ab))
    ax.update_datalim(X_2d_data)
    ax.autoscale()
    plt.show()
    plot_name="./plots/%s.eps" % name
    plt.savefig(plot_name,format='eps',transparent='TRUE')

def main():
    argv = sys.argv[1:]
    (input,name,seed) = getArgs(argv)
    makeModelReadyImages(input,name)
    makePairsList(input,name)

    data=pd.read_csv("./datatables/%s_pairs_list.csv" % name)

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
        model_input_dir= "./model_ready_images/%s" % (name)
        img_1_path="%s/%s" % (model_input_dir, row['img1'])
        img_2_path="%s/%s" % (model_input_dir, row['img2'])
        img_1=util.load_image(img_1_path)
        img_2=util.load_image(img_2_path)
        ex_ref = util.im2tensor(img_1)
        ex_p1 = util.im2tensor(img_2)
        ex_d0 = model.forward(ex_ref,ex_p1)
        dist.append(ex_d0)
        print(ex_d0)

    data.distance=dist
    data.to_csv("./datatables/output_%s_data.csv" % name)
    makeEmb(name,seed)
    emb_path="./datatables/%s_emb.csv" % name
    data=pd.read_csv(emb_path)
    visualize_scatter_with_images(name=name,data=data)
    sys.exit()

if __name__ == "__main__":
    main()
