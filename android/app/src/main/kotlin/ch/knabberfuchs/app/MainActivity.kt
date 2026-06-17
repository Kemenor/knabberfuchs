package ch.knabberfuchs.app

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by the health
// package so Health Connect's permission flow can use the Activity Result APIs.
class MainActivity : FlutterFragmentActivity()
