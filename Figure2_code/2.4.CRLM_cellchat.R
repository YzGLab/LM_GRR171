###

####
##具体思路：
#1：meta 单细胞  肝转移人群，
#2：肝癌队列表达特征
########计算评分 并计算差异

SingleScore.path <-"Results/SingleScoreFeatures"
if (!file.exists(SingleScore.path )) { dir.create(SingleScore.path) }
#####
library(gghalves)
library(ggpubr)
library(GEOquery)
library(dplyr)
library(tidyverse)
library(pheatmap)
library(Seurat)
library(clustree)
#library(scater)
library(dittoSeq)
library(readxl)
library(ggsci)
library(AUCell)
library(RColorBrewer)
library(corrplot)#
library(reshape2)
library(GSVA)
library(ggplot2)
library(data.table)
library(tidyr)
library(clusterProfiler)

#########################
###

##
#setwd("/home/data/wuchenghao/CRC_livermeta/")
mycol<-c('#1B9E77','#7FC97F','#BEAED4','#FDC086','#FFFF99','#386CB0','#F0027F', '#BF5B17', '#E41A1C', 
         '#D95F02','#7570B3','#E7298A', '#66A61E','#E6AB02','#A6761D','#666666',
         '#377EB8','#4DAF4A', '#984EA3','#FF7F00', '#FFFF33', '#A65628', '#F781BF', '#999999',
         '#8DD3C7', '#FFFFB3','#BEBADA', '#FB8072','#80B1D3','#FDB462','#B3DE69', '#FCCDE5',
         '#D9D9D9','#BC80BD','#CCEBC5', '#FFED6F','#66C2A5', '#FC8D62','#8DA0CB','#E78AC3',
         '#A6D854','#FFD92F', '#E5C494', '#B3B3B3','#A6CEE3', '#1F78B4', '#B2DF8A', '#33A02C',
         '#FB9A99', '#E31A1C','#FDBF6F', '#FF7F00', '#CAB2D6', '#6A3D9A', '#FFFF99', '#B15928')
###load data
sce<-readRDS("/home/data/gaoyuzhen/Projects/CRCprojects/CRC_livermeta/CRC_liver.RDS")

VlnPlot(sce[,sce$source=="LM"],features="GPR171",group.by = "customclassif",pt.size = 0,cols=mycol) & NoLegend()
FeaturePlot(sce[,sce$source=="CRC"],features="GPR171",reduction = "tsne",split.by = "source")+ 
  tidydr::theme_dr(xlength = 0.1,ylength = 0.1) +
  theme(panel.grid = element_blank(),aspect.ratio = 1)#

FeaturePlot(sce[,sce$source=="LM"],features="GPR171",reduction = "tsne",split.by = "source")
FeaturePlot(sce[,sce$source=="CRC"],features="GPR171",reduction = "tsne",split.by = "source")
FeaturePlot(sce[,sce$source=="PBMC"],features="GPR171",reduction = "tsne",split.by = "source")
ggsave("GPR171.pdf",width = 7,height = 7)


DimPlot(sce,reduction = "tsne",gsplit.by = "source",cols=mycol)+ 
  tidydr::theme_dr(xlength = 0.1,ylength = 0.1) +
  theme(panel.grid = element_blank(),aspect.ratio = 1)#
DimPlot(sce[,sce$customclassif=="Cancer cells"],reduction = "tsne",split.by = "source",cols=mycol)+ 
  tidydr::theme_dr(xlength = 0.1,ylength = 0.1) +
  theme(panel.grid = element_blank(),aspect.ratio = 1)#
DimPlot(sce[,sce$source=="LM"],reduction = "tsne",group.by = "type",cols=mycol[c(9,6)])+ 
  tidydr::theme_dr(xlength = 0.1,ylength = 0.1) +
  theme(panel.grid = element_blank(),aspect.ratio = 1)#
