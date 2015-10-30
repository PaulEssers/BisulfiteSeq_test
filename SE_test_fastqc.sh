echo "Starting FASTQC"
module load Java

top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/

cd ${raw}

if [[ -e ${tmp}fastqc.ids ]]; then
rm ${tmp}fastqc.ids
fi

file=test.fastq

echo "#!/bin/bash
module load FastQC
fastqc -t 18 -o ../fastqc ${rawt}${file}
rm ${tmp}fastqc_${file::(-6)}.sh" > ${tmp}fastqc_${file::(-6)}.sh

cd ${tmp}
chmod 755 ${tmp}fastqc_${file::(-6)}.sh
rm ../slurm_logs/fastqc_${file::(-6)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/fastqc_${file::(-6)}.%j.out ${tmp}fastqc_${file::(-6)}.sh 2>&1 | tee ${tmp}fastqc_${file::(-5)}id

id=$(cat ${tmp}fastqc_${file::(-5)}id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}fastqc.ids
rm ${tmp}fastqc_${file::(-5)}id

fastqc_ids=$(cat ${tmp}fastqc.ids)
srun -p blade,himem,hugemem -d afterok${fastqc_ids} echo "FASTQC done"
