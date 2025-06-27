# OpenPI
## Environment Setup

Follow the official OpenPI website to configure the environment. The OpenPI + RoboTwin environment has already been pre-configured in a file, so no additional setup is needed.

```bash
GIT_LFS_SKIP_SMUDGE=1 uv sync
```
install curobo：

```bash
conda deactivate
source .venv/bin/activate
# At this point, you should be in the (openpi) environment
cd ../../envs
git clone https://github.com/NVlabs/curobo.git
cd curobo
pip install -e . --no-build-isolation
cd ../../policy/pi0/
bash
```

## Generate RoboTwin Data
See [RoboTwin Tutorial (Usage Section)](https://robotwin-platform.github.io/doc/usage/collect-data.html) for more details.

## Generate openpi Data
First, convert RoboTwin data to HDF5 data type.
``` bash
bash process_data_pi0.sh ${task_name} ${task_config} ${expert_data_num}
# bash process_data_pi0.sh beat_block_hammer pi0_demo_randomized 50
```

If success, you will find the `${task_name}-${task_config}-${expert_data_num}` folder under `policy/pi0/processed_data`.

Example folder structure:

```
processed_data/ 
├──beat_block_hammer-pi0_demo_randomized-50
|       |   ├──episode_0
|       |   |	├── instructions.json  
|       |   |	├── episode_0.hdf5  
|       |   ├── episode_1 
|       |   |	├── instructions.json  
|       |   |	├── episode_1.hdf5  
|       |	├── ...
```

Copy all the data you wish to use for training from `processed_data` into `training_data/${model_name}`. If you have multiple tasks with different data, simply copy them in the same way.

After generating the HDF5 data, we can directly generate the LerobotDataset format data for pi0
If you want to create a multi-task dataset, please place the corresponding task folders according to the example below.

```
training_data/  
├── ${model_name}
|       ├──${task_0}
|       |   ├──episode_0
|       |   |	├── instructions.json  
|       |   |	├── episode_0.hdf5  
|       |   ├── episode_1 
|       |   |	├── instructions.json  
|       |   |	├── episode_1.hdf5  
|       |	├── ...
|       ├── ${task_1}
|       |   ├──episode_0
|       |   |	├── instructions.json  
|       |   |	├── episode_0.hdf5  
|       |   ├── episode_1 
|       |   |	├── instructions.json  
|       |   |	├── episode_1.hdf5  
|       |	├── ...

#example
training_data/  
├── pi0-beat_block_hammer
|       ├──beat_block_hammer-pi0_demo_randomized-50
|       |   ├──episode_0
|       |   |	├── instructions.json  
|       |   |	├── episode_0.hdf5  
|       |   ├── episode_1 
|       |   |	├── instructions.json  
|       |   |	├── episode_1.hdf5  
|       |	├── ...
```

```bash
# hdf5_path: The path to the generated HDF5 data (e.g., ./training_data/${model_name}/)
# repo_id: The name of the dataset (e.g., my_repo)
bash generate.sh ${hdf5_path} ${repo_id}
#bash generate.sh ./training_data/pi0-beat_block_hammer/ pi0-beat_block_hammer_repo
```

Generating the dataset can take some time—about half an hour for 100 sets, so feel free to take a break.

## note!
If you don't have enough disk space under the `~/.cache` path, please use the following command to set a different cache directory with sufficient space:
```bash
export XDG_CACHE_HOME=/path/to/your/cache
```

This is because generating the `lerobotdataset` will require a large amount of space.And the datasets will be writed into `$XDG_CACHE_HOME`.

## Write the Corresponding `train_config`
In `src/openpi/training/config.py`, there is a dictionary called `_CONFIGS`. You can modify two pre-configured PI0 configurations I’ve written:
`pi0_base_aloha_robotwin_lora` 
`pi0_fast_aloha_robotwin_lora`
`pi0_base_aloha_robotwin_full`
`pi0_fast_aloha_robotwin_full`

You only need to write `repo_id`  on your datasets.(e.g., repo_id=pi0-beat_block_hammer_repo)
If you want to change the `name` in `TrainConfig`, please include `fast` if you choose `pi_fast_base` model.
If your do not have enough gpu memory, you can set fsdp_devices, refer to config.py line `src/openpi/training/config.py` line 352.

## 5. Finetune model
Simply modify the `repo_id` to fine-tune the model:
```bash
# compute norm_stat for dataset
uv run scripts/compute_norm_stats.py --config-name ${train_config_name}
# uv run scripts/compute_norm_stats.py --config-name pi0_base_aloha_robotwin_full

# train_config_name: The name corresponding to the config in _CONFIGS, such as pi0_base_aloha_robotwin_full
# model_name: You can choose any name for your model
# gpu_use: if not using multi gpu,set to gpu_id like 0;else set like 0,1,2,3
bash finetune.sh ${train_config_name} ${model_name} ${gpu_use}
#bash finetune.sh pi0_base_aloha_robotwin_full pi0-beat_block_hammer 0,1,2,3
```

| Training mode | Memory Required | Example GPU        |
| ------------------ | --------------- | ------------------ |
| Fine-Tuning (LoRA) | > 46 GB       | A6000(48G)           |
| Fine-Tuning (Full) | > 100 GB         | 2*A100 (80GB) / 2*H100 |

If your GPU memory is insufficient, please set the `fsdp_devices` parameter according to the following GPU memory reference, or reduce the `batch_size` parameter.
Or you can try setting `XLA_PYTHON_CLIENT_PREALLOCATE=false` in `finetune.sh`, it will cost lower gpu memory, but make training speed slower.

The default `batch_size` is 32 in the table below.
| GPU memory | Model type | GPU num |fsdp_devices | Example GPU |
| ----- | ----- | ----- |-----| ----- |
|  24G | lora | 2 | 2 | 4090(24G)  |
|  40G | lora | 2 | 2 | A100(40G)  |
|  48G | lora | 1 | 1 | A6000(48G) |
|  40G | full | 4 | 4 | A100(40G)  |
|  80G | full | 2 | 2 | A100(80G)  |

## Eval on RoboTwin

```bash
# ckpt_path like: policy/pi0/checkpoints/pi0_base_aloha_robotwin_full/pi0-beat_block_hammer/30000
bash eval.sh ${task_name} ${task_config} ${train_config_name} ${model_name} ${seed} ${gpu_id}
#bash eval.sh beat_block_hammer pi0_demo_randomized pi0_base_aloha_robotwin_full pi0-beat_block_hammer 0 0
```