DimPlot(sce[,sce$source=="LM"],reduction = "tsne",group.by = "assign.ident",cols=mycol)+ 
  tidydr::theme_dr(xlength = 0.1,ylength = 0.1) +
  theme(panel.grid = element_blank(),aspect.ratio = 1)#
###cell chat 
##




####################cellchat 
library(CellChat)
library(patchwork)
library(ggplot2)
library(ggalluvial)
library(svglite)
library(Seurat)
library(SeuratData)
options(stringsAsFactors = FALSE)


load("CRC_meta_sce.Rdata")
subsce<-readRDS("CRC_subsce.RDS")

#write.table(data.input, 'cellphonedb_count.txt', sep='\t', quote=F)
data.input<-subsce@assays$RNA@data
data.input<-data.input[,colnames(data.input) %in% meta$Index]
data.input<-as.matrix(data.input)
###
library(CellChat)
library(patchwork)
library(ggplot2)
library(ggalluvial)
library(svglite)
library(Seurat)
library(SeuratData)
cellchat <- createCellChat(object = data.input, meta = meta, group.by = "Cell_type")
###
cellchat <- addMeta(cellchat, meta = meta)
cellchat <- setIdent(cellchat, ident.use = "Cell_type") # set "labels" as default cell identity
levels(cellchat@idents) # show factor levels of the cell labels
groupSize <- as.numeric(table(cellchat@idents)) # number of cells in each cell group
###我们的数据库 CellChatDB 是一个手动整理的文献支持的配体受体在人和小鼠中的交互数据库。
##小鼠中的CellChatDB包含2，021个经验证的分子相互作用，包括60%的自分泌/旁分泌信号相互作用
##、21%的细胞外基质（ECM）受体相互作用和19%的细胞-细胞接触相互作用。人的CellChatDB包含1，939个经验证的分子相互作用，
##包括61.8%的自分泌/旁分泌信号相互作用、21.7%的细胞外基质（ECM）受体相互作用和16.5%的细胞-细胞接触相互作用。
##
CellChatDB <- CellChatDB.human # use CellChatDB.mouse if running on mouse data
#showDatabaseCategory(CellChatDB)
#### Show the structure of the database
dplyr::glimpse(CellChatDB$interaction)
# use a subset of CellChatDB for cell-cell communication analysis
#CellChatDB.use <- subsetDB(CellChatDB, search = "Secreted Signaling") # use Secreted Signaling
# use all CellChatDB for cell-cell communication analysis
CellChatDB.use <- CellChatDB # simply use the default CellChatDB
# set the used database in the object
cellchat@DB <- CellChatDB.use
##预处理
cellchat <- subsetData(cellchat) # subset the expression data of signaling genes for saving computation cost
future::plan("multiprocess", workers = 70) # do parallel
cellchat <- identifyOverExpressedGenes(cellchat)
future::plan("multiprocess", workers = 70) # do parallel
cellchat <- identifyOverExpressedInteractions(cellchat)
future::plan("multiprocess", workers = 70) # do parallel
cellchat <- projectData(cellchat, PPI.human)
##在分析未分类的单细胞转录组时，假设丰富的细胞群倾向于发送比稀有细胞群更强的信号，
#CellChat 还可以在概率计算中考虑每个细胞组中细胞比例的影响。用户可以设置population.size = TRUE
#计算通信概率并推断cellchat网络##type = "truncatedMean"和对trim = 0.1。
future::plan("multiprocess", workers = 70) # do parallel
cellchat <- computeCommunProb(cellchat, raw.use = TRUE,population.size = TRUE)
# Filter out the cell-cell communication if there are only few number of cells in certain cell groups
future::plan("multiprocess", workers = 70) # do parallel
cellchat <- filterCommunication(cellchat, min.cells = 2)

##
df.net <- subsetCommunication(cellchat)
write.csv(df.net,file="df.net_all_LM.csv")




