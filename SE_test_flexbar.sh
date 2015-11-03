echo 'Starting Flexbar'

tmp=$(readlink -f ../tmp)/
top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/


cd ${tmp}

if [[ -e ${tmp}flexbar.ids ]]; then
rm ${tmp}flexbar.ids
fi

cd ${raw}
#head -n 40000000 SRR*8.fastq > subset68.fastq

file=subset68.fastq

echo "#!/bin/bash
module load Flexbar
flexbar -r ${raw}${file} \
-t ${top}raw_trimmed/${file::(-6)} \
-n 18 -f sanger \
-a ${top}adaptors.fa \
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
