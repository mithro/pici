---
eth_local_mac_address: 00:25:90:22:c4:91
eth_local_address: 10.21.0.1
eth_local_netmask: 24

eth_uplink_mac_address: 00:25:90:22:c4:90
eth_uplink_static: true
eth_uplink_static_address: 76.227.131.147
eth_uplink_static_netmask: 26
eth_uplink_static_gateway: 76.227.131.254
eth_uplink_dns_server: 8.8.8.8

dhcp_range: 10.21.0.128,10.21.0.254,6h

firewall_internal_networks: [10.21.0.0/24]

pib_network: 10.21.0

user_name: videoteam

conference_name: pib
room_name: catwalk

common_name: mithis.com
subject_alt_names:
  - frontend.ps1.fpgas.mithis.com
  - backend.ps1.fpgas.mithis.com

streaming_frontend_aliases: []
streaming_frontend_hostname: ps1.fpgas.mithis.com
domain_name: "{{ streaming_frontend_hostname}}"

letsencrypt_account_email: carl@NextDayVideo.com

# ./mk_secrets.sh | xclip

# snmpget -v 3 -u  -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \

switch:
    # Netgear #2 GS728TPP mac: "b0:39:56:88:22:4c"

    # HP https://support.hpe.com/hpesc/public/docDisplay?docId=c02596727
    # pethMainPseOperStatus .1.3.6.1.2.1.105.1.3.1.1.3

    # James Netgear:
    # http://kbserver.netgear.com/products/FS728TPv2.asp
    # FS728TP v2
    mac: "A0:21:B7:AF:4E:05"
    oid: "iso.3.6.1.4.1.4526.11.16.1.1.1.3.1"
    host: "10.21.0.200"
    SNMP_SWITCH_SECURITY_LEVEL: authPriv
    SNMP_SWITCH_AUTH_PROTOCOL: MD5
    SNMP_SWITCH_PRIV_PROTOCOL: DES

    SNMP_SWITCH_USERNAME: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              64326163636566386633383736656135343562373937366666326462316236303039666433613462
              3230363839303063633234306531636638363566623136650a303933333339353838326562313336
              31663835303330323962313062623831323831303433323933373464643738336564306363363631
              3339643130656366300a343239333930633833356533386639666135303131363965656135323263
              3363
    SNMP_SWITCH_AUTHKEY: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              38646430373439656336636635383537313938663763353236346639643466316663353865646139
              3665366435363664616232383435633966306139623865350a346132646337613738643766366365
              39646139323934633564336563383035353034613964326262623536663832343736636337313239
              3737336135393731650a666237646365356137363432363436343539326436386532646661363635
              3333
    SNMP_SWITCH_PASSPHRASE: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              61373861623962386633616533613631356138633832393635313534353436323533623937623936
              6639376161393435333561333733373338353464393566340a393463373432623630626239353666
              61393365623032666431636136343931636333316566383939356433393938383462633438376564
              6266623235346239390a303034323864303034663862386231393638643161303665626137653635
              3338
    SNMP_SWITCH_PRIV_PASSPHRASE: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              63316434343764626238313336323435313361643738326139383965336132323235393731336564
              3536376534323561376234623030366139356533393536320a633631373361396135316337636331
              65356431643863623632376235316662643033653339646131313439323332333130656335373035
              6665303438336436390a613934633231366537616132613066346530323038663463393637666333
              3235

db_pw: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36353966616130653437666634363938666230363139653732373466623565333531303136646638
          3366666634663937333533316463633263333637633961390a653634323465383931376461376338
          32326563363838333030343130616331616366303635383737393462653630373233356334356330
          3836343765616433350a666130303037623739616166346434326536663763376239323233383161
          3064
pi_pw: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          63643961613838643366666430386538393732356662313464346435626561373532303963356166
          6466313262303364326131333630313239636561623237360a376432373831636539386262333230
          64383532313334616135323365363465323431656635396438303939363138303537396461386334
          3939353338653930370a623433633733333832616434343837666232616564346639666262643261
          6135


# pi things
nos:
    - { port:  2, mac: "b8:27:eb:2f:5d:08", sn: 042f5d08 }
    - { port:  3, mac: "dc:a6:32:05:32:45", sn: f1b7bb5a }
    - { port:  4, mac: "e4:5f:01:64:76:05", sn: "e897e1d3", cable_color: "blue" }
    - { port:  5, mac: "b8:27:eb:d4:f1:74", sn: 9ed4f174 }
    - { port:  7, mac: "b8:27:eb:33:51:27", sn: 48335127 }
    - { port:  9, mac: "b8:27:eb:a3:51:b4", sn: 8da351b4 }
    - { port: 11, mac: "b8:27:eb:51:01:df", sn: 265101df }
    - { port: 13, mac: "b8:27:eb:68:fc:e7", sn: f168fce7 }
    - { port: 19, mac: "b8:27:eb:69:79:a0", sn: 426979a0 }
    - { port: 21, mac: "b8:27:eb:5f:de:85", sn: 7d5fde85 }
    - { port: 23, mac: "b8:27:eb:0c:f8:43", sn: 9b0cf843 }
      # - { port: ?, mac: "b8:27:eb:5a:26:5b", sn: 035a265b }

