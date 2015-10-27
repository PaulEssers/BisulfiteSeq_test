echo 'Starting Flexbar'
mkdir ../raw_trimmed
tmp=$(readlink -f ../tmp)/
top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/


cd ${raw}
# need to do this only once:
# srun zcat control2_1.fastq.gz | head -n 2000 > test_1.fastq
# srun zcat control2_2.fastq.gz | head -n 2000 > test_2.fastq

if [[ -e ${tmp}flexbar.ids ]]; then
rm ${tmp}flexbar.ids
fi

for file in $(ls test*.fastq); do

if [[ -e ${tmp}bismark_${file::(-8)}.sh ]]
then echo "mate 2: ${file}"
else
echo "mate 1: ${file}"

echo "#!/bin/bash
module load Flexbar
flexbar -r ${raw}${file::(-8)}_1.fastq ${raw}${file::(-8)}_1.fastq \
-t ${rawt} -n 18 -f sanger -a ${top}adaptors.fa \
--pre-trim-phred 20 --min-read-length 25 --max-uncalled 2
cd ${top}raw_trimmed
rm ${tmp}flexbar_${file::(-8)}sh" > ${tmp}flexbar_${file::(-8)}sh


cd ${tmp}
chmod 755 ${tmp}flexbar_${file::(-8)}sh
rm ../slurm_logs/flexbar_${file::(-8)}*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/flexbar_${file::(-8)}%j.out ${tmp}flexbar_${file::(-8)}sh 2>&1 | tee ${tmp}flexbar_${file::(-8)}id
id=$(cat ${tmp}flexbar_${file::(-8)}id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}flexbar.ids
rm ${tmp}flexbar_${file::(-8)}id
fi
done
