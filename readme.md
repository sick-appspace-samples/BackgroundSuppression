## BackgroundSuppression

Providing a scan view which shows the detected foreground points in front of a
teached-in background contour.

### Description

This sample may currently be outdated.
Editing the UI might not work properly in the latest version of SICK AppStudio. In order to edit the UI, you can either use SICK AppStudio version <= 2.4.2 or recreate it within the current version of SICK AppStudio by using the ScanView element from the extended control library (available for download).

After startup the scan view shows the original scan points retrieved from file.
After 75 scans the measured scan points define the background contour. Afterwards the app
enters the detection phase and every scan is filtered in the following way:

1. The measured scan points are subtracted from the background.
2. If the difference is larger than 150 mm the scan point is regarded as foreground point and the distance remains unchanged.
3. If the distance is less than 150 mm the scan point is regarded as background point and the distance is set to zero

### How to run

Starting this sample is possible either by running the app (F5) or
debugging (F7+F10). Information is printed to the console and the scans can be seen on the
ScanViewer in the web page. The playback stops after the last scan in the file.
To replay, the sample must be restarted.
To run this sample, a device with AppEngine >= 2.6.0 is required.

### Implementation

To run with real device data, the file provider has to be exchanged with the appropriate scan provider.

### Topics

algorithm, scan, sample, sick-appspace