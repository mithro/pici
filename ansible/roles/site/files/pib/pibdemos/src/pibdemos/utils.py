
import argparse

import paramiko

from pprint import pprint

# so we can send the browser a message when ...
# tangle up this code with the django-connect web socket code :(
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync


def notify_dcws(port,msg):

    pi_name=f"pi{port}"
    group = f"pistat_{pi_name}"
    message_type="stat.message"
    message_text=f"demo: {msg}"
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, {"type": message_type, "message": message_text} )


def run_on_pi(port,cmd):

    # port: rj45 port the pi is connected to
    # cmd: the shell command to run on the pi

    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.load_system_host_keys()
    o=100+port
    ip=f'10.21.0.{o}'
    client.connect(ip, username='pi')

    stdin, stdout, stderr = client.exec_command(cmd)

    ret={}
    ret['stdout']=list(stdout)
    ret['stderr']=list(stderr)

    for k in ret:
      for l in ret[k]:
        msg=f"{k}: {l}".strip()
        # send stdio to the web page
        # (I wish this happened somewhere else.
        # having it here makes this module hard to test.)
        notify_dcws(port,msg)

    return ret


def get_args():

    parser = argparse.ArgumentParser(
            description="PoE set and get")

    parser.add_argument('port',
            help='Which physical port on the switch.',
            type=int,
            )

    parser.add_argument('cmd',
            help='shell command to run on pi',
            )

    parser.add_argument('--site-path', '-p',
            default = "/srv/www/pib",
            help="DJANGO_SETTINGS_MODULE")

    parser.add_argument('--django-settings', '-s',
            default = "pib.settings",
            help="DJANGO_SETTINGS_MODULE")

    parser.add_argument('-v', '--verbose', action="store_true")

    args = parser.parse_args()

    return args


def test(port, cmd):
    ret = run_on_pi(port,cmd)
    pprint(ret)

def init_dcwc(site_path, django_settings_module):
    sys.path.insert(0, site_path)
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", django_settings_module)

def main():
    args = get_args()

    init_dcwc(args.site_path, args.django_settings)

    test(args.port,args.cmd)


if __name__=='__main__':
    main()