#df.net <- subsetCommunication(cellchat, sources.use = c(1,2), targets.use = c(4,5))#将推断的细胞-细胞通信从细胞组1和2发送到细胞组4和5。
#df.net <- subsetCommunication(cellchat, signaling = c("WNT", "TGFb"))#通过向WNT和TGFb发出信号来调节推断的细胞通信。
##在信号通路级别推断细胞-细胞通信
cellchat <- computeCommunProbPathway(cellchat)
##计算整合的细胞通信网络 我们可以通过计算链接数或汇总通信概率来计算整合的细胞通信网络。用户还可以通过设置sources.use和targets.use`
cellchat <- aggregateNet(cellchat)
groupSize <- as.numeric(table(cellchat@idents))
par(mfrow = c(1,2), xpd=TRUE)
netVisual_circle(cellchat@net$count,
                 vertex.weight = groupSize, 
                 weight.scale = T, 
                 label.edge= T,
                 title.name = "Number of interactions")

ggsave("full_manuscript.pdf")
netVisual_circle(cellchat@net$weight,
                 vertex.weight = groupSize, 
                 weight.scale = T, 
                 label.edge= F, 
                 title.name = "Interaction weights/strength")
##
mat <- cellchat@net$count
par(mfrow = c(2,3), xpd=TRUE)
for (i in 1:nrow(mat)) { 
  mat2 <- matrix(0, nrow = nrow(mat), ncol = ncol(mat), dimnames = dimnames(mat)) 
  mat2[, i] <- mat[,i]  
  pdf(paste0(gsub("/",".",rownames(mat))[i],"LM_network.pdf"))
  
  netVisual_circle(mat2, vertex.weight = groupSize, label.edge= T,  weight.scale = T, edge.weight.max = max(mat), title.name = rownames(mat)[i])
  dev.off()
}


###
mat <- cellchat@net$weight
par(mfrow = c(2,3), xpd=TRUE)
for (i in 1:nrow(mat)) { 
  mat2 <- matrix(0, nrow = nrow(mat), ncol = ncol(mat), dimnames = dimnames(mat)) 
  mat2[i, ] <- mat[i, ]  
  pdf(paste0(rownames(mat)[i],"network.pdf"))
  netVisual_circle(mat2, vertex.weight = groupSize, weight.scale = T, edge.weight.max = max(mat), title.name = rownames(mat)[i])
  dev.off()
}

##第三部分：细胞通信网络的可视化
cellchat@netP$pathways#示重要通信的信号通路均可通过
pathways.show <- c("SPP1") # Hierarchy plot# 
#Here we define `vertex.receive` so that the left portion of the hierarchy plot shows signaling to fibroblast and the right portion shows signaling to immune cells 
vertex.receiver = seq(1,4) # a numeric vector. 
netVisual_aggregate(cellchat, signaling = pathways.show,  vertex.receiver = vertex.receiver)
# Circle plot
par(mfrow=c(1,1))
##
colnames(meta)
levels(cellchat@idents)
Class<-meta$Class
names(Class) <- levels(cellchat@idents)
group.cellType <- c(rep("FIB", 8), rep("DC", 7), rep("TC",8)) # grouping cell clusters into fibroblast, DC and TC cells
names(group.cellType) <- levels(cellchat@idents)
par(mfrow=c(2,1))
netVisual_aggregate(cellchat, signaling = pathways.show, layout = "circle", group=group.cellType)
### Chord diagram
par(mfrow=c(1,1))
netVisual_aggregate(cellchat, signaling = pathways.show, layout = "chord")#> Note: The first link end is drawn out of sector 'Inflam. FIB'.
?netVisual_aggregate
# Heatmap
par(mfrow=c(1,1))
netVisual_heatmap(cellchat, signaling = pathways.show, color.heatmap = "Reds")#> Do heatmap based on a single object

