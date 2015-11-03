module load sratoolkit
cd ../raw
srun fastq-dump SRR2232567
srun fastq-dump SRR2232568
cd -
