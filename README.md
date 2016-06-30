# conodo

### Consul + Nomad + docker

Creates VMs with a Consul server(s), Nomad server(s) and (per default) 3 clients with docker containers.
## Consul Server
````
vagrant ssh consul
$ consul members
Node     Address            Status  Type    Build  Protocol  DC
client1  192.168.0.31:8301  alive   client  0.6.4  2         dc1
client2  192.168.0.32:8301  alive   client  0.6.4  2         dc1
client3  192.168.0.33:8301  alive   client  0.6.4  2         dc1
consul   192.168.0.21:8301  alive   server  0.6.4  2         dc1
nomad    192.168.0.11:8301  alive   client  0.6.4  2         dc1
````
## Nomad Server
````
vagrant ssh nomad
$ consul members
Node     Address            Status  Type    Build  Protocol  DC
client1  192.168.0.31:8301  alive   client  0.6.4  2         dc1
client2  192.168.0.32:8301  alive   client  0.6.4  2         dc1
client3  192.168.0.33:8301  alive   client  0.6.4  2         dc1
consul   192.168.0.21:8301  alive   server  0.6.4  2         dc1
nomad    192.168.0.11:8301  alive   client  0.6.4  2         dc1

$ nomad server-members
Name          Address       Port  Status  Leader  Protocol  Build  Datacenter  Region
nomad.global  192.168.0.11  4648  alive   true    2         0.3.2  dc1         global

$ nomad node-status
ID        DC   Name     Class   Drain  Status
9a993676  dc1  client3  <none>  false  ready
7b776860  dc1  client2  <none>  false  ready
49d3ebfe  dc1  client1  <none>  false  ready
````
## Clients
````
vagrant ssh clientN
$ consul members
Node     Address            Status  Type    Build  Protocol  DC
client1  192.168.0.31:8301  alive   client  0.6.4  2         dc1
client2  192.168.0.32:8301  alive   client  0.6.4  2         dc1
client3  192.168.0.33:8301  alive   client  0.6.4  2         dc1
consul   192.168.0.21:8301  alive   server  0.6.4  2         dc1
nomad    192.168.0.11:8301  alive   client  0.6.4  2         dc1

$ nomad node-status
ID        DC   Name     Class   Drain  Status
9a993676  dc1  client3  <none>  false  ready
7b776860  dc1  client2  <none>  false  ready
49d3ebfe  dc1  client1  <none>  false  ready
````
## WebUI
http://192.168.0.21:8500

## Running Nomad jobs
````
vagrant ssh nomad
$ nomad init
Example job file written to example.nomad

$ nomad run example.nomad
==> Monitoring evaluation "5e826cb7"
    Evaluation triggered by job "example"
    Allocation "070cb7b0" created: node "49d3ebfe", group "cache"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "5e826cb7" finished with status "complete"

$ nomad status
ID       Type     Priority  Status
example  service  50        running
vagrant@nomad:~$ nomad status example
ID          = example
Name        = example
Type        = service
Priority    = 50
Datacenters = dc1
Status      = running
Periodic    = false

==> Evaluations
ID        Priority  Triggered By  Status
5e826cb7  50        job-register  complete

==> Allocations
ID        Eval ID   Node ID   Task Group  Desired  Status
070cb7b0  5e826cb7  49d3ebfe  cache       run      running
````
Stop the job, increase the number of jobs to 3 (count = 3 in _example.nomad_) and run the job again.
Play with stopping the clients, restarting them, killing the VMs, etc. Enjoy responsibly! ;)
````
$ nomad stop example
==> Monitoring evaluation "ece3ae01"
    Evaluation triggered by job "example"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "ece3ae01" finished with status "complete"

$ sed -i 's/# count = 1/count = 3/g' example.nomad
$ nomad run example.nomad
...
````
