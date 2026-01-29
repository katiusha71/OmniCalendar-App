package com.omnicalendar.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import java.io.IOException;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.config-file}")
    private Resource firebaseConfigFile;

    @PostConstruct
    public void initialize() {
        try {
            if (firebaseConfigFile.exists()) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(firebaseConfigFile.getInputStream()))
                        .build();

                if (FirebaseApp.getApps().isEmpty()) {
                    FirebaseApp.initializeApp(options);
                    log.info("Firebase initialized successfully");
                }
            } else {
                log.warn("Firebase config file not found. Push notifications will be disabled.");
            }
        } catch (IOException e) {
            log.error("Failed to initialize Firebase", e);
        }
    }
}
