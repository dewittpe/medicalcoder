#/bin/bash

################################################################################
# CDC Downloads
wget --no-check-certificate\
  -m -np\
  https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10/

wget --no-check-certificate\
  -m -np\
  https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/

################################################################################
# Downloads from CMS
#
# see https://www.cms.gov/medicare/coding-billing/icd-10-codes
# (last accessed 29 July 2025) for links
#
mkdir -p cms

# FY 2026
wget --no-check-certificate\
  -O cms/cms_2026_pr.zip\
  https://www.cms.gov/files/zip/2026-icd-10-pcs-order-file-long-and-abbreviated-titles.zip

wget --no-check-certificate\
  -O cms/cms_2026_dx.zip\
  https://www.cms.gov/files/zip/2026-code-descriptions-tabular-order.zip

# FY 2025
wget --no-check-certificate\
  -O cms/cms_2025_pr.zip\
  https://www.cms.gov/files/zip/2025-icd-10-pcs-order-file-long-and-abbreviated-titles.zip

wget --no-check-certificate\
  -O cms/cms_2025_dx.zip\
  https://www.cms.gov/files/zip/2025-code-descriptions-tabular-order.zip

# FY 2024
wget --no-check-certificate\
  -O cms/cms_2024_dx.zip\
  https://www.cms.gov/files/zip/2024-code-descriptions-tabular-order-updated-02/01/2024.zip

wget --no-check-certificate\
  -O cms/cms_2024_pr.zip\
  https://www.cms.gov/files/zip/2024-icd-10-pcs-order-file-long-and-abbreviated-titles-updated-12/19/2023.zip

# FY 2023
wget --no-check-certificate\
  -O cms/cms_2023_dx.zip\
  https://www.cms.gov/files/zip/2023-code-descriptions-tabular-order-updated-01/11/2023.zip

wget --no-check-certificate\
  -O cms/cms_2023_pr.zip\
  https://www.cms.gov/files/zip/2023-icd-10-pcs-order-file-long-and-abbreviated-titles-updated-01/11/2023.zip

# FY 2022
wget --no-check-certificate\
  -O cms/cms_2022_dx.zip\
  https://www.cms.gov/files/zip/2022-code-descriptions-tabular-order-updated-02012022.zip

wget --no-check-certificate\
  -O cms/cms_2022_pr.zip\
  https://www.cms.gov/files/zip/2022-icd-10-pcs-order-file-long-and-abbreviated-titles-updated-december-1-2021.zip

wget --no-check-certificate\
  -O cms/cms_2022_errata.zip\
  https://www.cms.gov/files/zip/errata-january-12-2022.zip

# FY 2021
wget --no-check-certificate\
  -O cms/cms_2021_dx.zip\
  https://www.cms.gov/files/zip/2021-code-descriptions-tabular-order-updated-12162020.zip

wget --no-check-certificate\
  -O cms/cms_2021_pr.zip\
  https://www.cms.gov/files/zip/2021-icd-10-pcs-order-file-long-and-abbreviated-titles-updated-december-1-2020.zip

# FY 2020
wget --no-check-certificate\
  -O cms/cms_2020_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2020-icd-10-cm-codes.zip

wget --no-check-certificate\
  -O cms/cms_2020_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2020-icd-10-pcs-order.zip

# FY 2019
wget --no-check-certificate\
  -O cms/cms_2019_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2019-icd-10-cm-code-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_2019_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2019-icd-10-pcs-order-file.zip

# FY 2018
wget --no-check-certificate\
  -O cms/cms_2018_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2018-icd-10-code-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_2018_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2018-icd-10-pcs-order-file.zip

# FY 2017
wget --no-check-certificate\
  -O cms/cms_2017_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2017-icd10-code-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_2017_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2017-pcs-long-abbrev-titles.zip

# FY 2016
wget --no-check-certificate\
  -O cms/cms_2016_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2016-code-descriptions-in-tabular-order.zip

wget --no-check-certificate\
  -O cms/cms_2016_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2016-pcs-long-abbrev-titles.zip

# FY 2015
wget --no-check-certificate\
  -O cms/cms_2015_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2015-code-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_2015_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2015-pcs-long-and-abbreviated-titles.zip

# FY 2014
wget --no-check-certificate\
  -O cms/cms_2014_dx.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2014-icd10-code-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_2014_pr.zip\
  https://www.cms.gov/medicare/coding/icd10/downloads/2014-pcs-long-and-abbreviated-titles.zip

################################################################################
#                                 End of File                                  #
################################################################################
