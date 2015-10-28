top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/
# bt2=$(readlink -f ../bowtie2)/


if [[ -e ${tmp}bismark.ids ]]; then
rm ${tmp}bismark.ids
fi

bsm=$(readlink -f ../bismark)

cd ${rawt}
file=test.fastq

# only run once per pair of files
echo "#!/bin/bash
cd ${rawt}
module load Bowtie2
module load Bismark
bismark --bowtie2 -N 1 -o ${bsm} ${bsm} ${rawt}${file}
rm ${tmp}bismark_${file::(-6)}.sh" > ${tmp}bismark_${file::(-6)}.sh

cd ${tmp}
chmod 755 ${tmp}bismark_${file::(-6)}.sh
rm ../slurm_logs/bismark_${file::(-6)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=2 -o ../slurm_logs/bismark_${file::(-6)}.%j.out ${tmp}bismark_${file::(-6)}.sh 2>&1 | tee ${tmp}bismark_${file::(-6)}.id
id=$(cat ${tmp}bismark_${file::(-6)}.id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}bismark.ids
rm ${tmp}bismark_${file::(-6)}.id

# bismark_ids=$(cat ${tmp}bismark.ids)
# srun -p blade,himem,hugemem -d afterok${bismark_ids} echo "bismark done"
