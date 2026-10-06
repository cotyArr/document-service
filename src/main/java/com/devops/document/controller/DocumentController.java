package com.devops.document.controller;

import com.devops.document.service.S3StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/documents")
@RequiredArgsConstructor
public class DocumentController {

    private final S3StorageService storageService;

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadDocument(@RequestParam("file") MultipartFile file) throws IOException {
        String fileKey = storageService.uploadFile(file);

        return ResponseEntity.ok(Map.of(
            "status", "SUCCESS",
            "message", "Archivo subido exitosamente a LocalStack S3 y notificación enviada a SNS",
            "fileKey", fileKey,
            "originalFilename", file.getOriginalFilename()
        ));
    }
}
