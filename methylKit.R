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

# read the SAM file output from bismark
# needed to sort before this:
# srun samtools sort -T temp -O sam test.fastq_bismark_bt2.sam > test.bismark.sorted.sam

my.methRaw=read.bismark(location="test.bismark.sorted.sam", sample.id="test",assembly="mm10",read.context="CpG",save.folder=getwd())
