# 
# An example of a manifest file which creates the transmart and tsloader system users
# and loads transmart-data and transmart-batch into tsloader's home directory.
# Services are not installed.
#

include ::transmart_core
include ::transmart_core::data
include ::transmart_core::batch

