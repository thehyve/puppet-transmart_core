#
# An example of a manifest file which fetches installs:
# - transmart-api-server
# - transmart-data (the database provisioning repository)
# - postgresql
# - transmart-batch
#

include ::transmart_core::database
include ::transmart_core::api_essentials
include ::transmart_core::data
include ::transmart_core::batch
