[简体中文](README.md) | English

# **HTEffect_Demo_iOS**
## **Instruction**
- This article introduces how to quickly configure HTEffect module.

<br/>

## **Steps**
### **1. Download**
Execute the following commands in sequence
- git clone **repository**
- cd **project directory**
- git submodule init && git submodule update

### **2. Configure**
After downloading, open project
- Replace **Bundle Display Name** and **Bundle Identifier** with **your APP name** and **package name**, respectively
- Replace **Your AppId** in [[HTEffect shareInstance] initHTEffect:@"Your AppId" withDelegate:self] with **your AppId** in AppDelegate.m
- Replace **HTEffect.bundle** in HTEffect folder with your **HTEffect.bundle**
- Build, Run, and search **init-status** to see relevant logs
- The specific steps can be found by searching **//todo --- HTEffect** globally

<br/>