# Chord diagram自定义名称 可以
group.cellType <- c(rep("FIB", 4), rep("DC", 4), rep("TC", 4)) # grouping cell clusters into fibroblast, DC and TC 
names(group.cellType) <- levels(cellchat@idents)
netVisual_chord_cell(cellchat, signaling = pathways.show, group = group.cellType, title.name = paste0(pathways.show, " signaling network"))#> Plot the aggregated cell-cell communication network at the signaling pathway level#> Note: The first link end is drawn out of sector 'Inflam. FIB'.

##计算每个配体受体对整体信号通路的贡献，并可视化由单个配体受体对调节的细胞通信
netAnalysis_contribution(cellchat, signaling = pathways.show)
##我们还可以可视化由单个配体受体对调节的细胞-细胞通信。我们提供一个函数extractEnrichedLR来提取给定信号通路的所有重要相互作用（L-R对）和相关信号基因
pairLR.CXCL <- extractEnrichedLR(cellchat, signaling = pathways.show, geneLR.return = FALSE)
LR.show <- pairLR.CXCL[1,] # show one ligand-receptor pair# Hierarchy plot
vertex.receiver = seq(1,4) # a numeric vecto
netVisual_individual(cellchat, signaling = pathways.show,  pairLR.use = LR.show, vertex.receiver = vertex.receiver)

# Circle plot
netVisual_individual(cellchat, signaling = pathways.show, pairLR.use = LR.show, layout = "circle")
#> [[1]]
# Chord diagram
netVisual_individual(cellchat, signaling = pathways.show, pairLR.use = LR.show, layout = "chord")#> Note: The first link end is drawn out of sector 'Inflam. FIB'.
##
# Access all the signaling pathways showing significant communications
pathways.show.all <- cellchat@netP$pathways# check the order of cell identity to set suitable vertex.receiver
levels(cellchat@idents)
vertex.receiver = seq(1,4)
# Visualize communication network associated with both signaling pathway and individual L-R pairs  
# Compute and visualize the contribution of each ligand-receptor pair to the overall signaling pathway  
for (i in 1:length(pathways.show.all)) {  
  netVisual(cellchat, signaling = pathways.show.all[i], 
            vertex.receiver = vertex.receiver,
            layout = "hierarchy")  
  gg <- netAnalysis_contribution(cellchat, signaling = pathways.show.all[i])  
  ggsave(filename=paste0(pathways.show.all[i], "_L-R_contribution.pdf"), plot=gg, width = 3, height = 2, units = 'in', dpi = 300)}

##气泡图

# show all the significant interactions (L-R pairs) from some cell groups (defined by 'sources.use') to other cell groups (defined by 'targets.use')
netVisual_bubble(cellchat, sources.use = c(1:4), targets.use = c(5:8), remove.isolate = FALSE)#> Comparing communications on a single object

# show all the significant interactions (L-R pairs) associated with certain signaling pathways
netVisual_bubble(cellchat, sources.use = 4, targets.use = c(1:6), signaling = c("CCL","CXCL"), remove.isolate = FALSE)#> Comparing communications on a single object

####类似气泡图
# show all the significant interactions (L-R pairs) from some cell groups (defined by 'sources.use') to other cell groups (defined by 'targets.use')
# show all the interactions sending from Inflam.FIB
netVisual_chord_gene(cellchat, sources.use = 4, targets.use = c(1:6), lab.cex = 0.5,legend.pos.y = 30)#> Note: The first link end is drawn out of sector 'MIF'.
# show all the interactions received by Inflam.DC
netVisual_chord_gene(cellchat, sources.use = c(1,2,3,4), targets.use = 3, legend.pos.x = 15)
# show all the significant interactions (L-R pairs) associated with certain signaling pathways
netVisual_chord_gene(cellchat, sources.use = c(1,2,3,4), targets.use = c(1:6), signaling = c("CCL","CXCL"),legend.pos.x = 8)#> Note: The second link end is drawn out of sector 'CXCR4 '.#> Note: The first link end is drawn out of sector 'CXCL12 '.
# show all the significant signaling pathways from some cell groups (defined by 'sources.use') to other cell groups (defined by 'targets.use')
netVisual_chord_gene(cellchat, sources.use = c(1,2,3,4), targets.use = c(1:6), slot.name = "netP", legend.pos.x = 10)#> Note: The second link end is drawn out of sector ' '.#> Note: The first link end is drawn out of sector 'MIF'.#> Note: The second link end is drawn out of sector ' '.#> Note: The first link end is drawn out of sector 'CXCL '.


