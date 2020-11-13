################################################################

Initial auth information:
  Auth Method ID:     ampw_zWCRLBPuVA
  Auth Method Name:   Generated global scope initial auth method
  Login Name:         admin
  Password:           6FjPATqbt9foRVKI2R64
  Scope ID:           global
  User ID:            u_2BNWOwmEc7
  User Name:          admin

set BOUNDARY_ADDR=http://boundary.eu-guystack.original.aws.hashidemos.io:9200

boundary authenticate password -auth-method-id=ampw_zWCRLBPuVA -login-name=admin -password=6FjPATqbt9foRVKI2R64

boundary hosts update static -id hst_KfiCZpiszG -address server-2.eu-guystack.original.aws.hashidemos.io
​
boundary targets update tcp -id ttcp_c02tXMWb4m -default-port 8500 -session-connection-limit -1
​
#Consul
boundary connect -target-id=ttcp_DRSAcrd59o

#Vault
boundary connect -target-id=ttcp_6PNpxhaNpA

#SSH
boundary connect -target-id=ttcp_lFwmESY7nQ