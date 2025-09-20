#/bin/bash

################################################################################
# Downloads from CDC
wget --no-check-certificate\
  -m -np\
  https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD9-CM/

################################################################################
# Downloads from CMS
mkdir -p cms
wget --no-check-certificate\
  -O cms/cms_v32.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/icd-9-cm-v32-master-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_v31.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/cmsv31-master-descriptions.zip

wget --no-check-certificate\
  -O cms/cms_v30.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/cmsv30_master_descriptions.zip

wget --no-check-certificate\
  -O cms/cms_v29.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/cmsv29_master_descriptions.zip

wget --no-check-certificate\
  -O cms/cms_v28.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/cmsv28_master_descriptions.zip

wget --no-check-certificate\
  -O cms/cms_fy2010.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/fy2010diagnosis-procedurecodesfulltitles.zip

wget --no-check-certificate\
  -O cms/cms_v27.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/v27_icd9.zip

wget --no-check-certificate\
  -O cms/cms_v26.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/v26_icd9.zip

wget --no-check-certificate\
  -O cms/cms_v25.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/v25_icd9.zip

wget --no-check-certificate\
  -O cms/cms_v24.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/v24_icd9.zip

wget --no-check-certificate\
  -O cms/cms_v23.zip\
  https://www.cms.gov/medicare/coding/icd9providerdiagnosticcodes/downloads/v23_icd9.zip

################################################################################
#                                 End of File                                  #
################################################################################
