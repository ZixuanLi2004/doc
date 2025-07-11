# Common Issue

## Modify `clear_cache_freq` to Reduce GPU Memory Pressure

If you find that your GPU memory is insufficient—especially if the program consistently runs out of memory after several episodes (during data collection or evaluation)—try adjusting the `clear_cache_freq` parameter in the corresponding task configuration.
Note that setting a smaller `clear_cache_freq` value can reduce GPU memory usage but may also slow down runtime performance (For more details, see [Configurations](https://
robotwin-platform.github.io/doc/usage/configurations.html)).

## `[svulkan2] [error] OIDN Error: invalid handle`
Try: [[SAPIEN issue: https://github.com/haosulab/SAPIEN/issues/243](https://github.com/haosulab/SAPIEN/issues/243)]

## Stuck While Collecting Data and Evaluating
Please check your GPU model. According to user feedback and known issues reported on SAPIEN [[SAPIEN issue: https://github.com/haosulab/SAPIEN/issues/219](https://github.com/haosulab/SAPIEN/issues/219)], Hopper/Ampere series GPUs (e.g., A100, H100) may occasionally experience unexpected hangs during data collection. You may try skipping the affected seed as a workaround (remove the specific seed in the `data/${task_name}/${task_config}/seed.txt`).

## Join the RoboTwin Community

Consider joining the [WeChat Community](https://robotwin-platform.github.io/doc/community/index.html) to stay connected and receive updates.

