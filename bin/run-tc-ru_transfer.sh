#!/bin/sh

set -xe

ru_dir="./data/ru"
ru_csv="${ru_dir}/ru.csv"

epoch_count=$1

if [ ! -f "${ru_dir}/ru.csv" ]; then
    echo "Downloading and preprocessing Russian example data, saving in ${ru_dir}."
    python -u bin/import_ru.py ${ru_dir}
fi;

# Force only one visible device because we have a single-sample dataset
# and when trying to run on multiple devices (like GPUs), this will break
export CUDA_VISIBLE_DEVICES=0

# python -u DeepSpeech.py --noshow_progressbar --noearly_stop \
#   --fine_tune True \
#   --alphabet "${ru_dir}/alphabet.ru" \
#   --load 'transfer' --drop_source_layers 1 \
#   --source_model_checkpoint_dir '/tmp/ckpt' \ # /tmp/ckpt was generated by bin/ldc_new.sh
#   --checkpoint_dir '/tmp/ckpt/transfer' \
#   --n_hidden 100 --epochs ${epoch_count} --dropout_rate 0.05 \
#   --train_files ${ru_csv} --train_batch_size 1 \
#   --dev_files ${ru_csv} --dev_batch_size 1 \
#   --test_files ${ru_csv} --test_batch_size 1 | tee /tmp/transfer.log


python -u DeepSpeech.py --noshow_progressbar --noearly_stop \
       --fine_tune\
       --alphabet_config_path "${ru_dir}/alphabet.ru" \
       --load "transfer" --drop_source_layers 2 \
       --train_files  "${ru_dir}/ru.csv" --train_batch_size 1  \
       --dev_files  "${ru_dir}/ru.csv" --dev_batch_size 1 \
       --test_files  "${ru_dir}/ru.csv" --test_batch_size 1 \
       --checkpoint_dir '/tmp/ckpt/transfer' --epochs 5 \
       --source_model_checkpoint_dir "/home/josh/Downloads/deepspeech-0.6.1-checkpoint/"
