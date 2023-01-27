from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
from pprint import pprint

from snmp_switch.utils import snmp_set_state, snmp_status, snmp_toggle

@csrf_exempt
def toggle(request, extra_context={}):

    port = request.POST['port']

    context = {}
    context.update(extra_context)

    context.update(snmp_toggle(
        host=settings.SNMP_SWITCH_HOST,
        username=settings.SNMP_SWITCH_USERNAME,
        authkey=settings.SNMP_SWITCH_AUTHKEY,
        privkey=settings.SNMP_SWITCH_PRIVKEY,
        oid=settings.SNMP_SWITCH_OID,
        port=port))

    pprint(context)

    response = HttpResponse(content_type="application/json")
    d={'port': port, 'value': 1}
    json.dump(d, response, indent=2)

    return response

@csrf_exempt
def toggle_all(request):

    l = []
    for port in range(1,48):

        d = snmp_toggle(
            host=settings.SNMP_SWITCH_HOST,
            username=settings.SNMP_SWITCH_USERNAME,
            authkey=settings.SNMP_SWITCH_AUTHKEY,
            privkey=settings.SNMP_SWITCH_PRIVKEY,
            oid=settings.SNMP_SWITCH_OID,
            port=str(port))

        d={'port': port, 'value': 1}
        l.append(d)

    response = HttpResponse(content_type="application/json")
    json.dump(l, response, indent=2)

    return response

@csrf_exempt
def off_all(request):

    # 2=off
    state=2

    l = []
    for port in range(1,48):

        d = snmp_set_state(
            host=settings.SNMP_SWITCH_HOST,
            username=settings.SNMP_SWITCH_USERNAME,
            authkey=settings.SNMP_SWITCH_AUTHKEY,
            privkey=settings.SNMP_SWITCH_PRIVKEY,
            oid=settings.SNMP_SWITCH_OID,
            port=str(port),
            state=state)

        d={'port': port, 'value': state}
        l.append(d)

    response = HttpResponse(content_type="application/json")
    json.dump(l, response, indent=2)

    return response



@csrf_exempt
def status(request):

    port = request.POST['port']

    context = {}
    context.update(snmp_status(
        host=settings.SNMP_SWITCH_HOST,
        username=settings.SNMP_SWITCH_USERNAME,
        authkey=settings.SNMP_SWITCH_AUTHKEY,
        privkey=settings.SNMP_SWITCH_PRIVKEY,
        oid=settings.SNMP_SWITCH_OID,
        port=port))

    pprint(context)

    response = HttpResponse(content_type="application/json")
    d={     'port':port,
            'value': None,
            'context': context.__str__()
        }
    json.dump(d, response, indent=2)

    return response
