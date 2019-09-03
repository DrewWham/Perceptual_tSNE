library(data.table)
library(optparse)
library(Rtsne)
library(phangorn)
library(ggtree)
library(ggimage)
library(ape)
library(treeio)
library(pvclust)
library(ggrepel)

set.seed(1)
option_list = list(
make_option(c("-s", "--seed"), type="numeric", default=1,
help="random seed", metavar="character"),
make_option(c("-p", "--perplexity"), type="numeric", default=15,
help="tSNE perplexity", metavar="character"),
make_option(c("-n", "--name"), type="character", default=NULL,
help="output file base name [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

name<-opt$name
set.seed(opt$seed)
prpx<-opt$perplexity

input_path<-paste0("./datatables/output_",name,"_data.csv")


in_data<-fread(input_path,drop=1,header=T)

in_data$distance<-gsub("[^0-9\\.]", "", in_data$distance)

in_data$distance<-as.numeric(in_data$distance)


in_data<-in_data[,.(img1,img2,distance)]








data_dist<-dcast(in_data,img1~img2,value.var="distance")
dm<-as.dist(data_dist[,-1])


data_tsne<-Rtsne(dm,perplexity=prpx,is_distance=TRUE)
data_emb<-cbind(data_dist$img1,data_tsne$Y)


data_emb<-data.table(data_emb)



setnames(data_emb,c("V1","V2","V3"),c("image","X","Y"))

emb_out_name<-paste0("./datatables/",name,"_emb.csv")

fwrite(data_emb,emb_out_name)


input_path<-paste0("./datatables/output_",name,"_data.csv")

data<-fread(input_path,drop=1,header=T)

data$distance<-gsub("[^0-9\\.]", "", data$distance)

data$distance<-as.numeric(data$distance)
#data$img1<-gsub(".jpg", "", data$img1)
#data$img2<-gsub(".jpg", "", data$img2)

data<-data[,.(img1,img2,distance)]

img_lst<-data.table(img=unique(data$img1))
indx_mtx<-matrix(1:dim(img_lst)[1],nrow=100,ncol=dim(img_lst)[1],byrow=T)



data_dist<-dcast(data,img1~img2,value.var="distance")
dm<-as.dist(data_dist[,-1])

colnames(indx_mtx)<-names(data_dist)[-1]
rownames(indx_mtx)<-paste0('id_',1:nrow(indx_mtx))

perceptual<-function(x){
    data_tsne<-Rtsne(dm,perplexity=prpx,is_distance=TRUE)
    tsne_m<-data_tsne$Y
    rownames(tsne_m)<-names(data_dist)[-1]
    dist_m<-dist(tsne_m)
    attr(dist_m,"method")<- "perceptual"
	dist_m
}

result <- pvclust(indx_mtx, method.dist=perceptual, nboot=1000,r=1,method.hclust="average")

hc_node2tips<-function(i,dt_hc){
    tips<-NULL
    node_vec<-i
    while (length(node_vec)>0){
        node_vec<-c(node_vec,dt_hc[node_hc==node_vec[1],V1],dt_hc[node_hc==node_vec[1],V2])
        node_vec<-node_vec[-1]
        tips<-c(tips,node_vec[node_vec<0])
        node_vec<-node_vec[!node_vec<0]
    }
    tips<-tips*(-1)
    tips<-sort(tips)
    out<-paste0(tips,collapse="-")
    return(out)
}

py_node2tips<-function(i,dt_py){
    u_nodes<-unique(dt_py$V1)
    tips<-NULL
    node_vec<-i
    while (length(node_vec)>0){
        node_vec<-c(node_vec,dt_py[V1==node_vec[1],V2])
        node_vec<-node_vec[-1]
        tips<-c(tips,node_vec[!node_vec %in% u_nodes])
        node_vec<-node_vec[node_vec %in% u_nodes]
    }
    tips<-tips
    tips<-sort(tips)
    out<-paste0(tips,collapse="-")
    return(out)
}



pvclust2phylo_nodes<-function(pvclust){
    hclust.merge<-pvclust$hclust$merge
    phylo.edge<-as.phylo(pvclust$hclust)$edge
    dt_hc<-data.table(hclust.merge)
    dt_hc$node_hc<-1:nrow(dt_hc)
    dt_py<-data.table(phylo.edge)
    py_nodes<-unique(dt_py$V1)
    dt_hc$node_tips<-sapply(1:nrow(dt_hc),FUN=function(x){hc_node2tips(x,dt_hc)})
    py_node_tips<-sapply(py_nodes,FUN=function(x){py_node2tips(x,dt_py)})
    dt_py<-data.table(node_py=py_nodes,node_tips=py_node_tips)
    setkey(dt_hc,node_tips)
    setkey(dt_py,node_tips)
    out_dt<-merge(dt_hc,dt_py,all.x=T)
    out_dt<-out_dt[,.(node_hc,node_py)][order(node_hc)]
    out_dt$bp<-round(100*pvclust$edges$bp)
    return(out_dt)
}

nodes<-pvclust2phylo_nodes(result)
nodes<-nodes[order(node_py)]




photo_tree_name<-paste0("./plots/",name,"_image_tree.eps")
img_info<-data.frame(labels=result$hclust$labels)
print(result$hclust$labels)
img_info$img_path<-paste0('./model_ready_images/',name,'/',img_info$labels)

setEPS()
postscript(photo_tree_name)
ggtree(as.phylo(result$hclust),layout="daylight")+geom_text(aes(label=c(rep(NA,length(result$hclust$labels)),nodes$bp)),col="red", hjust=0)+geom_tiplab(aes(image= paste0('./model_ready_images/',name,'/',label)), geom="image", align=F, hjust=4)

dev.off()


result$hclust$labels<-tstrsplit(result$hclust$labels,"[.]")[[1]]

tree_name<-paste0("./plots/",name,"_upgma.eps")

setEPS()
postscript(tree_name)
plot(result,col.pv=c('white','red','white'),main="Cluster dendrogram with BP values (%)")
#ggtree(as.phylo(result$hclust))+geom_text(aes(label=c(rep(NA,length(result$hclust$labels)),nodes$bp)),col="red", hjust=0)+geom_tiplab()
dev.off()






