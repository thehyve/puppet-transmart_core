# Copyright 2017 The Hyve.
class transmart_core::essentials inherits transmart_core::params {
    include ::transmart_core
    include ::transmart_core::config
    include ::transmart_core::solr
    include ::transmart_core::rserve
    include ::transmart_core::backend
}
