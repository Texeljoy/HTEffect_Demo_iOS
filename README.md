简体中文 | [English](README_EN.md)

# **HTEffect_Demo_iOS**
## **说明**
- 本文介绍如何快速配置HTEffect模块

<br/>

## **操作步骤**
### **1. 下载源码**
依次执行以下命令
- git clone **当前仓库**
- cd **工程目录**
- git submodule init && git submodule update

### **2. 配置工程**
下载完成后，打开工程
- 将 **Bundle Display Name** 和 **Bundle Identifier** 分别替换为您的**应用名**和**包名**
- 将AppDelegate.m中[[HTEffect shareInstance] initHTEffect:@"Your AppId" withDelegate:self]的**Your AppId**替换成您的**AppId**
- 将HTEffect文件夹下的**HTEffect.bundle**替换为您的**HTEffect.bundle**
- 编译，运行，日志搜索**init-status**可以查看相关日志
- 具体执行步骤可以全局搜索 **//todo --- HTEffect** 进行查看 

<br/>
