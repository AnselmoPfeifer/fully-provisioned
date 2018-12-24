import logging
import sys
import json
import os

logging.basicConfig(level=logging.DEBUG)
LOG = logging.getLogger('infra-as-code')
FILE = "{}".format(sys.argv[1])

def read_terraform_output():
    try:
        LOG.info('loading terraform output')
        with open('output.json') as output:
            data = output.read()
            return json.loads(data)
    except:
        LOG.error("can not read terraform output")


def set_external_address():
    try:
        LOG.info("setting external address!")
        data = read_terraform_output()

        nginx_addr = data['instances']['value']['app-server'][1]
        master_addr = data['instances']['value']['database-master'][1]
        slave_addr = data['instances']['value']['database-slave'][1]

        os.environ['NGINX_EXTERNAL_IP'] = nginx_addr
        os.environ['MASTER_EXTERNAL_IP'] = master_addr
        os.environ['SLAVE_EXTERNAL_IP'] = slave_addr
    except:
        LOG.error("can not set the external address!")


def read_file():
    tpl = "{}.tpl".format(FILE)
    try:
        LOG.info('loading node template: %s', tpl)
        with open(tpl) as template:
            data = template.read()
            return json.loads(data)
    except:
        LOG.error('can not read template file!')


def replace_template_nginx():
    tpl = "{}.tpl".format(FILE)
    set_external_address()
    LOG.info('replacing %s', tpl)
    data = read_file()
    data['nginx']['ip_address'] = os.environ['NGINX_EXTERNAL_IP']


def write_node_json():
    json_file = "{}.json".format(FILE)
    data = replace_template_nginx()
    with open(json_file, 'w') as json_file:
        json.dump(data, json_file, indent=2)


if __name__ == '__main__':
    write_node_json()