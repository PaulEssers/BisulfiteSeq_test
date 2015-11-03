# dependencies
install.packages( c("data.table","devtools"))
source("http://bioconductor.org/biocLite.R")
biocLite(c("GenomicRanges","IRanges"))

# install the development version from github
library(devtools)
install_github("al2na/methylKit",build_vignettes=FALSE)

library(methylKit)

home<-getwd()
bismark.folder<-paste0(home,"/bismark/")
setwd(bismark.folder)

# analysed the data with Bismark, but only used 10 milion reads of each sample (out of 500 milion available)
#
# read the SAM file output from bismark
# needed to sort before this:
# srun samtools sort -T temp -O sam test.fastq_bismark_bt2.sam > test.bismark.sorted.sam

subset67=read.bismark(location="subset67.bismark.sorted.sam", sample.id="subset67",assembly="mm10",read.context="CpG",save.folder=getwd())
subset68=read.bismark(location="subset68.bismark.sorted.sam", sample.id="subset68",assembly="mm10",read.context="CpG",save.folder=getwd())


# this produces a file which contains non-numerical chromosome names, this is then a problem to read in. Made a separate file, removing these and loaded the text file again.

meth=methylKit::read(list("subset67_CpG_only_numerical_chromosomes.txt","subset68_CpG_only_numerical_chromosomes.txt"), sample.id = list("pre-pro","pro"), treatment=c(0,1), assembly="mm10", pipeline="bismark")


# print some basic stats:
getMethylationStats(meth[[1]],plot=T,both.strands=T)
getMethylationStats(meth[[2]],plot=T,both.strands=T)
library ("graphics")
getCoverageStats(meth[[1]],plot=T,both.strands=T)
getCoverageStats(meth[[2]],plot=T,both.strands=T)

# filter on minimum coverage of 10 and remove reads in >99.9th percentile (the last is basically dedup step)
meth=filterByCoverage(meth,lo.count=10,lo.perc=NULL,hi.count=NULL,hi.perc=99.9)


meth=unite(meth, destrand=FALSE)
getCorrelation(meth,plot=T)

myDiff=calculateDiffMeth(meth)

myDiff10p.hypo=get.methylDiff(myDiff,difference=5,qvalue=0.5,type="hypo")
myDiff10p.hypo

diffMethPerChr(myDiff,plot=T,qvalue.cutoff=0.2, meth.cutoff=10)

# this fails for some reason, maybe not enough differentially regulated sites from the minor amount of data I used.
gene.obj=read.transcript.features("UCSC_mm10.bed")
annotated<-annotate.WithGenicParts(myDiff10p.hypo,gene.obj)
