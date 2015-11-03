# BisulfiteSeq_test
Analysis of methylation status from publicly available bisulfite sequencing data using Bismark

Downloaded the bisulfite-seq data from: http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72860

consistently got very low mapping efficiency, cannot figure out why

Downloaded another data set: http://www.ncbi.nlm.nih.gov/sra/?term=SRR2232567

tested 1000 reads with SE_test_flexbar.sh and SE_test_bismark.sh -> this worked nicely (75% mapping efficiency) so contiue with this.

-> all the other files (not SE_test_*.sh) didn't work so far, but it is unclear wether this is due to me or the data

Use methylKit R package to analyse further.
