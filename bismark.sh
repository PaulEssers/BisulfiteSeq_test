top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/
bt2=$(readlink -f ../raw_trimmed)/


mkdir ../bismark
bsm=$(readlink -f ../bismark)
cd ${rawt}

for file in $(ls *.fastq); do echo "#!/bin/bash
cd ${rawt}
module load Bowtie2
module load Bismark
bismark --bowtie2 -o ${bsm} ${tmp}/Bisulfite_Genome/ ${rawt}${file}
rm ${tmp}bismark_${file::(-5)}sh" > ${tmp}bismark_${file::(-5)}sh

cd ${tmp}
chmod 755 ${tmp}bismark_${file::(-5)}sh
rm ../slurm_logs/bismark_${file::(-5)}*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/bismark_${file::(-5)}%j.out ${tmp}bismark_${file::(-5)}sh 2>&1 | tee ${tmp}bismark_${file::(-5)}id
id=$(cat ${tmp}bismark_${file::(-5)}id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}bismark.ids
rm ${tmp}bismark_${file::(-5)}id
done

bismark_ids=$(cat ${tmp}bismark.ids)
srun -p blade,himem,hugemem -d afterok${bismark_ids} echo "bismark done"
