import 'dart:async';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:admin/Common%20widgets/notification_services.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart'
    show ProjectDetailsScreen;
import 'package:admin/app/modules/EmployeeDashboard/views/sitesupervisor.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../controllers/employee_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin/app/routes/app_pages.dart';
import '../controllers/employee_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_dashboard_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceSystemWidget extends StatefulWidget {
  const AttendanceSystemWidget({super.key});

  @override
  State<AttendanceSystemWidget> createState() => _AttendanceSystemWidgetState();
}

class _AttendanceSystemWidgetState extends State<AttendanceSystemWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool _isLocationLoading = false;
  String _locationAddress = "Fetching location...";
  Position? _currentPosition;
  File? _imageFile;
  String _attendanceStatus = "";
  Color _statusColor = Colors.black;
  bool _hasMarkedAttendanceToday = false;
  Map<String, dynamic>? _todayAttendance;

  @override
  void initState() {
    super.initState();
    _checkTodayAttendance();
    _getLocation();
  }

  Future<void> _checkTodayAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        setState(() {
          _hasMarkedAttendanceToday = true;
          _todayAttendance = attendanceSnapshot.docs.first.data();

          // Check if attendance was late
          if (_todayAttendance?['isLate'] == true) {
            _attendanceStatus =
                "Marked Late at ${_todayAttendance?['timeString'] ?? 'unknown time'}";
            _statusColor = Colors.orange;
          } else {
            _attendanceStatus =
                "Marked Present at ${_todayAttendance?['timeString'] ?? 'unknown time'}";
            _statusColor = Colors.green;
          }
        });
      }
    } catch (e) {
      print("Error checking attendance: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationAddress = "Fetching location...";
    });

    try {
      // Different handling for web vs mobile
      if (kIsWeb) {
        // Web implementation using browser geolocation
        final geolocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: false,
          timeLimit: const Duration(seconds: 10),
        );

        _currentPosition = geolocation;

        // For web, we might need to use a different geocoding approach
        try {
          final response = await http.get(Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_currentPosition!.latitude},${_currentPosition!.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY'));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['results'] != null && data['results'].isNotEmpty) {
              setState(() {
                _locationAddress = data['results'][0]['formatted_address'];
                _isLocationLoading = false;
              });
            }
          }
        } catch (e) {
          setState(() {
            _locationAddress = "Location found but address not available";
            _isLocationLoading = false;
          });
        }
      } else {
        // Mobile implementation (original code)
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() {
              _locationAddress = "Location permission denied";
              _isLocationLoading = false;
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _locationAddress = "Location permission permanently denied";
            _isLocationLoading = false;
          });
          return;
        }

        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException("Failed to get location within time limit");
        });

        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException("Failed to get address within time limit");
        });

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _locationAddress =
                "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}";
            _isLocationLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _locationAddress = "Error fetching location: $e";
        _isLocationLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching location: $e")),
        );
      }
    }
  }

  // This method handles the camera functionality

  Future<void> _takePhoto() async {
    try {
      // Request camera permission (handled differently on web)
      if (!kIsWeb) {
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text("Camera permission is required to mark attendance")));
          return;
        }
      }

      // Ensure we have location permission too
      if (_currentPosition == null) {
        await _getLocation();
        if (_currentPosition == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Unable to get location. Please try again.")));
          return;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        // Web-specific options
        preferredCameraDevice: CameraDevice.front,
        // This helps with web camera handling
        requestFullMetadata: false,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });

        // On web, we need to manually dispose of the camera resources
        if (kIsWeb) {
          // Force a rebuild to ensure camera is properly released
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      print("Error taking photo: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error taking photo: $e")));
    }
  }

  bool _isWithinOfficeHours() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 9, 30); // 9:30 AM
    final endTime = DateTime(now.year, now.month, now.day, 13, 0); // 1:00 PM
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  Widget _buildAttendanceForm() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 9, 30); // 9:30 AM
    final lateTime = DateTime(now.year, now.month, now.day, 10, 10); // 10:10 AM
    final endTime = DateTime(now.year, now.month, now.day, 13, 0); // 1:00 PM

    String getStatusMessage() {
      if (now.isBefore(startTime)) {
        return "Attendance marking starts at 9:30 AM";
      } else if (now.isAfter(endTime)) {
        return "Attendance marking is closed for today";
      } else if (now.isAfter(lateTime)) {
        return "You will be marked late";
      } else {
        return "You're on time";
      }
    }

    Color getStatusColor() {
      if (now.isBefore(startTime) || now.isAfter(endTime)) {
        return Colors.red;
      } else if (now.isAfter(lateTime)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "Today's Attendance",
          style: AppTypography.medium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Location info - FIXED OVERFLOW HERE
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Changed to start alignment
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.buildingBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: "Current Location",
                      style: AppTypography.small.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isLocationLoading
                        ? const SizedBox(
                            height: 20,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                            ),
                          )
                        : CommonText(
                            text: _locationAddress,
                            style: AppTypography.small.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 3, // Added maxLines
                            overflow: TextOverflow
                                .ellipsis, // Added overflow handling
                          ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // Added spacing
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getLocation,
                color: AppTheme.buildingBlue,
                padding: EdgeInsets.zero, // Reduced padding
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ), // Made button smaller
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Photo section
        if (_imageFile != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _imageFile!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Buttons - IMPROVED RESPONSIVE LAYOUT
        Row(
          children: [
            Expanded(
              child: CommonButton(
                text: _imageFile == null ? "Take Photo" : "Retake Photo",
                onPressed: _isWithinOfficeHours() ? _takePhoto : null,
                color: _isWithinOfficeHours()
                    ? AppTheme.buildingBlue
                    : Colors.grey,
                textsize: 12,
                icon: Icons.camera_alt,
              ),
            ),
            if (_imageFile != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  textsize: 12,
                  text: "Mark Attendance",
                  onPressed: _isWithinOfficeHours()
                      ? (_isLoading ? null : _markAttendance)
                      : null,
                  color: _isWithinOfficeHours()
                      ? AppTheme.primaryGreen
                      : Colors.grey,
                  icon: Icons.check_circle,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ],
        ),

        // Current time indicator
        const SizedBox(height: 16),
        Center(
          child: CommonText(
            text:
                "Current Time: ${DateFormat('hh:mm a').format(DateTime.now())}",
            style: AppTypography.small.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Show if user will be marked late
        const SizedBox(height: 8), // Added spacing
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getStatusColor().withOpacity(0.3),
              ),
            ),
            child: CommonText(
              text: getStatusMessage(),
              style: AppTypography.small.copyWith(
                color: getStatusColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

// This method compresses the image before uploading
  Future<File> _compressImage(File imageFile) async {
    try {
      // Get file extension
      final fileExtension = path.extension(imageFile.path).toLowerCase();

      // Check if it's already a compressed format
      if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
        // For JPEG files, use the image_compression package or a similar approach
        // This is a simple file size check approach - if the file is already small, return it
        final fileSize = await imageFile.length();
        if (fileSize < 500 * 1024) {
          // Less than 500KB
          return imageFile;
        }
      }

      // Create a temporary compressed file path
      final dir = await getTemporaryDirectory();
      final targetPath =
          dir.path + "/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Compress and save the image - Note: Using an example compression approach
      // In a real app, you'd use a proper image compression library like flutter_image_compress

      // For this example, we'll use a mock compression approach
      // Copy the file to simulate compression since we can't use external packages directly
      final compressedFile = await imageFile.copy(targetPath);

      return compressedFile;
    } catch (e) {
      print("Error compressing image: $e");
      // Return original file if compression fails
      return imageFile;
    }
  }

  Future<void> _markAttendance() async {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 9, 30); // 9:30 AM
    final lateTime = DateTime(now.year, now.month, now.day, 10, 10); // 10:10 AM
    final endTime = DateTime(now.year, now.month, now.day, 13, 0); // 1:00 PM

    // Check if before start time
    if (now.isBefore(startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance marking starts at 9:30 AM"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if after end time
    if (now.isAfter(endTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance marking closes at 1:00 PM"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine if late
    final isLate = now.isAfter(lateTime);

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("User not logged in")));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current time and check if it's late
      final timeString = DateFormat('hh:mm a').format(now);
      final dateString = DateFormat('yyyy-MM-dd').format(now);

      // Variables for tracking upload state
      bool uploadCancelled = false;
      double uploadProgress = 0.0;
      String uploadStatus = "Preparing...";

      // Show uploading progress indicator dialog with cancel option
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Uploading Attendance"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.buildingBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      "$uploadStatus (${(uploadProgress * 100).toStringAsFixed(0)}%)"),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    uploadCancelled = true;
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ],
            );
          });
        },
      );

      if (uploadCancelled) {
        return;
      }

      // Update dialog status
      uploadStatus = "Compressing image...";
      // We need to use a reference to update the dialog
      if (context.mounted) {
        Navigator.of(context).pop(); // Close previous dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("Uploading Attendance"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: null, // Indeterminate progress during compression
                  ),
                  const SizedBox(height: 16),
                  Text(uploadStatus),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    uploadCancelled = true;
                    Navigator.of(ctx).pop();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      }

      // First compress the image file to reduce upload time
      File compressedFile = await _compressImage(_imageFile!);

      if (uploadCancelled || !context.mounted) {
        return;
      }

      // Update dialog for upload phase
      uploadStatus = "Uploading photo...";
      uploadProgress = 0.0;

      if (context.mounted) {
        Navigator.of(context).pop(); // Close previous dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return StatefulBuilder(builder: (context, setDialogState) {
              return AlertDialog(
                title: Text("Uploading Attendance"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: uploadProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.buildingBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                        "$uploadStatus (${(uploadProgress * 100).toStringAsFixed(0)}%)"),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      uploadCancelled = true;
                      Navigator.of(ctx).pop();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                ],
              );
            });
          },
        );
      }

      // Upload image to Firebase Storage
      final fileName =
          'attendance_${userId}_${now.millisecondsSinceEpoch}${path.extension(compressedFile.path)}';
      final ref = _storage.ref().child('attendance_photos/$fileName');

      final uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'date': dateString,
            'compressed': 'true',
          },
        ),
      );

      // Set up a completer to handle async completion
      Completer<TaskSnapshot> completer = Completer<TaskSnapshot>();

      // Monitor upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          // Update progress
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          uploadProgress = progress;

          // Update dialog if context is still available
          if (context.mounted) {
            // Force a rebuild of the dialog
            Navigator.of(context).pop();

            if (!uploadCancelled) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: Text("Uploading Attendance"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: uploadProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.buildingBlue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                            "$uploadStatus (${(uploadProgress * 100).toStringAsFixed(0)}%)"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          uploadCancelled = true;
                          Navigator.of(ctx).pop();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }

          // Complete when done
          if (snapshot.state == TaskState.success) {
            completer.complete(snapshot);
          }
        },
        onError: (e) {
          print("Upload error: $e");
          completer.completeError(e);
          if (context.mounted) {
            Navigator.of(context).pop(); // Close the dialog
          }
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading photo: $e")),
          );
        },
        onDone: () {
          // This ensures we catch completion even if the success state is missed
          if (!completer.isCompleted) {
            uploadTask.then(completer.complete);
          }
        },
      );

      // Wait for upload to complete
      TaskSnapshot snapshot;
      try {
        // Add a timeout to prevent infinite waiting
        snapshot = await completer.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            throw TimeoutException("Upload timed out. Please try again.");
          },
        );
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close the dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: $e")),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (uploadCancelled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Update dialog for final processing
      uploadStatus = "Processing...";
      if (context.mounted) {
        Navigator.of(context).pop(); // Close previous dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("Finalizing Attendance"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text("Processing your attendance record..."),
                ],
              ),
            );
          },
        );
      }

      // Get the download URL
      final imageUrl = await snapshot.ref.getDownloadURL();

      if (uploadCancelled || !context.mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Store attendance record in Firestore
      await _firestore.collection('attendance').add({
        'userId': userId,
        'timestamp': Timestamp.now(),
        'date': dateString,
        'timeString': timeString,
        'isLate': isLate,
        'photoUrl': imageUrl,
        'location': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'address': _locationAddress,
        },
        'lateMinutes': isLate ? now.difference(startTime).inMinutes : 0,
      });

      // Close the dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _hasMarkedAttendanceToday = true;
        _attendanceStatus = isLate
            ? "Marked Late at $timeString"
            : "Marked Present at $timeString";
        _statusColor = isLate ? Colors.orange : Colors.green;
        _imageFile = null;
        _isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isLate
              ? "Attendance marked as late at $timeString"
              : "Attendance marked successfully at $timeString"),
          backgroundColor: isLate ? Colors.orange : Colors.green,
        ));
      }

      // Refresh attendance status
      _checkTodayAttendance();
    } catch (e) {
      print("Error marking attendance: $e");

      if (context.mounted) {
        Navigator.of(context).pop(); // Make sure dialog is closed
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error marking attendance: $e")));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Improved image compression function

// You might also want to add this utility method to help with image operations
  Future<int> getFileSizeInKB(File file) async {
    final int bytes = await file.length();
    final int kb = bytes ~/ 1024;
    return kb;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.buildingBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                CommonText(
                  text: "Daily Attendance",
                  style: AppTypography.medium.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Current status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status display
                if (_hasMarkedAttendanceToday)
                  _buildStatusCard()
                else
                  _buildAttendanceForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _statusColor == Colors.green
                    ? Icons.check_circle
                    : Icons.warning,
                color: _statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              CommonText(
                text: _attendanceStatus,
                style: AppTypography.medium.copyWith(
                  fontSize: 16,
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_todayAttendance != null) ...[
            _infoRow(
                Icons.location_on,
                "Location",
                _todayAttendance?['location']?['address'] ??
                    "Unknown location"),
            const SizedBox(height: 8),
            if (_todayAttendance?['isLate'] == true) ...[
              _infoRow(Icons.hourglass_empty, "Late by",
                  "${_todayAttendance?['lateMinutes'] ?? 0} minutes"),
            ] else ...[
              _infoRow(Icons.timer, "On time", "Good job!"),
            ],
            const SizedBox(height: 8),
            if (_todayAttendance?['photoUrl'] != null) ...[
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _todayAttendance!['photoUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[700],
        ),
        const SizedBox(width: 8),
        CommonText(
          text: "$label: ",
          style: AppTypography.small.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: CommonText(
            text: value,
            style: AppTypography.small,
          ),
        ),
      ],
    );
  }
}

class AttendanceHistoryScreen extends StatefulWidget {
  final String initialMonth;

  const AttendanceHistoryScreen({
    super.key,
    required this.initialMonth,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _selectedMonth;
  bool _isLoading = false;
  List<Map<String, dynamic>> _attendanceRecords = [];

  // Statistics
  int _totalPresent = 0;
  int _totalLate = 0;
  int _totalAbsent = 0;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _fetchAttendanceRecords();
  }

  Future<void> _fetchAttendanceRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Parse selected month
      final dateParts = _selectedMonth.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);

      // Calculate start and end dates for the selected month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0); // Last day of the month

      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      // Fetch attendance records for the selected month
      // Use a simplified query to avoid requiring a composite index
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      // Filter the date range client-side
      final filteredDocs = querySnapshot.docs.where((doc) {
        final docDate = doc.data()['date'] as String;
        return docDate.compareTo(startDateStr) >= 0 &&
            docDate.compareTo(endDateStr) <= 0;
      }).toList();

      // Sort the results in Dart
      filteredDocs.sort((a, b) =>
          (a.data()['date'] as String).compareTo(b.data()['date'] as String));

      final records = filteredDocs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      // Calculate statistics
      _totalPresent =
          records.where((record) => record['isLate'] == false).length;
      _totalLate = records.where((record) => record['isLate'] == true).length;

      // Calculate total working days in the month (excluding weekends)
      int totalWorkingDays = 0;
      for (int day = 1; day <= endDate.day; day++) {
        final date = DateTime(year, month, day);
        // Exclude weekends (Saturday and Sunday)
        if (date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday) {
          totalWorkingDays++;
        }
      }

      // Calculate absences (working days minus days present)
      _totalAbsent = totalWorkingDays - (_totalPresent + _totalLate);
      if (_totalAbsent < 0) _totalAbsent = 0;

      setState(() {
        _attendanceRecords = records;
      });
    } catch (e) {
      print("Error fetching attendance records: $e");
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error fetching attendance records. Please try again."),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Generate a list of the last 12 months for the dropdown
  List<Map<String, String>> _getMonthOptions() {
    final options = <Map<String, String>>[];
    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final value = DateFormat('yyyy-MM').format(date);
      final label = DateFormat('MMMM yyyy').format(date);

      options.add({
        'value': value,
        'label': label,
      });
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: AppTheme.buildingBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAttendanceRecords,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildStatisticsSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceRecords.isEmpty
                    ? _buildEmptyState()
                    : _buildAttendanceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthOptions = _getMonthOptions();

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.buildingBlue.withOpacity(0.05),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppTheme.buildingBlue),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: InputDecoration(
                labelText: "Select Month",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: monthOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != _selectedMonth) {
                  setState(() {
                    _selectedMonth = value;
                  });
                  _fetchAttendanceRecords();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Statistics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.buildingBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                "Present",
                _totalPresent.toString(),
                Colors.green,
                Icons.check_circle,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                "Late",
                _totalLate.toString(),
                Colors.orange,
                Icons.access_time,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                "Absent",
                _totalAbsent.toString(),
                Colors.red[400]!,
                Icons.cancel_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No attendance records found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "There are no attendance records for this month",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendanceRecords.length,
      itemBuilder: (context, index) {
        final record = _attendanceRecords[index];
        final date = record['date'] as String;
        final time = record['timeString'] as String;
        final isLate = record['isLate'] as bool;
        final lateMinutes = record['lateMinutes'] as int? ?? 0;
        final address =
            record['location']?['address'] as String? ?? 'Unknown location';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLate
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isLate
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              child: Icon(
                isLate ? Icons.warning : Icons.check_circle,
                color: isLate ? Colors.orange : Colors.green,
              ),
            ),
            title: Row(
              children: [
                Text(
                  DateFormat('EEE, MMM dd').format(DateTime.parse(date)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLate
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLate ? "Late" : "On time",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isLate ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Checked in at $time",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isLate) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.hourglass_empty,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "Late by $lateMinutes minutes",
                        style: const TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            onTap: () {
              // Show detailed view with photo
              if (record['photoUrl'] != null) {
                _showAttendanceDetails(record);
              }
            },
            trailing: record['photoUrl'] != null
                ? const Icon(Icons.chevron_right)
                : null,
          ),
        );
      },
    );
  }

  void _showAttendanceDetails(Map<String, dynamic> record) {
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Attendance Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.buildingBlue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                record['photoUrl'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _detailRow(
              "Date",
              DateFormat('EEEE, MMMM dd, yyyy')
                  .format(DateTime.parse(record['date'])),
              Icons.calendar_today,
            ),
            _detailRow(
              "Time",
              record['timeString'],
              Icons.access_time,
            ),
            _detailRow(
              "Status",
              record['isLate'] ? "Late" : "On time",
              record['isLate'] ? Icons.warning : Icons.check_circle,
              color: record['isLate'] ? Colors.orange : Colors.green,
            ),
            if (record['isLate'])
              _detailRow(
                "Late by",
                "${record['lateMinutes']} minutes",
                Icons.hourglass_empty,
                color: Colors.orange,
              ),
            _detailRow(
              "Location",
              record['location']?['address'] ?? "Unknown location",
              Icons.location_on,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ));
  }

  Widget _detailRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? Colors.grey[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceSystemScreen extends StatelessWidget {
  const AttendanceSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        backgroundColor: AppTheme.buildingBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Using the existing AttendanceSystemWidget
              const AttendanceSystemWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
