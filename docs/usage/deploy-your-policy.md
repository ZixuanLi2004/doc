# 🚀 Deploy Your Policy

To deploy and evaluate your policy, you need to **modify the following three files**:

* `eval.sh`: [eval.sh demo](https://github.com/RoboTwin-Platform/RoboTwin/blob/main/policy/Your_Policy/eval.sh)
* `deploy_policy.yml`: [deploy_policy.yml demo](https://github.com/RoboTwin-Platform/RoboTwin/blob/main/policy/Your_Policy/deploy_policy.yml)
* `deploy_policy.py`: [deploy_policy.py demo](https://github.com/RoboTwin-Platform/RoboTwin/blob/main/policy/Your_Policy/deploy_policy.py)

In `deploy_policy.py`, the following components are defined: `get_model` for loading the policy model, `encode_obs` for observation processing (modification may not be necessary), and `get_action` along with the control loop that handles observation acquisition and action execution.

The `deploy_policy.yml` file specifies the input parameters, which are eventually passed into the `get_model` function as `usr_args` to assist in locating, defining, and loading your model.

In `eval.sh`, the parameters specified after `overrides` can be used to overwrite those in `deploy_policy.yml`, allowing you to specify different settings without manually modifying the YAML file each time.

```
# policy/Your_Policy/deploy_policy.py
# import packages and module here


def encode_obs(observation):  # Post-Process Observation
    obs = observation
    # ...
    return obs


def get_model(usr_args):  # from deploy_policy.yml and eval.sh (overrides)
    Your_Model = None
    # ...
    return Your_Model  # return your policy model


def eval(TASK_ENV, model, observation):
    """
    All the function interfaces below are just examples
    You can modify them according to your implementation
    But we strongly recommend keeping the code logic unchanged
    """
    obs = encode_obs(observation)  # Post-Process Observation
    instruction = TASK_ENV.get_instruction()

    if len(
            model.obs_cache
    ) == 0:  # Force an update of the observation at the first frame to avoid an empty observation window, `obs_cache` here can be modified
        model.update_obs(obs)

    actions = model.get_action()  # Get Action according to observation chunk

    for action in actions:  # Execute each step of the action
        # see for https://robotwin-platform.github.io/doc/control-robot.md more details
        TASK_ENV.take_action(action, action_type='qpos') # joint control: [left_arm_joints + left_gripper + right_arm_joints + right_gripper]
        # TASK_ENV.take_action(action, action_type='ee') # endpose control: [left_end_effector_pose (xyz + quaternion) + left_gripper + right_end_effector_pose + right_gripper]
        # TASK_ENV.take_action(action, action_type='delta_ee') # delta endpose control: [left_end_effector_delta (xyz + quaternion) + left_gripper + right_end_effector_delta + right_gripper]
        observation = TASK_ENV.get_obs()
        obs = encode_obs(observation)
        model.update_obs(obs)  # Update Observation, `update_obs` here can be modified


def reset_model(model):  
    # Clean the model cache at the beginning of every evaluation episode, such as the observation window
    pass
```

---

## 🔧 `deploy_policy.yml`

You are free to **add any parameters** needed in `deploy_policy.yml` to specify your model setup (e.g., checkpoint path, model type, architecture details). The entire YAML content will be passed to `deploy_policy.py` as `usr_args`, which will be available in the `get_model()` function.

---

## 🖥️ `eval.sh`

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

## 🧠  `deploy_policy.py`

You need to implement the following methods in `deploy_policy.py`:

### `encode_obs(obs: dict) -> dict`

Optional. This function is used to preprocess the raw environment observation (e.g., color channel normalization, reshaping, etc.). If not needed, it can be left unchanged.

---

### `get_model(usr_args: dict) -> Any`

Required. This function receives the full configuration from `deploy_policy.yml` via `usr_args` and must return the initialized model. You can define your own loading logic here, including parsing checkpoints and network parameters.

---

### `eval(env, model, observation, instruction) -> Any`

Required. The main evaluation loop. Given the current environment instance, model, and observation (as a dictionary), and a natural language `instruction` (string), this function must compute the next action and execute it in the environment.

---

### `update_obs(obs: dict) -> None`

Optional. Used to update any internal state of the model or observation buffer. Useful if your model requires a history of frames or a memory-based context.

---

### `get_action(model, obs: dict) -> Any`

Optional. Given a model and current observation, return the action to be executed. This is useful if action computation is separated from the evaluation loop.

---

### `reset_model() -> None`

Optional but **recommended**. This function is called before the evaluation of **each episode**, allowing you to reset model states such as recurrent memory, history buffers, or context encodings.

---

## ✔️ Run `eval.sh`

```
bash eval.sh ...(input parameters you define)
```

## 📌 Notes

* The variable `instruction` is a string containing the language command describing the task. You can choose how (or whether) to use it.
* Your policy should be compatible with the input/output format expected by the simulator.
