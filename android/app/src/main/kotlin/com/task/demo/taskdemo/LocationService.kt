package com.task.demo.taskdemo

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class LocationService : Service() {
    private lateinit var locationManager: LocationManager
    private lateinit var locationListener: LocationListener

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        print("LocationService -> OnCreated")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
            startForeground(1, getNotification())
        }

        observeLocationUpdates()

        locationListener = LocationListener { location ->
            val latitude = location.latitude
            val longitude = location.longitude
            saveLocationToDatabase(latitude, longitude)
        }
    }

    private fun getNotification(): Notification {
        return NotificationCompat.Builder(this, "LocationChannel")
            .setContentTitle("Location Service")
            .setContentText("Tracking your location")
            .setSmallIcon(R.drawable.launch_background)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "LocationChannel",
                "Location Service",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun saveLocationToDatabase(latitude: Double, longitude: Double) {
        CoroutineScope(Dispatchers.IO).launch {
            val locationEntity = LocationEntity(latitude = latitude, longitude = longitude, timestamp = System.currentTimeMillis())
            LocationDatabase.getInstance(applicationContext).locationDao().insertLocation(locationEntity)
        }
    }

    private fun observeLocationUpdates() {
        CoroutineScope(Dispatchers.IO).launch {
            LocationDatabase.getInstance(applicationContext)
                .locationDao()
                .getAllLocationsFlow()
                .collect { locations ->
                    val locationList = locations.map {
                        mapOf(
                            "latitude" to it.latitude,
                            "longitude" to it.longitude,
                            "timestamp" to it.timestamp
                        )
                    }

                    // Log the data being sent
                    println("Sending locations to Flutter: $locationList")

                    withContext(Dispatchers.Main) {
                        MainActivity.methodChannel?.invokeMethod("savedLocations", locationList)
                    }
                }
        }
    }

    private fun sendLocationToFlutter(latitude: Double, longitude: Double) {
        MainActivity.methodChannel?.invokeMethod("locationUpdate", "$latitude,$longitude")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
                    android.content.pm.PackageManager.PERMISSION_GRANTED
            } else {
                  true
            }
        ) {
            locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 5000L, 5f, locationListener)
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        locationManager.removeUpdates(locationListener)
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
