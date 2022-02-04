#!/bin/sh

booksim_net=dgx2

outdir=$SIMHOME/results/${booksim_net}_logs
batch_dir=$SIMHOME/utils/topology_reference/${booksim_net}_batch/

rm -rf $outdir
mkdir -p $outdir

rm -rf $batch_dir
mkdir -p $batch_dir

# ring
for nodes in 16
do
    for datasize in 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536
    do
        for element_size in 4 #0.66 # 4/6
        do
            num_elements=$((($datasize*1024)/$element_size))

            echo "$element_size"
            jobname=${nodes}nodes_${datasize}kB_${element_size}elementsize_${booksim_net}_ring
            batchfile=$batch_dir/$jobname\_batch.sh

            echo "#!/bin/bash" >> $batchfile
            echo "#SBATCH --job-name=$jobname" >> $batchfile
            echo "#SBATCH --ntasks=1" >> $batchfile
            echo "#SBATCH --output=./$jobname.log" >> $batchfile

            echo "python3.6 $SIMHOME/src/simulate.py \\
            --num-hmcs ${nodes} \\
            --run-name ${nodes}nodes_${datasize}kB_${element_size}elementsize \\
            --booksim-config $SIMHOME/src/booksim2/runfiles/${booksim_net}.cfg \\
            --allreduce ring \\
            --outdir $outdir \\
            --kary 2 \\
            --radix 1 \\
            --booksim-network ${booksim_net} \\
            --bigraph-m 8 \\
            --bigraph-n 2 \\
            --message-buffer-size 32 \\
            --message-size 256 \\
            --sub-message-size 256 \\
            --only-allreduce \\
            --synthetic-data-size $num_elements \\
            > $outdir/${nodes}nodes_${datasize}kB_${element_size}elementsize_ring_error.log 2>&1 &" >> $batchfile

            echo "wait" >> $batchfile
        done
    done
done


## multitree-alpha
for nodes in 16 #36 64 100 144 196 256
do
    for datasize in 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536
    do
        for element_size in 4 6
        do
            num_elements=$((($datasize*1024)/$element_size))

            jobname=${nodes}nodes_${datasize}kB_${element_size}elementsize_${booksim_net}_multitree-alpha
            batchfile=$batch_dir/$jobname\_batch.sh

            echo "#!/bin/bash" >> $batchfile
            echo "#SBATCH --job-name=$jobname" >> $batchfile
            echo "#SBATCH --ntasks=1" >> $batchfile
            echo "#SBATCH --output=./$jobname.log" >> $batchfile

            echo "python3.6 $SIMHOME/src/simulate.py \\
            --num-hmcs ${nodes} \\
            --run-name ${nodes}nodes_${datasize}kB_${element_size}elementsize \\
            --booksim-config $SIMHOME/src/booksim2/runfiles/${booksim_net}.cfg \\
            --allreduce multitree \\
            --outdir $outdir \\
            --kary 2 \\
            --radix 1 \\
            --booksim-network ${booksim_net} \\
            --bigraph-m 8 \\
            --bigraph-n 2 \\
            --message-buffer-size 32 \\
            --message-size 256 \\
            --sub-message-size 256 \\
            --strict-schedule \\
            --prioritize-schedule \\
            --estimate-lockstep \\
            --only-allreduce \\
            --synthetic-data-size $num_elements \\
            > $outdir/${nodes}nodes_${datasize}kB_${element_size}elementsize_multitree_alpha_error.log 2>&1 &" >> $batchfile

            echo "wait" >> $batchfile
        done
    done
done

# multitree-gamma
for nodes in 16 #36 64 100 144 196 256
do
    for datasize in 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536
    do
        for element_size in 4 6
        do
            num_elements=$((($datasize*1024)/$element_size))

            jobname=${nodes}nodes_${datasize}kB_${element_size}elementsize_${booksim_net}_multitree-gamma
            batchfile=$batch_dir/$jobname\_batch.sh

            echo "#!/bin/bash" >> $batchfile
            echo "#SBATCH --job-name=$jobname" >> $batchfile
            echo "#SBATCH --ntasks=1" >> $batchfile
            echo "#SBATCH --output=./$jobname.log" >> $batchfile

            echo "python3.6 $SIMHOME/src/simulate.py \\
            --num-hmcs ${nodes} \\
            --run-name ${nodes}nodes_${datasize}kB_${element_size}elementsize \\
            --booksim-config $SIMHOME/src/booksim2/runfiles/${booksim_net}.cfg \\
            --allreduce multitree \\
            --outdir $outdir \\
            --kary 2 \\
            --radix 1 \\
            --booksim-network ${booksim_net} \\
            --bigraph-m 8 \\
            --bigraph-n 2 \\
            --message-buffer-size 32 \\
            --message-size 0 \\
            --sub-message-size 256 \\
            --strict-schedule \\
            --prioritize-schedule \\
            --estimate-lockstep \\
            --only-allreduce \\
            --synthetic-data-size $num_elements \\
            > $outdir/${nodes}nodes_${datasize}kB_${element_size}elementsize_multitree_gamma_error.log 2>&1 &" >> $batchfile

            echo "wait" >> $batchfile
        done
    done
done
