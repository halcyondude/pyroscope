# https://yourThing.pyroscope.hack for fun and profit

aka: "How to set up local (fake) Top Level Domain (TLD) via dnsmasq."

this := enable fake TLD(s) w/ dnsmasq.

## Who this helps

The Pyroscope project's contributors and user community.

## Why this helps

Working with a local k8s cluster (kind, k3d, ...) for local iterative development environments invariably involves [Ingress]. When configuration (e.g. Ingress paths vs. hosts/domains) drifts, frustratingly complex nonsense can rapidly kill productivity.

[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress

## How this helps

Enable a TLD to be resolved locally, enabling using https w/ self-signed certs that match.  Since `.hack` is not one of the [TDL's starting with h](https://en.wikipedia.org/wiki/List_of_Internet_top-level_domains#H), we shall set up `*.pyroscope.hack` for our own use.

This guide assumes macos/ubuntu. Windows/WSL2, while awesome, does not work OOTB w/ dnsmasq. There are some additional wrinkles to handle which are outside the scope of this document.

This idea and steps come from: https://mjpitz.com/blog/2020/10/21/local-ingress-domains-kind

## Let's go!

First, install dnsmasq via brew

```bash
brew install dnsmasq

```
# Append to --> /usr/local/etc/dnsmasq.conf
# address=/pyroscope.hack/127.0.0.1
# server=8.8.8.8
# server=8.8.4.4

# restart dnsmasq
sudo brew services restart dnsmasq

# (⎈ |kind-pyroscope:pyroscope)~/gh/halcyondude/pyroscope/docs/coldstart-macos (my-coldstart-macos ✘)✹✚✭ ᐅ sudo brew services restart dnsmasq
# Warning: Taking root:admin ownership of some dnsmasq paths:
#   /usr/local/Cellar/dnsmasq/2.86/sbin
#   /usr/local/Cellar/dnsmasq/2.86/sbin/dnsmasq
#   /usr/local/opt/dnsmasq
#   /usr/local/opt/dnsmasq/sbin
#   /usr/local/var/homebrew/linked/dnsmasq
# This will require manual removal of these paths using `sudo rm` on
# brew upgrade/reinstall/uninstall.
# ==> Successfully started `dnsmasq` (label: homebrew.mxcl.dnsmasq)

# verify
dig @127.0.0.1 dorko.pyroscope.hack

# ᐅ dig @127.0.0.1 dorko.pyroscope.hack
#
# ; <<>> DiG 9.10.6 <<>> @127.0.0.1 dorko.pyroscope.hack
# ; (1 server found)
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36702
# ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 4096
# ;; QUESTION SECTION:
# ;dorko.pyroscope.hack.                IN      A

# ;; ANSWER SECTION:
# dorko.pyroscope.hack. 0       IN      A       127.0.0.1

# ;; Query time: 0 msec
# ;; SERVER: 127.0.0.1#53(127.0.0.1)
# ;; WHEN: Thu Jan 27 21:41:21 EST 2022
# ;; MSG SIZE  rcvd: 67


###
### Configure the resolver
###
sudo mkdir -p /etc/resolver
cat <<EOF | sudo tee /etc/resolver/pyroscope.hack
domain pyroscope.hack
search pyroscope.hack
nameserver 127.0.0.1
EOF

# restart mDNSResponder
sudo killall -HUP mDNSResponder

# confirm resolver is in place
scutil --dns

# ...
# resolver #8
#   domain   : pyroscope.hack
#   search domain[0] : pyroscope.hack
#   nameserver[0] : 127.0.0.1
#   flags    : Request A records, Request AAAA records
#   reach    : 0x00030002 (Reachable,Local Address,Directly Reachable Address)
# ...

