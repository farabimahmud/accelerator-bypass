#!/bin/sh

outdir=$SIMHOME/results/mesh_logs

mkdir -p $outdir

mlperfdir=$SIMHOME/src/SCALE-Sim/topologies/mlperf
cnndir=$SIMHOME/src/SCALE-Sim/topologies/conv_nets


## for nnpath in $mlperfdir/AlphaGoZero $mlperfdir/FasterRCNN $mlperfdir/NCF_recommendation \
##   $mlperfdir/Resnet50 $mlperfdir/Transformer $mlperfdir/Transformer_short \
##   $cnndir/alexnet $cnndir/Googlenet
## do
## 

# ring
for nnpath in $mlperfdir/FasterRCNN $mlperfdir/NCF_recommendation \
  $mlperfdir/Resnet50 $mlperfdir/Transformer $mlperfdir/Transformer_short \
  $cnndir/alexnet $cnndir/Googlenet
do
  nn=$(basename $nnpath)
  allreduce=ring
  python $SIMHOME/src/simulate.py \
    --network $nnpath.csv \
    --run-name ${nn} \
    --booksim-network mesh \
    --booksim-config $SIMHOME/src/booksim2/runfiles/mesh44express.cfg \
    --allreduce $allreduce \
    --outdir $outdir \
    --kary 2 \
    --radix 1 \
    --message-buffer-size 32 \
    --message-size 256 \
    --sub-message-size 256 \
    > $outdir/${nn}_${allreduce}_error.log 2>&1 &
done

