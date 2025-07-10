# RDT
## Environment Setup
The conda environment for RDT with RoboTwin is identical to the official RDT environment. Please follow the ([RDT official documentation](https://github.com/thu-ml/RoboticsDiffusionTransformer)) to install the environment and directly overwrite the RoboTwin virtual environment in [INSTALLATION.md](../../INSTALLATION.md).

```bash
# Make sure python version == 3.10
conda activate RoboTwin

# Install pytorch
# Look up https://pytorch.org/get-started/previous-versions/ with your cuda version for a correct command
pip install torch==2.1.0 torchvision==0.16.0  --index-url https://download.pytorch.org/whl/cu121

# Install packaging
pip install packaging==24.0
pip install ninja
# Verify Ninja --> should return exit code "0"
ninja --version; echo $?
# Install flash-attn
pip install flash-attn==2.7.2.post1 --no-build-isolation

# Install other prequisites
pip install -r requirements.txt
# If you are using a PyPI mirror, you may encounter issues when downloading tfds-nightly and tensorflow. 
# Please use the official source to download these packages.
# pip install tfds-nightly==4.9.4.dev202402070044 -i  https://pypi.org/simple
# pip install tensorflow==2.15.0.post1 -i  https://pypi.org/simple
```
## Download Model

```bash
# In the RoboTwin/policy directory
mkdir RDT && cd RDT
# Download the models used by RDT
huggingface-cli download google/t5-v1_1-xxl --local-dir t5-v1_1-xxl
huggingface-cli download google/siglip-so400m-patch14-384 --local-dir siglip-so400m-patch14-384
huggingface-cli download robotics-diffusion-transformer/rdt-1b --local-dir rdt-1b
```

## Collect RoboTwin Data

See [RoboTwin Tutorial (Usage Section)](https://robotwin-platform.github.io/doc/usage/collect-data.html) for more details.

## Generate HDF5 Data
> HDF5 is the data format required for RDT training.

First, create the `processed_data` and `training_data` folders in the `policy/RDT` directory:
```bash
mkdir processed_data && mkdir training_data
```

Then, run the following in the `RDT/` root directory:

```bash
bash process_data_rdt.sh ${task_name} ${task_config} ${expert_data_num} ${gpu_id}
```

If success, you will find the `${task_name}-${task_config}-${expert_data_num}` folder under `policy/RDT/processed_data`.

## Generate Configuration File
A `$model_name` manages the training of a model, including the training data and training configuration.
```bash
cd policy/RDT
bash generate.sh ${model_name}
# bash generate.sh RDT_demo_randomized
```

This will create a folder named `\${model_name}` under training_data and a configuration file `\${model_name}.yml` under model_config.

### Prepare Data
Copy all the data you wish to use for training from `processed_data` into `training_data/${model_name}`. If you have multiple tasks with different data, simply copy them in the same way.

Example folder structure:
```
training_data/${model_name}
├── ${task_1}
│   ├── episode_0
|   |   |── episode_0.hdf5
|   |   |-- instructions
|   │   │   ├── lang_embed_0.pt
|   │   │   ├── ...
├── ${task_2}
│   ├── ...
├── ...
```

### Modify Training Config
In `model_config/${model_name}.yml`, you need to manually set the GPU to be used (modify `cuda_visible_device`). For a single GPU, try format like `0` to set GPU 0. For multi-GPU usage, try format like `0,1,4`. You can flexibly modify other parameters.

## Finetune model

Once the training parameters are set, you can start training with:
```bash
bash finetune.sh ${model_name}
# bash finetune.sh RDT_demo_randomized
```
**Note!**

If you fine-tune the model using a single GPU, DeepSpeed will not save `pytorch_model/mp_rank_00_model_states.pt`. If you wish to continue training based on the results of a single-GPU trained model, please set `pretrained_model_name_or_path` to something like `./checkpoints/${model_name}/checkpoint-${ckpt_id}`. 

This will use the pretrain pipeline to import the model, which is the same import structure as the default `../weights/RDT/rdt-1b`.

## Eval on RoboTwin
The `task_config` field refers to the **evaluation environment configuration**, while the `model_name` field refers to the **training data configuration** used during policy learning.

```bash
bash eval.sh ${task_name} ${task_config} ${model_name} ${checkpoint_id} ${seed} ${gpu_id}
# bash eval.sh beat_block_hammer demo_randomized RDT_demo_randomized 10000 0 0
# This command trains the policy using the `RDT_demo_randomized` setting ($model_name)
# and evaluates it using the same `demo_randomized` setting ($task_config).
#
# To evaluate a policy trained on the `demo_randomized` setting and tested on the `demo_clean` setting, run:
# bash eval.sh beat_block_hammer demo_clean RDT_demo_randomized 10000 0 0
```

The evaluation results, including videos, will be saved in the `eval_result` directory under the project root.