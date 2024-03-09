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

# basic setup
#
.PHONY: af-create
af-create:
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


.PHONY: af-publish
af-publish:
	cd httpExample && \
	func \
		azure \
		functionapp \
		publish pm-playground1

.PHONY: af-test
af-test:
	curl https://pm-playground1.azurewebsites.net/api/HttpExample?name=Functions -v

# container
#
.PHONY: afc-create
afc-create:
	az \
		functionapp \
		create \
		--name <APP_NAME> \
		--storage-account <STORAGE_NAME> \
		--resource-group AzureFunctionsContainers-rg \
		--plan myPremiumPlan \
		--image <LOGIN_SERVER>/azurefunctionsimage:v1.0.0 \
		--registry-username <USERNAME> \
		--registry-password <SECURE_PASSWORD>

.PHONY: afc-setup
afc-setup:
	az \
		storage \
		account \
		show-connection-string \
		--resource-group AzureFunctionsContainers-rg \
		--name <STORAGE_NAME> \
		--query connectionString \
		--output tsv
	az \
		functionapp \
		config \
		appsettings \
		set \
		--name <APP_NAME> \
		--resource-group AzureFunctionsContainers-rg \
		--settings AzureWebJobsStorage=<CONNECTION_STRING>

# Azure Container Apps
#
.phony: aca-deploy
aca-deploy:
	az \
		deployment \
		group \
		create \
		--resource-group test1 --template-file exampleACA/bicep/main.bicep \
		--parameters acrName=packetapmtest1 acaName=pmtest1


.phony: aca-build-local
aca-build-local:
	docker \
		build \
		--tag packetapmtest1.azurecr.io/azure-functions-aca-example1:latest \
		--platform linux/amd64 \
		exampleACA/.

.phony: aca-push-to-acr
aca-push-to-acr:
	az \
		acr \
		login \
		-n packetapmtest1.azurecr.io
	docker \
		push \
		packetapmtest1.azurecr.io/azure-functions-aca-example1:latest 

.phony: aca-run-local
aca-run-local:
	docker \
		run \
		-p 8080:80 \
		-it \
		--rm \
		azure-functions-aca-example1:v1.0.0
