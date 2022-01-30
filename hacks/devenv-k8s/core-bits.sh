set -x


#############################
# local ingress via dnsmasq #
##########################
# https://mjpitz.com/blog/2020/10/21/local-ingress-domains-kind

brew install dnsmasq

# The default configuration for dnsmasq on OSX can be found 
# at /usr/local/etc/dnsmasq.conf. To configure a local private domain, 
# add an address line to the end of the file. When choosing a domain, 
# I suggest avoiding .local and .dev top level domains (TLD). .local addresses 
# are reserved for multicast domains. Using one will result in DNS query leaks, 
# which may be problematic for organizations. .dev has historically been used by
# engineers, but recent browser changes now require TLS for communication. 

# I’ve recently taken to the non-existent .hack TLD.

# Append to --> /usr/local/etc/dnsmasq.conf
# address=/halcyondude.hack/127.0.0.1
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
dig @127.0.0.1 dorko.halcyondude.hack

# ᐅ dig @127.0.0.1 dorko.halcyondude.hack
#
# ; <<>> DiG 9.10.6 <<>> @127.0.0.1 dorko.halcyondude.hack
# ; (1 server found)
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36702
# ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 4096
# ;; QUESTION SECTION:
# ;dorko.halcyondude.hack.                IN      A

# ;; ANSWER SECTION:
# dorko.halcyondude.hack. 0       IN      A       127.0.0.1

# ;; Query time: 0 msec
# ;; SERVER: 127.0.0.1#53(127.0.0.1)
# ;; WHEN: Thu Jan 27 21:41:21 EST 2022
# ;; MSG SIZE  rcvd: 67


###
### Configure the resolver
###
sudo mkdir -p /etc/resolver
cat <<EOF | sudo tee /etc/resolver/halcyondude.hack
domain halcyondude.hack
search halcyondude.hack
nameserver 127.0.0.1
EOF

# restart mDNSResponder
sudo killall -HUP mDNSResponder

# confirm resolver is in place
scutil --dns

# ...
# resolver #8
#   domain   : halcyondude.hack
#   search domain[0] : halcyondude.hack
#   nameserver[0] : 127.0.0.1
#   flags    : Request A records, Request AAAA records
#   reach    : 0x00030002 (Reachable,Local Address,Directly Reachable Address)
# ...

#
# Create a Kind Cluster, and install CP to it.
#
# More Info --> https://kind.sigs.k8s.io/docs/user/configuration
#
kind create cluster --name chezmoi --config kind-multi-node.yaml

#########################
# install nginx ingress #
#########################

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f nginx-ingress-kindpatches.yaml

# wait until ingress is ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# deploy 2 services (foo, bar) that echo, and confirm it works
# kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
kubectl apply -f kind-nginx-usage-example.yaml

# assuming dnsmasq  is config'd to handle .hack TLD

# should output "foo"
curl foo.halcyondude.hack

# should output "bar"
curl bar.halcyondude.hack
### end nginx

######################
# install crossplane #
######################

kubectl create namespace crossplane-system

helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane

# install bifocals, so we can browse CRDs
# kubectl create namespace bifocals
# kubectl -n bifocals apply -f https://raw.githubusercontent.com/crdsdev/bifocals/master/deploy/manifests/install.yaml
# (hack) expose dashboard
# kubectl port-forward svc/bifocals -n bifocals 8080:80

