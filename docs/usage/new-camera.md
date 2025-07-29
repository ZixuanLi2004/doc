# Configurating New Camera

Modify `task_config/_camera_config.yml` ([Github file](https://github.com/RoboTwin-Platform/RoboTwin/blob/main/task_config/_camera_config.yml)), adding new camera new and configurate `fov`, `h` and `w`, such as:

```
Demo_Camera:
  fovy: 56
  w: 224
  h: 224
```

Finally, modify the camera type in the task config file.

```
camera:
  head_camera_type: Demo_Camera
  wrist_camera_type: D435
```