##我们可以利用Seurat 包装的函数plotGeneExpression绘制与L-R对或信号通路相关的信号基因的基因表达分布图
plotGeneExpression(cellchat, signaling = "CXCL")#> Registered S3 method overwritten by 'spatstat':
plotGeneExpression(cellchat, signaling = "CXCL", enriched.only = FALSE)## full genes

##第四部分：细胞通信网络系统分析
# Compute the network centrality scores
cellchat <- netAnalysis_computeCentrality(cellchat, slot.name = "netP") # the slot 'netP' means the inferred intercellular communication network of signaling pathways
# Visualize the computed centrality scores using heatmap, allowing ready identification of major signaling roles of cell groups
netAnalysis_signalingRole_network(cellchat, signaling = pathways.show, width = 8, height = 2.5, font.size = 10)
#在 2D 空间中可视化占主导地位的发送器（源）和接收器（目标
# Signaling role analysis on the aggregated cell-cell communication network from all signaling pathway
gg1 <- netAnalysis_signalingRole_scatter(cellchat)
#> Signaling role analysis on the aggregated cell-cell communication network from all signaling pathways
# Signaling role analysis on the cell-cell communication networks of interest
gg2 <- netAnalysis_signalingRole_scatter(cellchat, signaling = c("CXCL", "CCL"))
#> Signaling role analysis on the cell-cell communication network from user's input
gg1 + gg2
ggsave("outgoing_incoming_cellchat.pdf")
##识别对某些细胞组的传出或传入信号贡献最大的信号
# Signaling role analysis on the aggregated cell-cell communication network from all signaling pathways
ht1 <- netAnalysis_signalingRole_heatmap(cellchat, pattern = "outgoing")
ht2 <- netAnalysis_signalingRole_heatmap(cellchat, pattern = "incoming")
ht1 + ht2

# Signaling role analysis on the cell-cell communication networks of interest
ht <- netAnalysis_signalingRole_heatmap(cellchat, signaling = c("CXCL", "CCL"))
ht
































#########
#############################
#####
colnames(sce@meta.data)
sce@meta.data[,c(9:39)]<-c()

#15089
meta_lmscore<-sce@meta.data
save(meta_lmscore,file=file.path(SingleScore.path,"liver_metascore.Rdata"))
##tsne plot for the sce 
Gsum<-summary(sce[,sce$customclassif=="Cancer cells"]$LMCScore1)
Gsum[3]
lmscore<-sce[,sce$customclassif=="Cancer cells"]$LMCScore1
#LMCScore_subtype <- as.data.frame(quantile(lmscore,probs = seq(0,1,0.25)))
#LMCScore_subtype<-levels(cut(lmscore, breaks = 4))
subsce<-sce[,sce$customclassif=="Cancer cells"]
subsce<-subsce[,subsce$source=="LM"]
subsce<-AddModuleScore(subsce,features = DEGs_pathwaylist,names=names(DEGs_pathwaylist))
meta<-subsce@meta.data
colnames(meta)[c(12:40)]<-names(DEGs_pathwaylist)

