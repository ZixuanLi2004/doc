# DP3 (3D Diffusion Policy)

> Since **DP3** is a 3D policy that requires point cloud input, please make sure to set `data_type/pointcloud` to `true` during data collection.


## Install
```
cd policy/DP3/3D-Diffusion-Policy && pip install -e . && cd ..
pip install zarr==2.12.0 wandb ipdb gpustat dm_control omegaconf hydra-core==1.2.0 dill==0.3.5.1 einops==0.4.1 diffusers==0.11.1 numba==0.56.4 moviepy imageio av matplotlib termcolor
```

## Prepare Training Data

This step performs data preprocessing, converting the original **RoboTwin 2.0** data into the **Zarr format** required for DP3 training.
The `expert_data_num` parameter specifies the number of trajectory pairs to be used as training data.

```
bash process_data.sh ${task_name} ${task_config} ${expert_data_num}
# bash process_data.sh beat_block_hammer demo_randomized 50
```

## Train Policy

This step launches the training process.
By default, the model is trained for **3,000 steps**.

```
bash train.sh ${task_name} ${task_config} ${expert_data_num} ${seed} ${gpu_id}
# bash train.sh beat_block_hammer demo_randomized 50 0 0
```

## Eval Policy

The `task_config` field refers to the **evaluation environment configuration**, while the `ckpt_setting` field refers to the **training data configuration** used during policy learning.

```
bash eval.sh ${task_name} ${task_config} ${ckpt_setting} ${expert_data_num} ${seed} ${gpu_id}
# bash eval.sh beat_block_hammer demo_randomized demo_randomized 50 0 0
# This command trains the policy using the `demo_randomized` setting ($ckpt_setting)
# and evaluates it using the same `demo_randomized` setting ($task_config).
#
# To evaluate a policy trained on the `demo_randomized` setting and tested on the `demo_clean` setting, run:
# bash eval.sh beat_block_hammer demo_clean demo_randomized 50 0 0
```

The evaluation results, including videos, will be saved in the `eval_result` directory under the project root.
