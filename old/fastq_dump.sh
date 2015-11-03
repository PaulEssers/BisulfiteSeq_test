#!/bin/bash
echo "Creating required folders"

mkdir ../slurm_logs
mkdir ../fastqc
mkdir ../tmp


top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/

#############################################################################
echo 'downloading files from SRA'

echo "#!/bin/bash
module load sratoolkit
cd ${raw}
fastq-dump --split-files -gzip SRR2319536 
fastq-dump --split-files -gzip SRR2319537
fastq-dump --split-files -gzip SRR2319538
fastq-dump --split-files -gzip SRR2319539
rm ${tmp}fastq_dump.sh" > ${tmp}fastq_dump.sh

echo "#!/bin/bash
cd ${raw}
mv SRR2319536_1.fastq.gz control2_1.fastq.gz
mv SRR2319537_1.fastq.gz control3_1.fastq.gz
mv SRR2319538_1.fastq.gz epsilon10_1.fastq.gz
mv SRR2319539_1.fastq.gz epsilon12_1.fastq.gz

mv SRR2319536_2.fastq.gz control2_2.fastq.gz
mv SRR2319537_2.fastq.gz control3_2.fastq.gz
mv SRR2319538_2.fastq.gz epsilon10_2.fastq.gz
mv SRR2319539_2.fastq.gz epsilon12_2.fastq.gz
rm ${tmp}rename.sh" > ${tmp}rename.sh


cd ${tmp}
chmod 755 ${tmp}rename.sh
chmod 755 ${tmp}fastq_dump.sh

rm ../slurm_logs/fastq_dump.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=4 -o ../slurm_logs/fastq_dump.%j.out ${tmp}fastq_dump.sh 2>&1 | tee ${tmp}fastq_dump_id
id=$(cat ${tmp}fastq_dump_id | grep 'Submitted batch job')

sbatch -p blade,himem,hugemem -d afterok${id:20} --cpus-per-task=1 -o ../slurm_logs/rename.%j.out ${tmp}rename.sh 2>&1
echo "fastq dump done"

