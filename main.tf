# terraform-coc-mypp-processed-cv
resource "google_storage_bucket" "terraform_coc_mypp_processed_cv" {
  name     = "terraform-coc-mypp-processed-cv"
  location = "eu"
  uniform_bucket_level_access = true

  public_access_prevention = "enforced"
}

# Run a script to get a list of files from the local directory
resource "null_resource" "scan_terraform_coc_mypp_processed_cv_files" {
  provisioner "local-exec" {
    command = "find source/Bucket-terraform-coc-mypp-processed-cv -type f -exec echo {} \\; > terraform_coc_mypp_processed_cv_files.txt"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Upload all the files to the storage bucket
resource "google_storage_bucket_object" "upload_terraform_coc_mypp_processed_cv_files" {
  for_each = toset([for file in split("\n", trimspace(file("terraform_coc_mypp_processed_cv_files.txt"))): file if length(file) > 0])

  name   = basename(each.value)
  bucket = google_storage_bucket.terraform_coc_mypp_processed_cv.name
  source = each.value
#   acl    = "private"
}







resource "google_storage_bucket" "terraform_coc_mypp_sap_integration" {
  name     = "terraform-coc-mypp-sap-integration"
  location = "eu"
  uniform_bucket_level_access = true

  public_access_prevention = "enforced"
}

# Run a script to get a list of files from the local directory
resource "null_resource" "scan_terraform_coc_mypp_sap_integration_files" {
  provisioner "local-exec" {
    command = "find source/Bucket-terraform-coc-mypp-sap-integration -type f -exec echo {} \\; > terraform_coc_mypp_sap_integration_files.txt"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Upload all the files to the storage bucket
resource "google_storage_bucket_object" "upload_terraform_coc_mypp_sap_integration_files" {
  for_each = toset([for file in split("\n", trimspace(file("terraform_coc_mypp_sap_integration_files.txt"))): file if length(file) > 0])

  name   = basename(each.value)
  bucket = google_storage_bucket.terraform_coc_mypp_sap_integration.name
  source = each.value
#   acl    = "private"
}

# terraform-CV_processing-job
resource "google_storage_bucket" "terraform_coc_medimrec_poc_bucket" {
  name     = "terraform-coc-medimrec-poc-bucket"
  location = "europe-southwest1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "terraform_coc_medimrec_poc_object" {
  name   = "index.zip"
  bucket = google_storage_bucket.terraform_coc_medimrec_poc_bucket.name
  source = "source/CV_processing-job/function-source.zip"
}

resource "google_cloudfunctions2_function" "terraform_coc_medimrec_poc_function" {
  name        = "terraform-CV_processing-job"
  location = "europe-southwest1"

  build_config {
    runtime = "python311"
    entry_point = "process_cv"  # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.terraform_coc_medimrec_poc_bucket.name
        object = google_storage_bucket_object.terraform_coc_medimrec_poc_object.name
      }
    }
  }

  service_config {
    max_instance_count  = 100
    available_memory    = "1Gi"
    timeout_seconds     = 360
    available_cpu       = "1.0"
  }

  event_trigger {
    trigger_region = "eu" # The trigger must be in the same location as the bucket
    event_type = "google.cloud.storage.object.v1.finalized"

    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.terraform_coc_mypp_sap_integration.name
    }
  }
}




# terraform-SAP-CV-integration
resource "google_storage_bucket_object" "terraform_sap_cv_integration_object" {
  name   = "index.zip"
  bucket = google_storage_bucket.terraform_coc_medimrec_poc_bucket.name
  source = "source/SAP-CV-integration/function-source.zip"
}

resource "google_cloudfunctions2_function" "terraform_sap_cv_integration_function" {
  name        = "terraform-SAP-CV-integration"
  location = "europe-southwest1"

  build_config {
    runtime = "python311"
    entry_point = "sap_integration"  # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.terraform_coc_medimrec_poc_bucket.name
        object = google_storage_bucket_object.terraform_sap_cv_integration_object.name
      }
    }


  }

  service_config {
    max_instance_count  = 100
    available_memory    = "256Mi"
    timeout_seconds     = 60
    available_cpu       = ".167"

    environment_variables = {
        API_URL = "https://atos-development-intergration-mhdx5ahs.it-cpi005-rt.cfapps.eu20.hana.ondemand.com/http/restapi/postCV"
        CLIENT_ID = "sb-fa7339af-c41d-4e21-9345-4fa171cbf7b9!b7500|it-rt-atos-development-intergration-mhdx5ahs!b259"
        CLIENT_SECRET = "913ede81-4177-48bf-8f48-3af1316cd6ea$p1rjlTzUVP9VqId4w0VgW6EIIJ13aytTNHSGHe00DDk="
    }
  }

  event_trigger {
    trigger_region = "eu" # The trigger must be in the same location as the bucket
    event_type = "google.cloud.storage.object.v1.finalized"

    retry_policy = "RETRY_POLICY_DO_NOT_RETRY"

    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.terraform_coc_mypp_processed_cv.name
    }
  }
}
