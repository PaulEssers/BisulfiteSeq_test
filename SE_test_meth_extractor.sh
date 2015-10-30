top=$(readlink -f ../)/
tmp=$(readlink -f ../tmp)/
raw=$(readlink -f ../raw)/
rawt=$(readlink -f ../raw_trimmed)/
# bt2=$(readlink -f ../bowtie2)/


if [[ -e ${tmp}extractor.ids ]]; then
rm ${tmp}extractor.ids
fi

bsm=$(readlink -f ../bismark)

cd ${rawt}
file=test.fastq_bismark_bt2.sam

echo "#!/bin/bash
cd ${bsm}
module load Bowtie2
module load Bismark
module load SAMtools
# bismark --bowtie2 -N 1 -o ${bsm} ${bsm} ${rawt}${file}
bismark_methylation_extractor --multicore 6 --bedGraph -s ${file}
rm ${tmp}extractor_${file::(-22)}.sh" > ${tmp}extractor_${file::(-22)}.sh

cd ${tmp}
chmod 755 ${tmp}extractor_${file::(-22)}.sh
rm ../slurm_logs/extractor_${file::(-22)}.*.out
sbatch -p blade,himem,hugemem --cpus-per-task=18 -o ../slurm_logs/extractor_${file::(-22)}.%j.out ${tmp}extractor_${file::(-22)}.sh 2>&1 | tee ${tmp}extractor_${file::(-22)}.id
id=$(cat ${tmp}extractor_${file::(-22)}.id | grep 'Submitted batch job')
echo -n :${id:20} >> ${tmp}extractor.ids
rm ${tmp}extractor_${file::(-22)}.id

# bismark_ids=$(cat ${tmp}bismark.ids)
# srun -p blade,himem,hugemem -d afterok${bismark_ids} echo "bismark done"
