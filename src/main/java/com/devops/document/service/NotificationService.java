package com.devops.document.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final SnsClient snsClient;

    @Value("${aws.sns.topic-arn}")
    private String topicArn;

    public void publishDocumentUploadedEvent(String fileKey, String contentType, long size) {
        String message = String.format(
            "{\"event\": \"DOCUMENT_UPLOADED\", \"fileKey\": \"%s\", \"contentType\": \"%s\", \"size\": %d}",
            fileKey, contentType, size
        );

        PublishRequest request = PublishRequest.builder()
                .topicArn(topicArn)
                .message(message)
                .build();

        snsClient.publish(request);
    }
}
