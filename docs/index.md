---
comments: true
---

# RoboTwin 2.0


<style>
* {
  box-sizing: border-box;
}
body {
  font-family: Arial, Helvetica, sans-serif;
}
hr.narrow {margin: 0 10px}
/* 并排浮动两列 */
.column {
  float: left;
  width: 50%;
  padding: 0 5px;
}
.fullcolumn {
  float: left;
  width: 100%;
  padding: 0 5px;
}


/* 删除多余的左右边距，由于填充 */
.row {margin: 0 10px; margin-bottom: 20px;}

/* 清除列后的浮点数 */
.row:after {
  content: "";
  display: table;
  clear: both;
}

/* 响应列 */
@media screen and (max-width: 600px) {
  .column {
    width: 100%;
    display: block;
    margin-bottom: 20px;
  }
}

/* 设置计数器卡片的样式 */
.card {
  box-shadow: 0 0px 3px 0 rgba(128, 128, 128, 0.2);
  padding: 10px;
  transition: 0.3s;
  /* text-align: center; */
  /* background-color: #ffffff; */
  border-radius: 2px;
}
.card:hover {
  box-shadow: 0 8px 16px 0 rgba(128, 128, 128, 0.2);
}
.container {
  padding: 5px 5px;
}

.centered-table {
    display: flex;
    justify-content: center;
    align-items: center;
    /* height: 100vh; */
  }
  table {
    border-collapse: collapse;
    margin: auto;
    text-align: center;
  }
  th, td {
    /* padding: 8px; */
    border: 1px solid #ddd;
  }
  th {
    background-color: #f2f2f2;
  }
  tr:hover {background-color: #ddd;}
</style>

<img src="./assets/robotwin-text-logo.jpg" alt="description" style="display: block; margin: auto; width: 70%;">

> Here is the official documentation for RoboTwin 2.0, which includes installation and usage instructions for various RoboTwin functionalities, detailed information on the 50 bimanual tasks in RoboTwin 2.0, comprehensive descriptions of the RoboTwin-OD dataset, and guidelines for joining the community.

<img src="./assets/teaser.png" alt="description" style="display: block; margin: auto; width: 100%;">

## Everything about RoboTwin 2.0

<div style="display: flex; justify-content: center; margin-top: 20px;">
  <video 
    src="https://robotwin-platform.github.io/RoboTwin2.0_video.mp4" 
    controls 
    autoplay 
    muted 
    loop 
    style="width: 100%; height: auto;"
  ></video>
</div>

> <div style="font-size: small"><a href="https://tianxingchen.github.io/">Tianxing Chen</a>, Zanxin Chen, Baijun Chen, Zijian Cai, <a href="https://10-oasis-01.github.io">Yibin Liu</a>, <a href="https://kolakivy.github.io/">Qiwei Liang</a>, Zixuan Li, Xianliang Lin, <a href="https://geyiheng.github.io">Yiheng Ge</a>, Zhenyu Gu, Weiliang Deng, Yubin Guo, Tian Nian, Xuanbing Xie, <a href="https://www.linkedin.com/in/yusen-qin-5b23345b/">Qiangyu Chen</a>, Kailun Su, Tianling Xu, Guodong Liu, <a href="https://aaron617.github.io/">Mengkang Hu</a>, <a href="https://c7w.tech/about">Huan-ang Gao</a>, Kaixuan Wang, <a href="https://liang-zx.github.io/">Zhixuan Liang</a>, <a href="https://www.linkedin.com/in/yusen-qin-5b23345b/">Yusen Qin</a>, Xiaokang Yang, <a href="http://luoping.me/">Ping Luo</a>, <a href="https://yaomarkmu.github.io/">Yao Mu</a></div>

Webpage: [https://robotwin-platform.github.io/](https://robotwin-platform.github.io/)

PDF: [RoboTwin 2.0: A Scalable Data Generator and Benchmark with Strong Domain Randomization for Robust Bimanual Robotic Manipulation](https://robotwin-platform.github.io/paper.pdf)

Paper (arXiv, Coming Soon): [RoboTwin 2.0: A Scalable Data Generator and Benchmark with Strong Domain Randomization for Robust Bimanual Robotic Manipulation]()

Github Repo: [http://github.com/robotwin-Platform/RoboTwin](http://github.com/robotwin-Platform/RoboTwin)

## Previous Works

<b>[CVPR 2025 Highlight]</b> <a href="https://arxiv.org/abs/2504.13059">RoboTwin: Dual-Arm Robot Benchmark with Generative Digital Twins</a><br>
<b>[CVPR 2025 Challenge@MEIS Workshop]</b> The Technical report is coming soon !<br>
<b>[ECCV 2024 MAAS Workshop Best Paper]</b> <a href="https://arxiv.org/abs/2409.02920">RoboTwin: Dual-Arm Robot Benchmark with Generative Digital Twins (early version)</a><br>
<b>[第十九届挑战杯官方赛题]</b> <a href="https://2025.tiaozhanbei.net/media/ckeditor_uploads/49/2025/05/14/4.%E3%80%90%E9%A2%98%E7%9B%AE%E5%9B%9B%E3%80%91%E7%AB%AF%E4%BE%A7%E5%8F%AF%E9%83%A8%E7%BD%B2%E7%9A%84%E5%8F%8C%E8%87%82%E6%93%8D%E4%BD%9C%E7%AE%97%E6%B3%95%E8%AE%BE%E8%AE%A1.pdf">赛题链接</a>

## Citations
If you find our work useful, please consider citing:

RoboTwin 2.0: A Scalable Data Generator and Benchmark with Strong Domain Randomization for Robust Bimanual Robotic Manipulation
```
Coming Soon !
```

RoboTwin: Dual-Arm Robot Benchmark with Generative Digital Twins, accepted to <i style="color: red; display: inline;"><b>CVPR 2025 (Highlight)</b></i>
```
@InProceedings{Mu_2025_CVPR,
    author    = {Mu, Yao and Chen, Tianxing and Chen, Zanxin and Peng, Shijia and Lan, Zhiqian and Gao, Zeyu and Liang, Zhixuan and Yu, Qiaojun and Zou, Yude and Xu, Mingkun and Lin, Lunkai and Xie, Zhiqiang and Ding, Mingyu and Luo, Ping},
    title     = {RoboTwin: Dual-Arm Robot Benchmark with Generative Digital Twins},
    booktitle = {Proceedings of the Computer Vision and Pattern Recognition Conference (CVPR)},
    month     = {June},
    year      = {2025},
    pages     = {27649-27660}
}
```

RoboTwin: Dual-Arm Robot Benchmark with Generative Digital Twins (**early version**), accepted to <i style="color: red; display: inline;"><b>ECCV Workshop 2024 (Best Paper)</b></i>
```
@article{mu2024robotwin,
  title={RoboTwin: Dual-Arm Robot Benchmark with Generative Digital Twins (early version)},
  author={Mu, Yao and Chen, Tianxing and Peng, Shijia and Chen, Zanxin and Gao, Zeyu and Zou, Yude and Lin, Lunkai and Xie, Zhiqiang and Luo, Ping},
  journal={arXiv preprint arXiv:2409.02920},
  year={2024}
}
```
## Contact
Contact [Tianxing Chen](https://tianxingchen.github.io) if you have any questions or suggestions.