gsva_es_single<-t(meta[,c(12:40)])
dist.e=dist(t(gsva_es_single),method='euclidean')
hclust(dist.e, method = "complete", members = NULL)
tree <- hclust(dist.e, method = "ward.D2")
plot(tree,labels = FALSE, hang = -3, main = "MetaSubtype")
#plot(tree, hang = -5)
# save figures
pdf(file.path(Cluster.path,"hcluster_fig_single.pdf"))
plot(tree,labels = FALSE, hang = -3, main = "MetaSubtype")
dev.off()
###############################
#cutree 
group<-cutree(tree, k =6)
group_cluster<-group
group_cluster<-data.frame(group_cluster)
group_cluster <-cbind(Sample_id=rownames(group_cluster),group_cluster)
##heatmap for subsce
subsce<-AddMetaData(subsce,metadata = group_cluster,col.name = colnames(group_cluster))
colnames(subsce@meta.data)[c(12:40)]<-names(DEGs_pathwaylist)
colnames(subsce@meta.data)
meta<-subsce@meta.data
#
meta<-meta[order(meta$LMCScore1,decreasing = T),]
#DoHeatmap(susce,)
#"#FF7F00","#A6CEE3","#E31A1C","#33A02C","#999999"
col = list(
  group_cluster= c('4'="#E31A1C",
                   '6'=mycol[6],
                   '5'=mycol[3],
                   '2'=mycol[2],
                   '1'=mycol[4],
                   "3"="grey")
  #biopsy_tissue_bio= c("nonliver"="white","liver"="black")
  #tissue= c("Bone"="#FF7F00","Brain"="#A6CEE3", "Liver"="#E31A1C", "Lung"="#33A02C"),
  #tumor= c("Breast"="#A6CEE3", "Colorectal"="#E31A1C", "Kidney"=mycol[4], "Lung"="#33A02C" ,"Prostate"=mycol[5],"Skin"=mycol[9] )
)
############
colnames(meta)
type<-meta[,c(5,9,42)]
ha1= HeatmapAnnotation(df=data.frame(type),
                       col=col,
                       #height = unit(30, "mm"),
                       gap=unit(0.4, "mm"),
                       #gp = gpar(fontsize=8),
                       #annotation_width =unit(4, "cm"),
                       annotation_name_side ="left"
                       #annotation_height = unit(3, "cm")
                       #width = 1
)
colnames(meta)
plotdata<-meta[,c(12:40)]
plotdata<-apply(plotdata,2,as.numeric)
rownames(plotdata)<-rownames(meta)
heatcluster<-t(scale(plotdata))##
heatcluster[heatcluster >2]  <- 2 # 
heatcluster[heatcluster < -2] <- -2 # 
#display.brewer.all()
p4<-Heatmap(heatcluster,
            name = "Z-score",
            cluster_columns = T,
            cluster_rows =T,
            #split = 4,
            #row_km = 2,
            #jitter = TRUE,
            #column_order=c("1","2","3","4"),
            #row_split = splits,
            column_split = meta$group_cluster,
            #row_labels = splits,
            gap = unit(1, "mm"),
            show_heatmap_legend = TRUE,
            row_names_gp = gpar(fontsize =9),
            #column_names_gp = gpar(fontsize = 8),
            col=colorRampPalette(c('blue','white','#E7298A'))(100), 
            #col=brewer.pal(n=9, name="YlGnBu"), 
            row_names_side = "left",
            #row_names_rot = 30,
            #row_names_max_width = unit(3, "cm"),
            show_column_names = FALSE,
            show_row_names = FALSE,
            #width = unit(120, "mm"),
            #height = unit(140, "mm"),
            top_annotation = ha1,
            #bottom_annotation=ha,
            #right_annotation = ha33,
            #left_annotation=ha33,
            row_dend_side = "left",
            show_row_dend=TRUE,
            show_column_dend = FALSE,
            #name = "ht2",
            border = TRUE,
            na_col = "grey",
            column_title_gp = gpar(fill = "WHITE", col = "BLACK", border = "WHITE"),
            row_title_gp = gpar(fill = "WHITE", col = "BLACK", border = "WHITE"),
            row_title = "Liver metastasis special Immune signatures",
            #column_title = "Combinded TME with HIF "
)
p4

pdf(file.path(SingleScore.path,"Immunosuppression_single_cell_heatmap.pdf"),width=10.68,height = 6.16)
p4
dev.off()
#########




