# Smart Seat Belt and Accident Alert System

## Overview

The Smart Seat Belt and Accident Alert System is an IoT-based project designed to enhance vehicle safety through app integration. This system ensures that the vehicle operates only when the seat belt is fastened and provides immediate alerts in case of accidents.

## Features

- **Seat Belt Detection**: Prevents the vehicle from starting unless the seat belt is securely fastened.
- **Accident Detection**: Utilizes sensors to detect collisions or accidents.
- **Alert Mechanism**: Sends immediate notifications to emergency contacts or authorities upon detecting an accident.
- **App Integration**: Allows users to monitor system status and receive alerts through a dedicated mobile application.

## Components

- **Hardware**:
  - Microcontroller (e.g., Arduino UNO)
  - Seat belt sensor
  - Vibration sensor
  - GSM module
  - GPS module
  - Buzzer
  - Power supply

- **Software**:
  - Embedded C/C++ for microcontroller programming
  - Mobile application developed using Dart (Flutter)

## Installation and Setup

1. **Hardware Assembly**:
   - Connect the seat belt sensor to detect fastening status.
   - Integrate the vibration sensor to monitor for collisions.
   - Set up the GSM and GPS modules for communication and location tracking.
   - Connect the buzzer for audible alerts.
   - Ensure all components are powered appropriately.

2. **Software Installation**:
   - Program the microcontroller with the provided firmware.
   - Install the mobile application on your device.
   - Pair the mobile application with the hardware system via Bluetooth or Wi-Fi.

## Usage

- **Starting the Vehicle**:
  - Fasten the seat belt to enable the vehicle's ignition system.
  - If the seat belt is not fastened, the vehicle will remain immobilized.

- **Accident Detection and Alert**:
  - In the event of a collision, the vibration sensor triggers the alert system.
  - The system sends an SMS with the vehicle's location to predefined emergency contacts.
  - The mobile application receives a notification about the incident.

## Repository Structure

- `SmartSeatApp/`: Contains the source code for the mobile application developed using Flutter.
- `SmartSeatBelt_AccidentAlert_System/`: Includes the firmware code for the microcontroller and hardware schematics.
- `LICENSE`: Details the licensing information for this project.
- `README.md`: Provides an overview and instructions for the project.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Acknowledgments

Special thanks to the contributors and the open-source community for their support and resources.

