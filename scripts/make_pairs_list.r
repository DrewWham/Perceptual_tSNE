library(data.table)
library("optparse")

option_list = list(
make_option(c("-i", "--input"), type="character", default=NULL,
help="dataset file path", metavar="character"),
make_option(c("-n", "--name"), type="character", default=NULL,
help="output file base name [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

imgs<-list.files(opt$input)

combos<-expand.grid(imgs,imgs)

names(combos)<-c("img1","img2")

combos$distance<-0

out_name<-paste0("./datatables/",opt$name,"_pairs_list.csv")

fwrite(combos,out_name)



