# Control Robot

The `take_action` function in `_base_task` is used to control actions during task execution. It accepts two parameters: `action` and `action_type`.

## Supported Action Types

The parameter `action_type` supports two modes:

* `qpos` (Joint Position Control) — **default**
* `ee` (End-Effector Pose Control)

Depending on the selected mode, the format and dimension of the input `action` will differ.

---

### `qpos` Mode (Joint Position Control)

In `qpos` mode, the `action` is defined as:

```
[left_arm_joints + left_gripper + right_arm_joints + right_gripper]
```

* The specific dimension of the `action` depends on the robotic arm configuration.
* The system will **automatically adjust** the input dimensions during deployment to match the specific robot configuration.

---

### `ee` Mode (End-Effector Pose Control)

In `ee` mode, the `action` is defined as:

```
[left_end_effector_pose (xyz + quaternion) + left_gripper + right_end_effector_pose + right_gripper]
```

* The dimension is **fixed**, regardless of the robot configuration.

---

## Deployment Example

You can find a demonstration of usage in:

```
policy/Your_Policy/deploy_policy.py
```

This file provides a sample implementation to help you understand how to use the `take_action` function with different `action_type` settings during deployment.

