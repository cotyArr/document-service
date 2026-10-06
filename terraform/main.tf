# 1. Configuración del Provider de AWS apuntando a LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true # <--- AGREGAR ESTA LÍNEA

  endpoints {
    s3  = "http://localhost:4566"
    sns = "http://localhost:4566"
    sqs = "http://localhost:4566"
  }
}
# 2. Bucket de S3 para almacenamiento de documentos
resource "aws_s3_bucket" "document_bucket" {
  bucket = "devops-app-storage-dev"
}

# 3. Tópico SNS para notificaciones de eventos
resource "aws_sns_topic" "document_events" {
  name = "document-events-topic"
}

# 4. Cola SQS que procesará los mensajes en segundo plano
resource "aws_sqs_queue" "document_queue" {
  name = "document-processing-queue"
}

# 5. Suscripción del patrón Fan-Out: SNS -> SQS
resource "aws_sns_topic_subscription" "document_events_sqs_target" {
  topic_arn = aws_sns_topic.document_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.document_queue.arn
}

# 6. Política de SQS para permitir que el Tópico SNS le envíe mensajes
resource "aws_sqs_queue_policy" "document_queue_policy" {
  queue_url = aws_sqs_queue.document_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.document_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.document_events.arn}"
        }
      }
    }
  ]
}
POLICY
}
