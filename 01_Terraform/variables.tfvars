# Azure Provider Variables

################################################################
# Variablen für das Azure-Tenant definieren
# Hier muss die Azure-Tenant angepasst werden
azure_tenant_id = "23b4    -da63-4fea-95eb-97b44c78147 "

# Variablen für das Azure-Abonnement (Subscription) definieren
# Hier muss die Azure-Abonnement (Subscription) angepasst werden
azure_subscription_id = "86   f52-b127-4e63-8ed9-5f7b6cae28d "

# Hier muss die Azure-Client ID angepasst werden
azure_client_id = "db861f92-8de5-417f-ac9c-8e50c79dc5af"

# Hier muss die Azure-Client Secret angepasst werden
# azure_client_secret = "7 V8Q~dq BMlBP9wc4Qud1P9TZfbPFOj49TQ1dq "
################################################################

## Standort wo Infrastruktur bereitgestellt wird ##
azure_tenant_location = "West Europe"

## Zugangsdaten - Authentifizierungsinformationen ##
windows_user = "adminuser"
windows_password = "Password12345!"
ansible_user = "ansibleuser"
ansible_password = "Passwordansible1!"


## Name der Server ##
azure_dc_server01 = "DC01"
azure_pki_server01 = "PKI01"
azure_web_server01 = "Web01"
azure_file_server01 = "File01"
azure_rds_server01 = "RDS01"
azure_ansible-controller = "ansible-controller"