export AWS_DEFAULT_REGION = us-east-1
AWS_PROFILE ?= callowayart
STACK ?= callowayart
INGRESS ?= 0.0.0.0/0
KEYNAME ?= callowayart.web
KEYPATH ?= ./rsa
AZ := $(AWS_DEFAULT_REGION)a
TEMPLATEPATH := ./templates/stack.yml


.PHONY: all orchestrate
all:
	rm -rf ./build && mkdir ./build

test:
	@ aws cloudformation validate-template \
			--template-body file://$(TEMPLATEPATH)

orchestrate:
	@ aws cloudformation create-stack \
			--stack-name $(STACK) \
			--template-body file://$(TEMPLATEPATH) \
			--capabilities CAPABILITY_NAMED_IAM \
			--parameters ParameterKey=AvailabilityZone,ParameterValue=$(AZ) \
					ParameterKey=AdminIngressLocation,ParameterValue=$(INGRESS) \
					ParameterKey=KeyName,ParameterValue=$(KEYNAME)

get-config:
	@ aws cloudformation describe-stacks \
			--query 'Stacks[*].Outputs[?OutputKey == `GetKubeConfigCommand`].OutputValue' \
			--output text --stack-name $(STACK) \
				| sed -e 's#path/to/.*pem#$(KEYPATH)#g' \
				> ./build/get-config.sh
		chmod +x ./build/get-config.sh
		./build/get-config.sh

