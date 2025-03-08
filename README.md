BreatheSmartApp is an example iOS app in SwiftUI using CoreBluetooth to connect to the HM10 BLE adapter on the STM32 project I'm currently building for air quality monitoring here:

https://github.com/markawil/BreathSmartBLE

The app uses CoreBluetooth with a Combine interface to connect to any BLE device, but functions off of connecting to the HM10 module and reading sensor data over a characteristic.

![Landing screen](https://i.imgur.com/oyHC2UYl.png)
