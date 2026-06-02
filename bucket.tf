resource "yandex_storage_bucket" "staticfiles" {
  bucket     = "smartmeeting-static"
  access_key = yandex_iam_service_account_static_access_key.sa_staticfiles_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_staticfiles_key.secret_key
  force_destroy = true
  default_storage_class   = "STANDARD"
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
  max_size                = 214748365
}
