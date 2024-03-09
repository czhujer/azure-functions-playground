.PHONY: set-su
set-su:
	az account set --name IAM-APIM-Workshop-Playground

.PHONY: create-rg
create-rg:
	az \
		storage \
		account \
		create \
		--name pm0functions0playground1 --location westeurope --resource-group test1 --sku Standard_LRS --allow-blob-public-access false

.PHONY: create-af
create-af:
	az \
		functionapp \
		create \
		--resource-group test1 \
		--consumption-plan-location westeurope \
		--runtime node \
		--runtime-version 20 \
		--functions-version 4 \
		--name pm-playground1 \
		--storage-account pm0functions0playground1 


.PHONY: afp
afp:
	func \
	azure \
	functionapp \
	publish pm-playground1

.PHONY: test1
test1:
	curl https://pm-playground1.azurewebsites.net/api/HttpExample?name=Functions -v
