# 🚀 Deploy Your Policy

To deploy and evaluate your policy, you need to **modify the following three files**:

* `eval.sh`
* `deploy_policy.yml`
* `deploy_policy.py`

---

## 🔧 1. `deploy_policy.yml`

You are free to **add any parameters** needed in `deploy_policy.yml` to specify your model setup (e.g., checkpoint path, model type, architecture details). The entire YAML content will be passed to `deploy_policy.py` as `usr_args`, which will be available in the `get_model()` function.

---

## 🖥️ 2. `eval.sh`

Update the script to pass additional arguments to override default values in `deploy_policy.yml`.

```bash
#!/bin/bash

policy_name=Your_Policy
task_name=${1}
task_config=${2}
ckpt_setting=${3}
seed=${4}
gpu_id=${5}
# [TODO] Add your custom command-line arguments here

export CUDA_VISIBLE_DEVICES=${gpu_id}
echo -e "\033[33mgpu id (to use): ${gpu_id}\033[0m"

cd ../.. # move to project root

python script/eval_policy.py --config policy/$policy_name/deploy_policy.yml \
    --overrides \
    --task_name ${task_name} \
    --task_config ${task_config} \
    --ckpt_setting ${ckpt_setting} \
    --seed ${seed} \
    --policy_name ${policy_name} 
    # [TODO] Add your custom arguments here
```

---

## 🧠 3. `deploy_policy.py`

You need to implement the following methods in `deploy_policy.py`:

### 1. `encode_obs(obs: dict) -> dict`

Optional. This function is used to preprocess the raw environment observation (e.g., color channel normalization, reshaping, etc.). If not needed, it can be left unchanged.

---

### 2. `get_model(usr_args: dict) -> Any`

Required. This function receives the full configuration from `deploy_policy.yml` via `usr_args` and must return the initialized model. You can define your own loading logic here, including parsing checkpoints and network parameters.

---

### 3. `eval(env, model, observation, instruction) -> Any`

Required. The main evaluation loop. Given the current environment instance, model, and observation (as a dictionary), and a natural language `instruction` (string), this function must compute the next action and execute it in the environment.

---

### 4. `update_obs(obs: dict) -> None`

Optional. Used to update any internal state of the model or observation buffer. Useful if your model requires a history of frames or a memory-based context.

---

### 5. `get_action(model, obs: dict) -> Any`

Optional. Given a model and current observation, return the action to be executed. This is useful if action computation is separated from the evaluation loop.

---

### 6. `reset_model() -> None`

Optional but **recommended**. This function is called before the evaluation of **each episode**, allowing you to reset model states such as recurrent memory, history buffers, or context encodings.

---

## 📌 Notes

* The variable `instruction` is a string containing the language command describing the task. You can choose how (or whether) to use it.
* Your policy should be compatible with the input/output format expected by the simulator.
