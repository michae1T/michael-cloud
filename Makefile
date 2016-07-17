.PHONY: create-stack update-stack create-rds-stack update-rds-stack upload-scripts

CLOUDFORMATION_ARGS = --stack-name michael-origin --capabilities CAPABILITY_IAM --template-body file://origin-cf.template.json

create-stack:
	aws cloudformation create-stack $(CLOUDFORMATION_ARGS)

update-stack:
	aws cloudformation update-stack $(CLOUDFORMATION_ARGS)

RDS_TEMPLATE = rds-cf.template.temp.json
CLOUDFORMATION_RDS_ARGS = --stack-name rds-1 --capabilities CAPABILITY_IAM --template-body file://$(RDS_TEMPLATE)

create-rds-template:
	./rds-cf.sh ~/etc/private/contents/rds-1/rds-template-params.json > $(RDS_TEMPLATE)

create-rds-stack: create-rds-template
	aws cloudformation create-stack $(CLOUDFORMATION_RDS_ARGS)
	rm $(RDS_TEMPLATE)

update-rds-stack: create-rds-template
	aws cloudformation update-stack $(CLOUDFORMATION_RDS_ARGS)
	rm $(RDS_TEMPLATE)

CLOUDFORMATION_S3_ARGS = --stack-name s3 --capabilities CAPABILITY_IAM --template-body file://s3-cf.template.json

create-s3-stack:
	aws cloudformation create-stack $(CLOUDFORMATION_S3_ARGS)

update-s3-stack:
	aws cloudformation update-stack $(CLOUDFORMATION_S3_ARGS)

upload-scripts:
	aws s3 sync init-scripts s3://michael-init
