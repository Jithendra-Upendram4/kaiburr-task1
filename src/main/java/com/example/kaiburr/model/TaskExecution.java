package com.example.kaiburr.model;

import java.time.Instant;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskExecution {
    private Instant startTime;
    private Instant endTime;
    private String output;
}
