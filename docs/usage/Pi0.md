# OpenPI
## Environment Setup

We use [uv](https://docs.astral.sh/uv/) to manage Python dependencies,you can add uv your conda environment.

```bash
conda activate RoboTwin
#Install uv
pip install uv
```
Once uv is installed, run the following to set up the environment:

```bash
# Install prequisites in uv environment
GIT_LFS_SKIP_SMUDGE=1 uv sync
```

If you want to eval pi0 policy in RoboTwin，you are required to install curobo in your uv environment：

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
First, create the `processed_data` and `training_data` folders in the `policy/pi0` directory:

```
mkdir processed_data && mkdir training_data
```

Then, convert RoboTwin data to HDF5 data type.

``` bash
bash process_data_pi0.sh ${task_name} ${task_config} ${expert_data_num}
# bash process_data_pi0.sh beat_block_hammer demo_randomized 50
```

If success, you will find the `${task_name}-${task_config}-${expert_data_num}` folder under `policy/pi0/processed_data`.

Example folder structure:

```bash
processed_data/ 
├──${task_name}-${task_config}-${expert_data_num}
|       |   ├──episode_0
|       |   |	├── instructions.json  
|       |   |	├── episode_0.hdf5  
|       |   ├── episode_1 
|       |   |	├── instructions.json  
|       |   |	├── episode_1.hdf5  
|       |	├── ...
```

Copy all the data you wish to use for training from `processed_data` into `training_data/${model_name}`. If you have multiple tasks with different data, simply copy them in the same way.please Place the corresponding task folders according to the example below.

```bash
#multi-task dataset example
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

#sigle task example
training_data/  
├── demo_randomized
|       ├──beat_block_hammer-demo_randomized-50
|       |   ├──episode_0
|       |   |	├── instructions.json  
|       |   |	├── episode_0.hdf5  
|       |   ├── episode_1 
|       |   |	├── instructions.json  
|       |   |	├── episode_1.hdf5  
|       |	├── ...
```

Before generating the LerobotDataset format data for pi0,please make sure you have enough disk space under the `~/.cache`.This is because generating the `lerobotdataset` will require a large amount of space.And the datasets will be writed into `$XDG_CACHE_HOME`,which default path is  `~/.cache`.If you don't have enough disk space under the `~/.cache` path, please use the following command to set a different cache directory with sufficient space:

```bash
export XDG_CACHE_HOME=/path/to/your/cache
```

Now, we can directly generate the LerobotDataset format data for pi0

```bash
# hdf5_path: The path to the generated HDF5 data (e.g., ./training_data/${model_name}/)
# repo_id: The name of the dataset (e.g., my_repo)
bash generate.sh ${hdf5_path} ${repo_id}
#bash generate.sh ./training_data/demo_randomized/ demo_randomized_repo
```

LerobotDataset format data will be writed into `${XDG_CACHE_HOME}/huggingface/lerobot/${repo_id}`

## Write the Corresponding `train_config`

In `src/openpi/training/config.py`, there is a dictionary called `_CONFIGS`. You can modify 4 pre-configured PI0 configurations I’ve written:
`pi0_base_aloha_robotwin_lora` 
`pi0_fast_aloha_robotwin_lora`
`pi0_base_aloha_robotwin_full`
`pi0_fast_aloha_robotwin_full`

You only need to write `repo_id`  on your datasets.(e.g., `repo_id=demo_randomized_repo`)
If you want to change the `name` in `TrainConfig`, please include `fast` if you choose `pi_fast_base` model.
If your do not have enough gpu memory, you can set `fsdp_devices`, refer to `config.py` line `src/openpi/training/config.py` line 352.

## 5. Finetune model
```bash
# compute norm_stat for dataset
uv run scripts/compute_norm_stats.py --config-name ${train_config_name}
# uv run scripts/compute_norm_stats.py --config-name pi0_base_aloha_robotwin_full

# train_config_name: The name corresponding to the config in _CONFIGS, such as pi0_base_aloha_robotwin_full
# model_name: You can choose any name for your model
# gpu_use: if not using multi gpu,set to gpu_id like 0;else set like 0,1,2,3
bash finetune.sh ${train_config_name} ${model_name} ${gpu_use}
#bash finetune.sh pi0_base_aloha_robotwin_full demo_randomized 0,1,2,3
```

| Training mode | Memory Required | Example GPU        |
| ------------------ | --------------- | ------------------ |
| Fine-Tuning (LoRA) | > 46 GB       | A6000(48G)           |
| Fine-Tuning (Full) | > 100 GB         | 2*A100 (80GB) / 2*H100 |

If your GPU memory is insufficient, please set the `fsdp_devices` parameter according to the following GPU memory reference, or reduce the `batch_size` parameter.
Or you can try setting `XLA_PYTHON_CLIENT_PREALLOCATE=false` in `finetune.sh`, it will cost lower gpu memory, but make training speed slower.

The default `batch_size` is 32 in the table below.

| GPU memory | Model type | GPU num |fsdp_devices | Example GPU |
| ----- | ----- | ----- | ----- | ----- |
|  24G | lora | 2 | 2 | 4090(24G)  |
|  40G | lora | 2 | 2 | A100(40G)  |
|  48G | lora | 1 | 1 | A6000(48G) |
|  40G | full | 4 | 4 | A100(40G)  |
|  80G | full | 2 | 2 | A100(80G)  |

## Eval on RoboTwin

Checkpoints will be saved in policy/pi0/checkpoints/${train_config_name}/${model_name}/${checkpoint_id}

You can modify the `deploy_policy.yml` file to change the `checkpoint_id` you want to evaluate.

```bash
# ckpt_path like: policy/pi0/checkpoints/pi0_base_aloha_robotwin_full/demo_randomized/30000
bash eval.sh ${task_name} ${task_config} ${train_config_name} ${model_name} ${seed} ${gpu_id}
# bash eval.sh beat_block_hammer demo_randomized pi0_base_aloha_robotwin_full demo_randomized 0 0
# This command trains the policy using the `demo_randomized` setting ($model_name)
# and evaluates it using the same `demo_randomized` setting ($task_config).

# To evaluate a policy trained on the `demo_randomized` setting and tested on the `demo_clean` setting, run:
# bash eval.sh beat_block_hammer demo_clean pi0_base_aloha_robotwin_full demo_randomized 0 0
```
