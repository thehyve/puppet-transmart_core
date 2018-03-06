# Copyright 2017 The Hyve.
class transmart_core::complete inherits transmart_core::params {
    include ::transmart_core::thehyve_repositories
    include ::transmart_core::essentials
    include ::transmart_core::data
    include ::transmart_core::batch
}
