library(data.table)
library(optparse)
library(Rtsne)
set.seed(1)
option_list = list(
make_option(c("-s", "--seed"), type="numeric", default=1,
help="random seed", metavar="character"),
make_option(c("-n", "--name"), type="character", default=NULL,
help="output file base name [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

name<-opt$name
set.seed(opt$seed)

input_path<-paste0("./datatables/output_",name,"_data.csv")


in_data<-fread(input_path,drop=1,header=T)

in_data$distance<-gsub("[^0-9\\.]", "", in_data$distance)

in_data$distance<-as.numeric(in_data$distance)


in_data<-in_data[,.(img1,img2,distance)]








data_dist<-dcast(in_data,img1~img2,value.var="distance")
data_tsne<-Rtsne(data_dist,perplexity=15,pca=FALSE)
data_emb<-cbind(data_dist$img1,data_tsne$Y)


data_emb<-data.table(data_emb)



setnames(data_emb,c("V1","V2","V3"),c("image","X","Y"))

emb_out_name<-paste0("./datatables/",name,"_emb.csv")

fwrite(data_emb,emb_out_name)






