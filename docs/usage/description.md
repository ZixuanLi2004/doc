# Description Gen (Object & Task)

## Object Description

```bash
# Generate object description for all objects
python3 utils/generate_object_description.py

# Generate object description for a specific type of object with as many objects as this class contains
python3 utils/generate_object_description.py 001_bottle

# Generate object description for a specific object index of a specific type of object
python3 utils/generate_object_description.py 001_bottle --index 0
```

## Task Instruction

```bash
# Generate 60 task descriptions for a task
python3 utils/generate_task_description.py place_shoe 60
```

It will call for `instruction_num % 12` times of API, each time returning 12 instructions shuffled into 10 seen and 2 unseen instructions.

## Episode Instruction

```bash
# Generate 60 task descriptions for a task
python3 utils/generate_episode_instructions.py place_shoe franka-panda-D435 1000
```

### Parameters:
- `task_name`: Name of the task (JSON file name without extension)
- `setting`: Setting name used to construct the data directory path
- `max_num`: Maximum number of descriptions per episode
    