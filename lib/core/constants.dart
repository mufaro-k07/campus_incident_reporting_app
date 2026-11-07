import 'package:flutter/foundation.dart';

const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

// Lets a personal email register while testing. It only works in debug
// builds, and must be false before recording the demo.
const devAllowAnyEmail = false;

const allowAnyEmailDomain = devAllowAnyEmail && kDebugMode;

const cloudinaryCloudName = 'qejqolc8';
const cloudinaryUploadPreset = 'incident_photos_unsigned';

const maxPhotoBytes = 5 * 1024 * 1024;

const campusLocations = [
  'Learning Commons',
  'Social Commons',
  'Enterprise Commons',
  'Leadership Center',
  'Library',
  'Study Pods',
  'Auditorium',
  'Cafeteria',
  'Basketball Court',
  'Wellness Center',
  'Faculty Office',
  'Parking',
  'Other',
];
