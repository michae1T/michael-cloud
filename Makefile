.PHONY: create-stack update-stack upload-scripts

CLOUDFORMATION_ARGS = --stack-name michael-origin --capabilities CAPABILITY_IAM --template-body file://origin-cf.template.json

create-stack:
	aws cloudformation create-stack $(CLOUDFORMATION_ARGS)

update-stack:
	aws cloudformation update-stack $(CLOUDFORMATION_ARGS)

upload-scripts:
	aws s3 sync init-scripts s3://michael-init
