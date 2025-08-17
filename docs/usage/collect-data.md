# Collect Data

We provide over 100,000 pre-collected trajectories as part of the open-source release [RoboTwin Dataset](https://huggingface.co/datasets/TianxingChen/RoboTwin2.0/tree/main/dataset).
However, we strongly recommend users to perform data collection themselves due to the high configurability and diversity of task and embodiment setups.

Running the following command will first search for a random seed for the target collection quantity, and then replay the seed to collect data.

```
bash collect_data.sh ${task_name} ${task_config} ${gpu_id}
# Example: bash collect_data.sh beat_block_hammer demo_randomized 0
```

After data collection is completed, the collected data will be stored under `data/${task_name}/${task_config}`.

**An episode's data will be stored in one HDF5 file. Specifically, the images will be stored as bit streams. If you want to recover the image, you can use the following code:**

```
image = cv2.imdecode(np.frombuffer(image_bit, np.uint8), cv2.IMREAD_COLOR)
```

* Each trajectory's observation and action data are saved in **HDF5 format** in the `data` directory.
* The corresponding **language instructions** for each trajectory are stored in the `instructions` directory.
* **Head camera videos** of each trajectory can be found in the `video` directory.
* The `_traj_data`, `.cache`, `scene_info.json`, and `seed.txt` files are auxiliary outputs generated during the data collection process.


All available `task_name` options can be found in the [documentation](https://robotwin-platform.github.io/doc/tasks/index.html).
The `gpu_id` parameter specifies which GPU to use and should be set to an integer in the range `0` to `N-1`, where `N` is the number of GPUs available on your system.

Our data synthesizer enables automated data collection by executing the task scripts in the `envs` directory, in combination with the `curobo` robot planner. Specifically, data collection is configured through a task-specific configuration file (see the tutorial in `./configurations.md`), which defines parameters such as the target embodiment, domain randomization settings, and the number of data samples to collect.

The success rate of data generation for each embodiment across all tasks can be found at: [https://robotwin-platform.github.io/doc/tasks/index.html](https://robotwin-platform.github.io/doc/tasks/index.html). Due to the structural limitations of different robotic arms, not all embodiments are capable of completing every task.

Our pipeline first explores a set of random seeds (`seed.txt`) to identify trajectories that can yield successful data collection. It then records fine-grained action trajectories (`_traj_data`) accordingly. Collected videos are available in the `videos` directory.

The entire process is fully automated—just run a single command to get started.

> ⚠️ The `missing pytorch3d` warning can be ignored if 3D data is not required.

