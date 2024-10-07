<p align="center">
  <a href="https://play.google.com/store/apps/dev?id=7086930298279250852" target="_blank">
    <img alt="" src="https://github-production-user-asset-6210df.s3.amazonaws.com/125717930/246971879-8ce757c3-90dc-438d-807f-3f3d29ddc064.png" width=500/>
  </a>  
</p>

#### 🤗 Hugging Face - [Here](https://huggingface.co/kby-ai) <span> <img src="https://github.com/kby-ai/.github/assets/125717930/bcf351c5-8b7a-496e-a8f9-c236eb8ad59e" style="margin: 4px; width: 36px; height: 20px"> <span/>
#### 📚 Product & Resources - [Here](https://github.com/kby-ai/Product)
#### 🛟 Help Center - [Here](https://docs.kby-ai.com)
#### 💼 KYC Verification Demo - [Here](https://github.com/kby-ai/KYC-Verification-Demo-Android)
#### 🙋‍♀️ Docker Hub - [Here](https://hub.docker.com/u/kbyai)

# Automatic-License-Plate-Recognition-Flutter

## Overview

We implemented `ANPR/ALPR(Automatic Number/License Plate Recognition)` engine with unmatched accuracy and precision by applying SOTA(State-of-the-art) deep learning techniques in this repository. </br>
We have built `ANPR/ALPR` project with Flutter framework.

KBY-AI's `LPR` solutions utilizes artificial intelligence and machine learning to greatly surpass legacy solutions. Now, in real-time, users can receive a vehicle's plate number.

The `ALPR` system consists of the following steps:
- Vehicle image capture
- Preprocessing
- Vehicle detection
- Number plate extraction
- Charater segmentation
- Optical Character Recognition(OCR) </br>

The `ALPR` system works in these strides, the initial step is the location of the vehicle and capturing a vehicle image of front or back perspective of the vehicle, the second step is the localization of Number Plate and then extraction of vehicle Number Plate is an image. The final stride uses image segmentation strategy, for the segmentation a few techniques neural network, mathematical morphology, color analysis and histogram analysis. Segmentation is for individual character recognition. Optical Character Recognition (OCR) is one of the strategies to perceive the every character with the assistance of database stored for separate alphanumeric character.

### Google Play
<a href="https://play.google.com/store/apps/details?id=com.kbyai.alpr_flutter" target="_blank">
  <img alt="" src="https://user-images.githubusercontent.com/125717930/230804673-17c99e7d-6a21-4a64-8b9e-a465142da148.png" height=80/>
</a>

## Screenshots
<p float="left">
  <img src="https://github.com/user-attachments/assets/d19998a8-9b94-47dd-86f5-a206e430d4cf" width=200/>
  <img src="https://github.com/user-attachments/assets/34be1181-fe83-4be0-b955-7c174961410b" width=200/>
  <img src="https://github.com/user-attachments/assets/4d17e31e-d1e0-492a-98bd-c34ed68c3a6a" width=200/>
</p>

<p float="left">
  <img src="https://github.com/user-attachments/assets/dc819a46-cdc7-4459-aca1-f94da8e1a14e" width=200/>
  <img src="https://github.com/user-attachments/assets/84f89d18-9c34-465e-a855-8c2b4467ce69" width=200/>
  <img src="https://github.com/user-attachments/assets/23645cc7-2f79-4deb-becd-2d88cb32c983" width=200/>
</p>

## Performance Video
You can visit our YouTube video for ANPR/ALPR model's performance [here](https://www.youtube.com/watch?v=sLBYxgMdXlA) to see how well our demo app works.</br></br>
[![ANPR/ALPR Demo](https://img.youtube.com/vi/sLBYxgMdXlA/0.jpg)](https://www.youtube.com/watch?v=sLBYxgMdXlA)</br>

## SDK License
- The code line below shows how to update SDK with the `license key`: https://github.com/kby-ai/Automatic-License-Plate-Recognition-Flutter/blob/1dbfc414f3386bd4132a333ac3a9b79dff93c213/lib/main.dart#L69-L78
- To request `license key`, please contact us:</br>
🧙`Email:` contact@kby-ai.com</br>
🧙`Telegram:` [@kbyai](https://t.me/kbyai)</br>
🧙`WhatsApp:` [+19092802609](https://wa.me/+19092802609)</br>
🧙`Skype:` [live:.cid.66e2522354b1049b](https://join.skype.com/invite/OffY2r1NUFev)</br>
🧙`Facebook:` https://www.facebook.com/KBYAI</br>

## How To Run
### 1. Flutter Setup
  Make sure you have `Flutter` installed. </br>
  This repo has been built with Flutter version `3.22.3`.</br> 
  If you don't get `Flutter` installed, please follow the instructions provided in the official `Flutter` documentation [here](https://docs.flutter.dev/get-started/install).</br>
  
### 2. Placing Library File
  Please contact us to get our `SDK library` file(`libttvalpr.aar`) and put it on the suitable SDK folder(folder `android/libttvalpr`).</br> 
  
### 3. Running the App
  Try to build this repo to make sure that SDK works fine by linking real `Android` phone, not `simulator`. Once it works fine, you are ready to integrate our SDK to your project.</br>
  Run the following commands:</br>
  ```bash
  flutter pub upgrade
  flutter run
  ```  
  If you plan to run the iOS app, please refer to the following [link](https://docs.flutter.dev/deployment/ios) for detailed instructions.</br>
  
## About SDK

### 1. Set up
### 1.1 Setting Up ALPR SDK
  > Android
  - Please contact us to get our `SDK library` file(`libttvalpr.aar`) and paste it to SDK folder(folder `android/libttvalpr`).
    And then copy the SDK(folder `libttvalpr`) to the folder `android` in your project.
  -  Add SDK to the project in `settings.gradle`.
  ```dart
  include ':libttvalpr'
  ```

3. Add SDK to the project in `settings.gradle`.
```bash
include ':libidsdk'
```

3. Add dependency to your `build.gradle`.
```bash
implementation project(path: ':libidsdk')
```

### 2. Initializing the SDK

- Step One

To begin, you need to activate the SDK using the `license key` that you have received.
```kotlin
IDSDK.setActivation("...")
```

If activation is successful, SDK would return `SDK_SUCCESS`. Otherwise, it would return an error message.

- Step Two

Once activation is successful, you can call initialization function supported by our SDK.
```kotlin
IDSDK.init(getAssets());
```
If initialization is successful, SDK would return `SDK_SUCCESS`. Otherwise, it would return an error message.
