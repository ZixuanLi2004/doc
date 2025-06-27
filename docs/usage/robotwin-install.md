# Install & Download
## **Dependencies**

Python versions:

* Python 3.10

Operating systems:

* Linux: Ubuntu 18.04+, Centos 7+

CUDA version:

* 12.1 (Recommended)

Hardware:

* Rendering: NVIDIA or AMD GPU

* Ray tracing: NVIDIA RTX GPU or AMD equivalent

* Ray-tracing Denoising: NVIDIA GPU

* GPU Simulation: NVIDIA GPU

Software:

* Ray tracing: NVIDIA Driver >= 470
* Denoising (OIDN): NVIDIA Driver >= 520

## Install Vulkan (if not installed)
Check `vulkaninfo`
```
sudo apt install libvulkan1 mesa-vulkan-drivers vulkan-tools
```

## Basic Env
First, prepare a conda environment.
```bash
conda create -n RoboTwin python=3.10 -y
conda activate RoboTwin
```

RoboTwin 2.0 Code Repo: [https://github.com/RoboTwin-Platform/RoboTwin](https://github.com/RoboTwin-Platform/RoboTwin)

```bash
git clone https://github.com/RoboTwin-Platform/RoboTwin.git
```

Then, run `script/_install.sh` to install basic envs and CuRobo:
```
bash script/_install.sh
```

If you meet curobo config path issue, try to run `python script/update_embodiment_config_path.py`

If you encounter any problems, please refer to the [manual installation](#manual-installation-only-when-step-2-failed) section. If you are not using 3D data, a failed installation of pytorch3d will not affect the functionality of the project.


## Download Assert (RoboTwin-OD, Texture Library and Embodiments)
To download the assets, run the following command. If you encounter any rate-limit issues, please log in to your Hugging Face account by running `huggingface-cli login`:
```
bash script/_download_assets.sh
```

The structure of the `assets` folder should be like this:

```text
assets
├── background_texture
├── embodiments
│   ├── embodiment_1
│   │   ├── config.yml
│   │   └── ...
│   └── ...
├── objects
└── ...
```

## Manual Installation (Only when step 2 failed)
1. Install requirements
```bash
pip install -r requirements.txt
```

2. Install pytorch3d
```bash
pip install "git+https://github.com/facebookresearch/pytorch3d.git@stable"
```

3. Install CuRobo
```
cd envs
git clone https://github.com/NVlabs/curobo.git
cd curobo
pip install -e . --no-build-isolation
cd ../..
```

4. Adjust code in `mplib` (**Important**)
- You can use `pip show mplib` to find where the `mplib` installed.

- Remove `or collide`

```python
# mplib.planner (mplib/planner.py) line 807
# remove `or collide`

if np.linalg.norm(delta_twist) < 1e-4 or collide or not within_joint_limit:
                return {"status": "screw plan failed"}
=>
if np.linalg.norm(delta_twist) < 1e-4 or not within_joint_limit:
                return {"status": "screw plan failed"}
```


