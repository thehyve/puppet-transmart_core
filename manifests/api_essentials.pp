# Copyright 2017 The Hyve.
class transmart_core::api_essentials inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config
    include ::transmart_core::backend
}
