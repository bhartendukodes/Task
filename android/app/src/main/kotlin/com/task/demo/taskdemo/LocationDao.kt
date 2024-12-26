package com.task.demo.taskdemo

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow


@Dao
interface LocationDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLocation(location: LocationEntity)

    @Query("SELECT * FROM LocationEntity ORDER BY timestamp DESC")
    fun getAllLocationsFlow(): Flow<List<LocationEntity>>
}