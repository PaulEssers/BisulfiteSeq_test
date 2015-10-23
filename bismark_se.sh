top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/
# bt2=$(readlink -f ../bowtie2)/


if [[ -e ${tmp}bismark.ids ]]; then
rm ${tmp}bismark.ids
fi


mkdir ../bismark
bsm=$(readlink -f ../bismark)
cd ${rawt}

# only run once per pair of files
for file in $(ls *.fastq); do echo "#!/bin/bash
cd ${rawt}
module load Bowtie2
module load Bismark
bismark --bowtie2 -N 1 -o ${bsm} ${bsm} ${rawt}${file}
rm ${tmp}bismark_${file::(-9)}.sh" > ${tmp}bismark_${file::(-9)}.sh

cd ${tmp}
chmod 755 ${tmp}bismark_${file::(-9)}.sh
rm ../slurm_logs/bismark_${file::(-9)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=2 -o ../slurm_logs/bismark_${file::(-9)}.%j.out ${tmp}bismark_${file::(-9)}.sh 2>&1 | tee ${tmp}bismark_${file::(-9)}.id
id=$(cat ${tmp}bismark_${file::(-9)}.id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}bismark.ids
rm ${tmp}bismark_${file::(-9)}.id
done

bismark_ids=$(cat ${tmp}bismark.ids)
srun -p blade,himem,hugemem -d afterok${bismark_ids} echo "bismark done"
