# API for Controlling Mechanical Arms

The API can be used to control one or two robotic arms to perform operations such as grasping, placing, moving, and returning to the origin. Each arm is identified by an `ArmTag`, which can be `"left"` or `"right"`. Actions are generated in sequences and executed together via the `move()` method.

---

## Class Structure

- **`self`**: The task class inherit from `Base_Task`.
- **`ArmTag`**: A custom type representing a robotic arm. It supports comparison with strings: `ArmTag("left") == "left"` returns `True`. You can obtain the opposite arm using `ArmTag("left").opposite`, i.e., `ArmTag("left").opposite == "right"` returns `True`.
- **`Actor`**/**`ArticulationActor`**: The object being manipulated. Provides methods to retrieve key points (contact point `contact_point`, functional point `functional_point`, target point `target_point`) and its current global pose.
- **`Action`**: A sequence of actions for controlling the arm. You only need to know that it can be executed via the `move()` function.

---

## Controlling APIs

### `move(self, actions_by_arm1: tuple[ArmTag, list[Action]], actions_by_arm2: tuple[ArmTag, list[Action]] = None)`

#### Description
Executes action sequences on one or both robotic arms simultaneously.

#### Parameters
- `actions_by_arm1`: Action sequence for the first arm, formatted as `(arm_tag, [action1, action2, ...])`
- `actions_by_arm2`: Optional, action sequence for the second arm

#### Notes
- The same `ArmTag` cannot be passed twice.
- All actions must have been pre-generated.

#### Example
One arm grasps a bottle, the other moves back to avoid interference.
```python
self.move(
    self.grasp_actor(self.bottle, arm_tag=arm_tag),
    self.back_to_origin(arm_tag=arm_tag.opposite)
)
```

---

### `grasp_actor(self, actor: Actor, arm_tag: ArmTag, pre_grasp_dis=0.1, grasp_dis=0, gripper_pos=0., contact_point_id=None) -> tuple[ArmTag, list[Action]]`

#### Description
Generates a sequence of actions to pick up the specified `Actor`.

#### Parameters
- `actor`: The object to grasp
- `arm_tag`: Which arm to use
- `pre_grasp_dis`: Pre-grasp distance (default 0.1 meters), the arm will move to this position first
- `grasp_dis`: Grasping distance (default 0 meters), the arm moves from the pre-grasp position to this position and then closes the gripper
- `gripper_pos`: Gripper closing position (default 0, fully closed)
- `contact_point_id`: Optional list of contact point IDs; if not provided, the best grasping point is selected automatically

#### Returns
`(arm_tag, action_list)` containing the grasp actions.

#### Example
Select appropriate grasp point based on arm_tag and grasp the cup.
```python
self.move(
    self.grasp_actor(
        self.cup, arm_tag=arm_tag,
        pre_grasp_dis=0.1,
        contact_point_id=[0, 2][int(arm_tag=='left')]
    )
)
```

---

### `place_actor(self, actor: Actor, arm_tag: ArmTag, target_pose: list | np.ndarray, functional_point_id: int = None, pre_dis=0.1, dis=0.02, is_open=True, **kwargs) -> tuple[ArmTag, list[Action]]`

#### Description
Places a currently held object at a specified target pose.

#### Parameters
- `actor`: The currently held object
- `arm_tag`: The arm holding the object
- `target_pose`: Target position/orientation, length 3 or 7 (xyz + optional quaternion)
- `functional_point_id`: Optional ID of the functional point; if provided, aligns this point to the target, otherwise aligns the base of the object
- `pre_dis`: Pre-place distance (default 0.1 meters), arm moves to this position first
- `dis`: Final placement distance (default 0.02 meters), arm moves from pre-place to this location, then opens the gripper
- `is_open`: Whether to open the gripper after placing (default True)
- `**kwargs`: Other optional parameters:
    - `constrain : {'free', 'align', 'auto'}, default='auto'` Alignment strategy:
        - `free`: Only forces the object's z-axis to align with the target point's z-axis, other axes are determined by projection.
        - `align`: Forces all axes of the object to align with all axes of the target point.
        - `auto`: Automatically selects a suitable placement pose based on grasp direction (vertical or horizontal).
    - `align_axis : list of np.ndarray or np.ndarray or list, optional` Vectors or vector list in world coordinates to align with. For example, `[1, 0, 0]` or `[[1, 0, 0], [0, 1, 0]]`. If multiple vectors are provided, the one with the smallest dot product with the current actor axis will be chosen for alignment.
    - `actor_axis : np.ndarray or list, default=[1, 0, 0]` The second object axis used for alignment (the first is the z-axis which will be forced to align). Typically used for auxiliary alignment (especially when `constrain == 'align'`).
    - `actor_axis_type : {'actor', 'world'}, default='actor'` Specifies whether `actor_axis` is relative to the object coordinate system or world coordinate system.
    - `pre_dis_axis : {'grasp', 'fp'} or np.ndarray or list, default='grasp'` Specifies the pre-placement offset direction:
        - `grasp`: Offset along the grasp direction (i.e., opposite to the end-effector pointing towards the object center).
        - `fp`: Offset along the target point's z-axis direction.
        - Custom vectors can also be provided to represent the offset direction.
#### Returns
`(arm_tag, action_list)` containing the place actions.

#### Example
When stacking one object on top of another (for example, placing blockA on top of blockB).
```python
target_pose = self.last_actor.get_functional_point(point_id, "pose")
# Use this target_pose in place_actor to place the object exactly on top of last_actor at the specified functional point.
self.move(
    self.place_actor(
        actor=self.current_actor, # The object to be placed
        target_pose=target_pose, # The pose acquired from last_actor
        arm_tag=arm_tag,
        functional_point_id=0, # Align functional point 0, or specify as needed
        pre_dis=0.1,
        dis=0.02,
	    pre_dis_axis="fp", # Use functional point direction for pre-displacement, if the functional point is used
    )
)
```

Place the actor at actor_pose (already a Pose object).
```python
self.move(
    self.place_actor(
        self.box,
        target_pose=self.actor_pose, # already a Pose, no need for get_pose()
        arm_tag=grasp_arm_tag,
        functional_point_id=0, # functional_point_id can be retrived from the actor list if the actor has functional points
        pre_dis=0,
        dis=0,  # set dis to 0 if is_open is False, and the gripper will not open after placing. Set the `dis` to a small value like 0.02 if you want the gripper to open after placing.
        is_open=False, # if is_open is False, pre_dis and dis will be 0, and the gripper will not open after placing.
        constrain="free", # if task requires the object to be placed in a specific pose that mentioned in the task description (like "the head of the actor should be toward xxx), you can set constrain to "align", in all of other cases, you should set constrain to "free".
        pre_dis_axis='fp', # Use functional point direction for pre-displacement, if the functional_point_id is used
    )
)
```
---

### `move_by_displacement(self, arm_tag: ArmTag, x=0., y=0., z=0., quat=None, move_axis='world') -> tuple[ArmTag, list[Action]]`

#### Description
Moves the end-effector of the specified arm along relative directions and sets its orientation.

#### Parameters
- `arm_tag`: The arm to control
- `x`, `y`, `z`: Displacement along each axis (in meters)
- `quat`: Optional quaternion specifying the target orientation; if not set, uses current orientation
- `move_axis`: `'world'` means displacement is in world coordinates, `'arm'` means displacement is in local coordinates

#### Returns
`(arm_tag, action_list)` containing the move-by-displacement actions.

#### Example
Lift the object up by moving relative to current position, you should lift the arm up evrery time after grasping an object to avoid collision.
```python
self.move(
    self.move_by_displacement(
        arm_tag=arm_tag,
        z=0.07,  # Move 7cm upward
        move_axis='world'
    )
)
```

---

### `move_to_pose(self, arm_tag: ArmTag, target_pose: list) -> tuple[ArmTag, list[Action]]`

#### Description
Moves the end-effector of the specified arm to a specific absolute pose.

#### Parameters
- `arm_tag`: The arm to control
- `target_pose`: Absolute position and/or orientation, length 3 or 7 (xyz + optional quaternion)

#### Returns
`(arm_tag, action_list)` containing the move-to-pose actions.

#### Example
Move the arm to a specific pose, for example, to place an object in a certain position decided by which arm is placing the object.
```python
target_pose = self.get_arm_pose(arm_tag=arm_tag)
if arm_tag == 'left':
    # Set specific position and orientation for left arm
    target_pose[:2] = [-0.1, -0.05]
    target_pose[2] -= 0.05
    target_pose[3:] = [-0.707, 0, -0.707, 0]
else:
    # Set specific position and orientation for right arm
    target_pose[:2] = [0.1, -0.05]
    target_pose[2] -= 0.05
    target_pose[3:] = [0, 0.707, 0, -0.707]

# Move the skillet to the defined target pose
self.move(
    self.move_to_pose(arm_tag=arm_tag, target_pose=target_pose)
)
```

---

### `close_gripper(self, arm_tag: ArmTag, pos=0.) -> tuple[ArmTag, list[Action]]`

#### Description
Closes the gripper of the specified arm.

#### Parameters
- `arm_tag`: Which arm's gripper to close
- `pos`: Gripper position (0 = fully closed)

#### Returns
`(arm_tag, action_list)` containing the gripper-close action.

#### Example
```python
self.move(
    self.close_gripper(arm_tag=arm_tag)
)
```

---

### `open_gripper(self, arm_tag: ArmTag, pos=1.) -> tuple[ArmTag, list[Action]]`

#### Description
Opens the gripper of the specified arm.

#### Parameters
- `arm_tag`: Which arm's gripper to open
- `pos`: Gripper position (1 = fully open)

#### Returns
`(arm_tag, action_list)` containing the gripper-open action.

#### Example
```python
self.move(
    self.open_gripper(arm_tag=arm_tag)
)
```

---

### `back_to_origin(self, arm_tag: ArmTag) -> tuple[ArmTag, list[Action]]`

#### Description
Returns the specified arm to its predefined initial position.

#### Parameters
- `arm_tag`: The arm to return to origin

#### Returns
`(arm_tag, action_list)` containing the return-to-origin action.

#### Example
Place left object while moving right arm back to origin.
```python
move_arm_tag = ArmTag("left")  # Specify which arm is placing the object
back_arm_tag = ArmTag("right")  # Specify which arm is moving back to origin
self.move(
    self.place_actor(
        actor=self.left_actor,
        arm_tag=move_arm_tag,
        target_pose=target_pose,
        pre_dis_axis="fp",
    ),
    self.back_to_origin(arm_tag=back_arm_tag)
)
```

---

### `get_arm_pose(self, arm_tag: ArmTag) -> list[float]`

#### Description
Gets the current pose of the end-effector of the specified arm.

#### Parameters
- `arm_tag`: Which arm to query

#### Returns
A list of 7 floats: `[x, y, z, qw, qx, qy, qz]`, representing position and orientation.

#### Example
```python
pose = self.get_arm_pose(ArmTag("left"))
```

---

## `Actor` Class APIs

`Actor` is the object being manipulated by the robotic arms. It provides methods to retrieve key points and its current global pose. The `Actor` class has the following data points:

- Target Point `target_point`: Special points available during planning (e.g., handle of a cup)
- Contact Point `contact_point`: Position where the robotic arm grasps the object (e.g., rim of a cup)
- Functional Point `functional_point`: Position where the object interacts with other objects (e.g., head of a hammer)
- Orientation Point `orientation_point`: Specifies the orientation of the object (e.g., toe of a shoe pointing left)

These methods can be called on `Actor` objects:

### `get_contact_point(self, idx: int) -> list[float]`
Returns the pose of the `idx`-th contact point as `[x, y, z, qw, qx, qy, qz]`

### `get_functional_point(self, idx: int) -> list[float]`
Returns the pose of the `idx`-th functional point as `[x, y, z, qw, qx, qy, qz]`

### `get_target_point(self, idx: int) -> list[float]`
Returns the pose of the `idx`-th target point as `[x, y, z, qw, qx, qy, qz]`

### `get_orientation_point(self, idx: int) -> list[float]`
Returns the pose of the `idx`-th orientation point as `[x, y, z, qw, qx, qy, qz]`

### `get_pose(self) -> sapien.Pose`
Returns the global pose of the object in SAPIEN (`.p` is position, `.q` is orientation)

## `ArticulationActor` Class APIs

If the actor was created with method that contains "urdf"(e.g. `create_rand_sapien_urdf_actor`), it will be a subclass of `Actor` called `ArticulationActor`, with the following additional methods:

### `get_qlimits(self) -> list[tuple[float, float]]`
Returns a list of joint limits, where each joint limit is a tuple `(min, max)`.

### `get_qpos(self) -> list[float]`
Returns the current positions (rotational/positional) of all joints.

### `get_qvel(self) -> list[float]`
Returns the current velocities of all joints.