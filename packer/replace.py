import os
import json
import logging

logging.basicConfig(level=logging.DEBUG)
LOG = logging.getLogger('infra-as-code')
TEMPLATE = 'packer/template.tpl'


def read_file(template):
    try:
        LOG.info("loading packer file: %s", template)
        with open(template) as extension:
            data = extension.read()
            return json.loads(data)
    except:
        LOG.error("can not read template file %s", template)


def replace_packer(template):
    LOG.info('replacing %s', template)
    json_data = read_file(template)
    json_data['variables']['destination_regions'] = os.environ['AWS_DEFAULT_REGION']
    json_data['variables']['aws_vpc_id'] = os.environ['AWS_VPC_ID']
    json_data['variables']['aws_subnet_id'] = os.environ['AWS_SUBNET_ID']
    json_data['variables']['aws_access_key'] = os.environ['AWS_ACCESS_KEY_ID']
    json_data['variables']['aws_secret_key'] = os.environ['AWS_SECRET_ACCESS_KEY']
    json_data['variables']['ami_name'] = "{}".format(os.environ['AWS_LABEL'])

    LOG.info('writing packer/template.json')
    with open('packer/template.json', 'w') as file:
        json.dump(json_data, file, indent=2)


if __name__ == '__main__':
    replace_packer(TEMPLATE)
