#!/bin/bash
# before running this script, downloaded data and renamed it
# mkdir ../scripts
# mkdir ../raw
# cd raw

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
module load srtoolkit
cd ${raw}
fastq-dump --split-files -gzip SRR2319536 
fastq-dump --split-files -gzip SRR2319537 
fastq-dump --split-files -gzip SRR2319538 
fastq-dump --split-files -gzip SRR2319539 

mv SRR2319536_1.fastq.gz control2_1.fastq.gz
mv SRR2319537_1.fastq.gz control3_1.fastq.gz
mv SRR2319538_1.fastq.gz epsilon10_1.fastq.gz
mv SRR2319539_1.fastq.gz epsilon12_1.fastq.gz

mv SRR2319536_2.fastq.gz control2_2.fastq.gz
mv SRR2319537_2.fastq.gz control3_2.fastq.gz
mv SRR2319538_2.fastq.gz epsilon10_2.fastq.gz
mv SRR2319539_2.fastq.gz epsilon12_2.fastq.gz


rm ${tmp}fastq_dump.sh" > ${tmp}fastq_dump.sh


cd ${tmp}
chmod 755 ${tmp}fastq_dump.sh
rm ../slurm_logs/fastq_dump.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=2 -o ../slurm_logs/fastq_dump.%j.out ${tmp}fastq_dump.sh 2>&1 | tee ${tmp}fastq_dump_id


#############################################################################

echo "Starting FASTQC"
module load Java

cd ${raw}

if [[ -e ${tmp}fastqc.ids ]]; then
rm ${tmp}fastqc.ids
fi

for file in $(ls *.fastq); do echo "#!/bin/bash

module load FastQC
cp ${raw}${file} ${tmp}
cd ${tmp}
echo ${file}
fastqc -t 10 -o ../fastqc ${file}
rm ${tmp}fastqc_${file::(-6)}.sh" > ${tmp}fastqc_${file::(-6)}.sh

cd ${tmp}
chmod 755 ${tmp}fastqc_${file::(-6)}.sh
rm ../slurm_logs/fastqc_${file::(-6)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=9 -o ../slurm_logs/fastqc_${file::(-6)}.%j.out ${tmp}fastqc_${file::(-6)}.sh 2>&1 | tee ${tmp}fastqc_${file::(-5)}id

id=$(cat ${tmp}fastqc_${file::(-5)}id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}fastqc.ids
rm ${tmp}fastqc_${file::(-5)}id
done

fastqc_ids=$(cat ${tmp}fastqc.ids)
srun -p blade,himem,hugemem -d afterok${fastqc_ids} echo "FASTQC done"


#############################################################################


echo 'Starting Flexbar'
mkdir ../raw_trimmed
tmp=$(readlink -f ../tmp)/
top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/


cd ${tmp}

if [[ -e ${tmp}flexbar.ids ]]; then
rm ${tmp}flexbar.ids
fi

for file in $(ls *.fastq); do

echo "#!/bin/bash
module load Flexbar
flexbar -r ${tmp}${file} \
-t ${top}raw_trimmed/${file::(-6)} \
-n 18 -f sanger \
--pre-trim-phred 20 --min-read-length 25 --max-uncalled 2

cd ${top}raw_trimmed
# pigz -p 10 ${file}
rm ${tmp}flexbar_${file::(-5)}sh" > ${tmp}flexbar_${file::(-5)}sh


cd ${tmp}
chmod 755 ${tmp}flexbar_${file::(-5)}sh
rm ../slurm_logs/flexbar_${file::(-5)}*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/flexbar_${file::(-5)}%j.out ${tmp}flexbar_${file::(-5)}sh 2>&1 | tee ${tmp}flexbar_${file::(-5)}id
id=$(cat ${tmp}flexbar_${file::(-5)}id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}flexbar.ids
rm ${tmp}flexbar_${file::(-5)}id
done

#############################################################################

# make a link to the genome to avoid permission errors, then have bismark index the genome with bowtie2.
# because the genome is large, running this with bowtie1 generates a large index which bismark then cannot read.
ln -s /beegfs/common/genomes/mus_musculus/GRCm38_81/toplevel_bowtie2/GRCm38.dna.toplevel.fa ../tmp/GRCm38.fa
srun --bowtie2 -o ../slurm_logs/bismark_genome.%j.out bismark_genome_preparation ../tmp/

echo "Starting Bismark Alignment with bowtie2"

# index=/beegfs/common/genomes/mus_musculus/GRCm38_81/toplevel_bowtie2/GRCm38.dna.toplevel
# mkdir ../bowtie2
