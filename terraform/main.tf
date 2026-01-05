resource "google_integrations_client" "fao_dr" {
  location = "europe-west1"
  project  = var.project_id
}

resource "google_integrations_integration_version" "send_email_notifications" {
  depends_on = [google_integrations_client.fao_dr]

  integration = "fao-dr-emails-service"
  location    = "europe-west1"
  project     = var.project_id

  integration_parameters {
    key               = "BODY"
    data_type         = "STRING_VALUE"
    display_name      = "BODY"
    input_output_type = "IN"
    default_value {
      string_value = ""
    }
  }

  integration_parameters {
    key               = "SUBJECT"
    data_type         = "STRING_VALUE"
    display_name      = "SUBJECT"
    input_output_type = "IN"
    default_value {
      string_value = ""
    }
  }

  integration_parameters {
    key               = "RECIPIENTS"
    data_type         = "STRING_ARRAY"
    display_name      = "RECIPIENTS"
    input_output_type = "IN"
  }

  trigger_configs {
    label          = "API Trigger"
    trigger_type   = "API"
    trigger_number = "1"
    trigger_id     = "api_trigger/fao-dr-emails-service_API_1"

    properties = {
      "Trigger name" = "fao-dr-emails-service_API_1"
    }

    start_tasks {
      task_id = "1"
    }
  }

  task_configs {
    task         = "EmailTask"
    task_id      = "1"
    display_name = "Send Email"

    parameters {
      key = "TextBody"
      value {
        string_value = "$BODY$"
      }
    }

    parameters {
      key = "To"
      value {
        string_value = "$RECIPIENTS$"
      }
    }

    parameters {
      key = "Subject"
      value {
        string_value = "$SUBJECT$"
      }
    }

    parameters {
      key = "BodyFormat"
      value {
        string_value = "text"
      }
    }

    parameters {
      key = "ThrowNoRequiredInputException"
      value {
        boolean_value = true
      }
    }

    # Empty parameters as seen in the retrieval
    parameters {
      key = "Cc"
      value {
        string_array {}
      }
    }
    parameters {
      key = "Bcc"
      value {
        string_array {}
      }
    }
    parameters {
      key = "AttachmentPath"
      value {
        string_array {}
      }
    }

    parameters {
      key = "EmailConfigInput"
      value {
        json_value = jsonencode({
          "@type" = "type.googleapis.com/enterprise.crm.eventbus.proto.EmailConfig"
        })
      }
    }
  }
}
