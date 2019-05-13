REGION=eu-west-1
NAME=batch-android-build
CONTAINER_WORK_DIR=/workspace
KMS=arn:aws:kms:eu-west-1:438591499564:key/025471da-37d7-4127-aae7-02cf06f69cf4

gituser := $(shell git config --global user.name)
gitbranch := $(shell git branch | grep \* | cut -d ' ' -f2)
gitrepo := $(shell basename `git config --get remote.origin.url`)
ts := $(shell /bin/date "+%Y-%m-%d-%H-%M-%S")
.create:
	@echo "Stack does not exists, create it."
	aws cloudformation create-stack --stack-name $(STACK_NAME) \
		--template-body $(TEMPLATE_BODY) \
		--region $(REGION) --capabilities CAPABILITY_NAMED_IAM \
		--enable-termination-protection --output text \
		--parameters $(PARAMETERS) && \
	aws cloudformation wait stack-create-complete --stack-name $(NAME)-vpc

.change:
	@echo "Stack exists, update it."
	@aws cloudformation create-change-set --stack-name $(STACK_NAME) \
		--template-body $(TEMPLATE_BODY) \
		--region $(REGION) --capabilities CAPABILITY_NAMED_IAM \
		--parameters $(PARAMETERS) \
		--change-set-name Update-$(ts) && \
	aws cloudformation wait change-set-create-complete --change-set-name Update-$(ts) \
		--stack-name $(STACK_NAME) --region $(REGION) && \
	aws cloudformation describe-change-set --change-set-name Update-$(ts) \
		--stack-name $(STACK_NAME) --region $(REGION)
	@echo "Do you want to apply the changes? [y/N] "
	@read answer; \
	[[ $$answer == y* ]] && \
		aws cloudformation execute-change-set --change-set-name Update-$(ts) --stack-name $(STACK_NAME) --region $(REGION) || \
		aws cloudformation delete-change-set --change-set-name Update-$(ts) --stack-name $(STACK_NAME) --region $(REGION)

network:
	@aws cloudformation describe-stacks --stack-name $(NAME)-vpc --region $(REGION) && \
	make .change \
		STACK_NAME=$(NAME)-vpc \
		TEMPLATE_BODY=file://cloudformation/amazon_vpc/vpc_template_cfn.yml \
		PARAMETERS='ParameterKey=Project,ParameterValue=$(NAME)' || \
	make .create \
		STACK_NAME=$(NAME)-vpc \
		TEMPLATE_BODY=file://cloudformation/amazon_vpc/vpc_template_cfn.yml \
		PARAMETERS='ParameterKey=Project,ParameterValue=$(NAME)';

pipeline:
	aws cloudformation describe-stacks --stack-name $(NAME)-pipeline --region $(REGION) && \
	make .change \
		STACK_NAME=$(NAME)-pipeline \
		TEMPLATE_BODY=file://cloudformation/aws_codepipeline/code_template_cfn.yml \
		PARAMETERS='ParameterKey=VpcStackName,ParameterValue=$(NAME)-vpc ParameterKey=Project,ParameterValue=$(NAME) ParameterKey=GitHubUser,ParameterValue=$(gituser) ParameterKey=GitHubBranch,ParameterValue=$(gitbranch) ParameterKey=GitHubRepo,ParameterValue=$(gitrepo) ParameterKey=GitHubToken,ParameterValue=$(TOKEN)' || \
	make .create \
		STACK_NAME=$(NAME)-pipeline \
		TEMPLATE_BODY=file://cloudformation/aws_codepipeline/code_template_cfn.yml \
		PARAMETERS='ParameterKey=VpcStackName,ParameterValue=$(NAME)-vpc ParameterKey=Project,ParameterValue=$(NAME) ParameterKey=GitHubUser,ParameterValue=$(gituser) ParameterKey=GitHubBranch,ParameterValue=$(gitbranch) ParameterKey=GitHubRepo,ParameterValue=$(gitrepo) ParameterKey=GitHubToken,ParameterValue=$(TOKEN)';

buildenv:
	aws cloudformation describe-stacks --stack-name $(NAME) --region $(REGION) && \
	make .change \
		STACK_NAME=$(NAME) \
		TEMPLATE_BODY=file://cloudformation/aws_batch/batch_template_cfn.yml \
		PARAMETERS='ParameterKey=Project,ParameterValue=$(NAME) ParameterKey=VpcStackName,ParameterValue=$(NAME)-vpc ParameterKey=KmsKeyArn,ParameterValue=$(KMS) ParameterKey=ImageName,ParameterValue=$(NAME)-ecr ParameterKey=ImageTag,ParameterValue=$(IMAGETAG)' || \
	make .create \
		STACK_NAME=$(NAME) \
		TEMPLATE_BODY=file://cloudformation/aws_batch/batch_template_cfn.yml \
		PARAMETERS='ParameterKey=Project,ParameterValue=$(NAME) ParameterKey=VpcStackName,ParameterValue=$(NAME)-vpc ParameterKey=KmsKeyArn,ParameterValue=$(KMS) ParameterKey=ImageName,ParameterValue=$(NAME)-ecr ParameterKey=ImageTag,ParameterValue=$(IMAGETAG)';

