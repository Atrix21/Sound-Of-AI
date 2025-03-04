# SoundofAI
## Objective
Sound of AI is a mobile application designed to classify heart sounds using advanced deep learning models. By leveraging audio classification technology, users can analyze audio files and receive predictions for various sound categories, potentially aiding in early detection and diagnosis.

## __Technical Description__
### Datasets and Models
__Pascal Classifying Heart Sounds Challenge Dataset__
__Models:__ MobileNetV2, ResNet152V2 (with additional custom layers)      
__Classes:__ Murmur, Normal, Extrasystole, Artifact


<img align="center" src="https://github.com/Atrix21/Sound-Of-AI/blob/main/Datasets/A_data/soundofAIdata.png" width="600">


### __Mobile Application Features__
__User Authentication:__ Email-password and phone number-SMS verification    
__Classifiers:__ HeartSound classifier    
__Audio Analysis:__ Upload audio files and receive predicted class labels via FlaskAPI
### __Deployment__    
__Backend:__ FlaskAPI for data preprocessing and model inference    
__Hosting:__ AWS EC2 instance for global access

## Implementation
### Integration
__Flutter Application & FlaskAPI:__ HeartSound and UrbanSound Classification    
__Authentication:__ Dual-method user verification (email-password, phone number-SMS)    
__Email Authentication:__ Firebase manages user registration and login      
__Phone Authentication:__ SMS-based OTP verification
### Application Structure
__Home Page:__ Navigation to UrbanSound or HeartSound classifier      
__HeartSound Classifier:__ Upload WAV files for heart sound classification      
__Features Page:__ Display waveform and spectrogram of the audio file     
__Database:__ Firebase Authentication and Cloud Firestore for user data and predictions storage

## Platform and Tools
__Mobile Development:__ AndroidStudio (Flutter), Firebase (Database)        
__Model Training:__ Jupyter Notebook, Google Colab     
__Models:__ ResNet152v2, MobileNetV2     
__API Development:__ Visual Studio (FlaskAPI)    
__Deployment:__ AWS EC2 instance
## System Configuration
Device: Macbook Pro
Processor: M1 silicon chip
RAM: 16GB

## Building the Model
### HeartSound Classifier - Model Summary
To enhance the classification capabilities, we extended the base architectures of ResNet152v2 and MobileNetV2 with additional custom layers. These layers were designed to:

Improve Feature Extraction: By adding specialized layers, we were able to refine the feature extraction process, making the model more sensitive to subtle variations in the audio signals.
__Increase Model Capacity:__ The extra layers help the models better capture complex patterns and nuances in the data.     
__Tailored Output:__ Custom layers allow for fine-tuning of the output structure, optimizing the model's performance for the specific classification tasks.


## Research Paper Reference
The model building and prediction process for "Sound of AI" was significantly influenced by the research paper:

Title: Heartbeat Sound Classification with Visual Domain, Deep Neural Networks       
Authors: Uddipan Mukherjee, Sidharth Pancholi        
Publication: 4 Oct 2021       
Link: _(https://arxiv.org/pdf/2107.13237)_        
This paper provided key insights into data preprocessing, model architecture, and the training process, which were instrumental in developing the HeartSound and UrbanSound classifiers.

## Summary
The "Sound of AI" flutter mobile application utilizes advanced deep learning models to classify audio files into predefined categories. The backend API, hosted on an AWS EC2 instance, facilitates the classification process, making the app's functionality globally accessible.
