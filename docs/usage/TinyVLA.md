# Tiny-VLA (Towards Fast, Data-Efficient Vision-Language-Action Models for Robotic Manipulation)

> Contributed by Midea Group

## Install
To guarantee clean isolation between training and evaluation environments for both DexVLA and TinyVLA, we provide two distinct, self-contained setups.The training and testing environment can be used for both DexVLA and TinyVLA.

Training Environment：
```bash
cd policy/TinyVLA
conda env create -f Train_Tiny_DexVLA_train.yml
conda activate dexvla-robo
cd policy_heads
pip install -e .
```
Evaluation Environment:

If you already have RoboTwin 2.0 installed, activate its conda environment and add the evaluation dependencies:
```bash
conda activate your_RoboTwin_env
pip install -r Eval_Tiny_DexVLA_requirements.txt 
```
## Prepare Training Data
This step performs data preprocessing, converting the original RoboTwin 2.0 data into the format required for TinyVLA training. The `expert_data_num` parameter specifies the number of trajectory pairs to be used as training data.
```bash
python process_data.py ${task_name} ${task_config} ${expert_data_num}
# python process_data.py beat_block_hammer demo_randomized 50
```
If success, you will find the `sim_${task_name}/${setting}_${expert_data_num}` folder under `policy/Tinyvla/data`.

## Train Policy
This step launches the training process.
First, download the VLM model InternVL3-1B ([huggingface](https://huggingface.co/OpenGVLab/InternVL3-1B/tree/main)) to the path `.../policy/TinyVLA/model_param/InternVL3-1B`. Then modify the `config.json` file in the folder as follows:
```
{
    "_name_or_path": ".../robotiwin/policy/TinyVLA/vla/models/internvl", # Modify this.
    "architectures": [
        "TinyVLA" # Change this.
    ],
    # "auto_map":{...} # Delete this.
    ...
    "llm_config": {}, # Don't Change.
    "min_dynamic_patch": 1,
    "model_type": "tinyvla", # Change this.
    ...
}
```
Then add an task config item in `.../policy/TinyVLA/aloha_scripts/constants.py`
```python
TASK_CONFIGS = {
    ...
    "your_task": {
        'dataset_dir': [DATA_DIR + "/sim-your_task/aloha-agilex-1-m1_b1_l1_h0.03_c0_D435-100"],
        'episode_len': 500,
        'camera_names': ['cam_high', 'cam_left_wrist', 'cam_right_wrist'],
        "sample_weights": [1, 1]
    }
}
```
Then begin the training
```bash
bash ./scripts/franks/train_robotwin_aloha.sh
```
Configure the training by modifying the following items in the `train_robotwin_aloha.sh` file.
```
TASK=your_task # Set the Task
ROOT=.../robotiwin/policy/TinyVLA # Set Root Path
mnop=.../robotiwin/policy/TinyVLA/model_param/InternVL3-1B/ # Set The Path of base VLM
```
## Eval Policy
You need to modify the corresponding path in the `deploy_policy.yml` file:
1. **model_path** : Path to the trained model, in the OUTPUT path.
2. **state_path** : Path to `dataset_stats.pkl`, in the OUTPUT path.
3. **model_base** : Path to InternVL3-1B.

Then execute:

```
bash eval.sh ${task_name} ${task_config} ${ckpt_setting} ${expert_data_num} ${seed} ${gpu_id}
# bash eval.sh beat_block_hammer demo_randomized 0 50 0 0
```

## Citation

If you find Tiny-VLA useful for your research and applications, please cite using this BibTeX:

```bibtex
@inproceedings{wen2024tinyvla,
    title={Tinyvla: Towards fast, data-efficient vision-language-action models for robotic manipulation},
    author={Wen, Junjie and Zhu, Yichen and Li, Jinming and Zhu, Minjie and Wu, Kun and Xu, Zhiyuan and Liu, Ning and Cheng, Ran and Shen, Chaomin and Peng, Yaxin and others},
    booktitle={IEEE Robotics and Automation Letters (RA-L)},
    year={2025}
}
```