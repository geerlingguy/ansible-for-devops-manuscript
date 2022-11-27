# Chapter 9 - Ansible Cookbooks

Until now, most of this book has demonstrated individual aspects of Ansible---inventory, playbooks, ad-hoc tasks, etc. But this chapter synthesizes everything we've gone over in the previous chapters and shows how Ansible is applied to real-world infrastructure management scenarios.

## Highly-Available Infrastructure with Ansible

Real-world web applications require redundancy and horizontal scalability with multi-server infrastructure. In the following example, we'll use Ansible to configure a complex infrastructure on servers provisioned either locally (via Vagrant and VirtualBox) or on a set of automatically-provisioned instances (running on either DigitalOcean or Amazon Web Services):

{width=60%}
![Highly-Available Infrastructure.](images/9-highly-available-infrastructure.png)

**Varnish** acts as a load balancer and reverse proxy, fronting web requests and routing them to the application servers. We could just as easily use something like **Nginx** or **HAProxy**, or even a proprietary cloud-based solution like an Amazon's **Elastic Load Balancer** or Linode's **NodeBalancer**, but for simplicity's sake and for flexibility in deployment, we'll use Varnish.

**Apache** and mod_php run a PHP-based application that displays the entire stack's current status and outputs the current server's IP address for load balancing verification.

A **Memcached** server provides a caching layer that can be used to store and retrieve frequently-accessed objects in lieu of slower database storage.

Two **MySQL** servers, configured as a master and slave, offer redundant and performant database access; all data will be replicated from the master to the slave, and in addition, the slave can be used as a secondary server for read-only queries to take some load off the master.

### Directory Structure

In order to keep our configuration organized, we'll use the following structure for our playbooks and configuration:

{lang="text",linenos=off}
```
lamp-infrastructure/
  inventories/
  playbooks/
    db/
    memcached/
    varnish/
    www/
  provisioners/
  configure.yml
  provision.yml
  requirements.yml
  Vagrantfile
```

Organizing things this way allows us to focus on each server configuration individually, then build playbooks for provisioning and configuring instances on different hosting providers later. This organization also keeps server playbooks completely independent, so we can modularize and reuse individual server configurations.

### Individual Server Playbooks

Let's start building our individual server playbooks (in the `playbooks` directory). To make our playbooks more efficient, we'll use some contributed Ansible roles on Ansible Galaxy rather than install and configure everything step-by-step. We're going to target CentOS 7 servers in these playbooks, but only minimal changes would be required to use the playbooks with Ubuntu, Debian, or later versions of CentOS.

**Varnish**

Create a `main.yml` file within the `playbooks/varnish` directory, with the following contents:

{lang="yaml"}
```
---
- hosts: lamp_varnish
  become: yes

  vars_files:
    - vars.yml

  roles:
    - geerlingguy.firewall
    - geerlingguy.repo-epel
    - geerlingguy.varnish

  tasks:
    - name: Copy Varnish default.vcl.
      template:
        src: "templates/default.vcl.j2"
        dest: "/etc/varnish/default.vcl"
      notify: restart varnish
```

We're going to run this playbook on all hosts in the `lamp_varnish` inventory group (we'll create this later), and we'll run a few simple roles to configure the server:

  - `geerlingguy.firewall` configures a simple iptables-based firewall using a couple variables defined in `vars.yml`.
  - `geerlingguy.repo-epel` adds the EPEL repository (a prerequisite for varnish).
  - `geerlingguy.varnish` installs and configures Varnish.

Finally, a task copies over a custom `default.vcl` that configures Varnish, telling it where to find our web servers and how to load balance requests between the servers.

Let's create the two files referenced in the above playbook. First, `vars.yml`, in the same directory as `main.yml`:

{lang="yaml"}
```
---
firewall_allowed_tcp_ports:
  - "22"
  - "80"

varnish_use_default_vcl: false
```

The first variable tells the `geerlingguy.firewall` role to open TCP ports 22 and 80 for incoming traffic. The second variable tells the `geerlingguy.varnish` we will supply a custom `default.vcl` for Varnish configuration.

Create a `templates` directory inside the `playbooks/varnish` directory, and inside, create a `default.vcl.j2` file. This file will use Jinja syntax to build Varnish's custom `default.vcl` file:

{lang="text"}
```
vcl 4.0;

import directors;

{% for host in groups['lamp_www'] %}
backend www{{ loop.index }} {
  .host = "{{ host }}";
  .port = "80";
}
{% endfor %}

sub vcl_init {
  new vdir = directors.random();
{% for host in groups['lamp_www'] %}
  vdir.add_backend(www{{ loop.index }}, 1);
{% endfor %}
}

sub vcl_recv {
  set req.backend_hint = vdir.backend();

  # For testing ONLY; makes sure load balancing is working correctly.
  return (pass);
}
```

We won't study Varnish's VCL syntax in depth but we'll run through `default.vcl` and highlight what is being configured:

  1. (1-3) Indicate that we're using the 4.0 version of the VCL syntax and import the `directors` varnish module (which is used to configure load balancing).
  2. (5-10) Define each web server as a new backend; give a host and a port through which varnish can contact each host.
  3. (12-17) `vcl_init` is called when Varnish boots and initializes any required varnish modules. In this case, we're configuring a load balancer `vdir`, and adding each of the `www[#]` backends we defined earlier as backends to which the load balancer will distribute requests. We use a `random` director so we can easily demonstrate Varnish's ability to distribute requests to both app backends, but other load balancing strategies are also available.
  4. (19-24) `vcl_recv` is called for each request, and routes the request through Varnish. In this case, we route the request to the `vdir` backend defined in `vcl_init`, and indicate that Varnish should *not* cache the result.

According to #4, we're actually *bypassing Varnish's caching layer*, which is not helpful in a typical production environment. If you only need a load balancer without any reverse proxy or caching capabilities, there are better options. However, we need to verify our infrastructure is working as it should. If we used Varnish's caching, Varnish would only ever hit one of our two web servers during normal testing.

In terms of our caching/load balancing layer, this should suffice. For a true production environment, you should remove the final `return (pass)` and customize `default.vcl` according to your application's needs.

**Apache / PHP**

Create a `main.yml` file within the `playbooks/www` directory, with the following contents:

{lang="yaml"}
```
---
- hosts: lamp_www
  become: yes

  vars_files:
    - vars.yml

  roles:
    - geerlingguy.firewall
    - geerlingguy.repo-epel
    - geerlingguy.apache
    - geerlingguy.php
    - geerlingguy.php-mysql
    - geerlingguy.php-memcached

  tasks:
    - name: Remove the Apache test page.
      file:
        path: /var/www/html/index.html
        state: absent

    - name: Copy our fancy server-specific home page.
      template:
        src: templates/index.php.j2
        dest: /var/www/html/index.php

    - name: Ensure required SELinux dependency is installed.
      package:
        name: libsemanage-python
        state: present

    - name: Configure SELinux to allow HTTPD connections.
      seboolean:
        name: "{{ item }}"
        state: true
        persistent: true
      with_items:
        - httpd_can_network_connect_db
        - httpd_can_network_memcache
      when: ansible_selinux.status == 'enabled'
```

As with Varnish's configuration, we'll configure a firewall and add the EPEL repository (required for PHP's memcached integration), and we'll also add the following roles:

  - `geerlingguy.apache` installs and configures the latest available version of the Apache web server.
  - `geerlingguy.php` installs and configures PHP to run through Apache.
  - `geerlingguy.php-mysql` adds MySQL support to PHP.
  - `geerlingguy.php-memcached` adds Memcached support to PHP.

Two first two tasks remove the default `index.html` home page included with Apache, and replace it with our PHP app.

The last two tasks ensure SELinux is configured to allow Apache to communicate with the database and memcached servers over the network. For more discussion on how to configure SELinux, please see chapter 11.

As in the Varnish example, create the two files referenced in the above playbook. First, `vars.yml`, alongside `main.yml`:

{lang="yaml"}
```
---
firewall_allowed_tcp_ports:
  - "22"
  - "80"
```

Create a `templates` directory inside the `playbooks/www` directory, and inside, create an `index.php.j2` file. This file will use Jinja syntax to build a (relatively) simple PHP script to display the health and status of all the servers in our infrastructure:

{lang="php"}
```
<?php
/**
 * @file
 * Infrastructure test page.
 *
 * DO NOT use this in production. It is simply a PoC.
 */

$mysql_servers = array(
{% for host in groups['lamp_db'] %}
  '{{ host }}',
{% endfor %}
);
$mysql_results = array();
foreach ($mysql_servers as $host) {
  if ($result = mysql_test_connection($host)) {
    $mysql_results[$host] = '<span style="color: green;">PASS\
</span>';
    $mysql_results[$host] .= ' (' . $result['status'] . ')';
  }
  else {
    $mysql_results[$host] = '<span style="color: red;">FAIL</span>';
  }
}

// Connect to Memcached.
$memcached_result = '<span style="color: red;">FAIL</span>';
if (class_exists('Memcached')) {
  $memcached = new Memcached;
  $memcached->addServer('{{ groups['lamp_memcached'][0] }}', 11211);

  // Test adding a value to memcached.
  if ($memcached->add('test', 'success', 1)) {
    $result = $memcached->get('test');
    if ($result == 'success') {
      $memcached_result = '<span style="color: green;">PASS</span>';
      $memcached->delete('test');
    }
  }
}

/**
 * Connect to a MySQL server and test the connection.
 *
 * @param string $host
 *   IP Address or hostname of the server.
 *
 * @return array
 *   Array with 'success' (bool) and 'status' ('slave' or 'master').
 *   Empty if connection failure.
 */
function mysql_test_connection($host) {
  $username = 'mycompany_user';
  $password = 'secret';
  try {
    $db = new PDO(
      'mysql:host=' . $host . ';dbname=mycompany_database',
      $username,
      $password,
      array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));

    // Query to see if the server is configured as a master or slave.
    $statement = $db->prepare("SELECT variable_value
      FROM information_schema.global_variables
      WHERE variable_name = 'LOG_BIN';");
    $statement->execute();
    $result = $statement->fetch();

    return array(
      'success' => TRUE,
      'status' => ($result[0] == 'ON') ? 'master' : 'slave',
    );
  }
  catch (PDOException $e) {
    return array();
  }
}
?>
<!DOCTYPE html>
<html>
<head>
  <title>Host {{ inventory_hostname }}</title>
  <style>* { font-family: Helvetica, Arial, sans-serif }</style>
</head>
<body>
  <h1>Host {{ inventory_hostname }}</h1>
  <?php foreach ($mysql_results as $host => $result): ?>
    <p>MySQL Connection (<?php print $host; ?>):
    <?php print $result; ?></p>
  <?php endforeach; ?>
  <p>Memcached Connection: <?php print $memcached_result; ?></p>
</body>
</html>
```

T> Don't try transcribing this example manually; you can get the code from this book's repository on GitHub. Visit the [ansible-for-devops](https://github.com/geerlingguy/ansible-for-devops) repository and download the source for [index.php.j2](https://github.com/geerlingguy/ansible-for-devops/blob/master/lamp-infrastructure/playbooks/www/templates/index.php.j2)

This application is a bit more complex than most examples in the book, but here's a quick run through:

  - (9-23) Iterate through all the `lamp_db` MySQL hosts defined in the playbook inventory and test the ability to connect to them---as well as whether they are configured as master or slave, using the `mysql_test_connection()` function defined later (40-73).
  - (25-39) Check the first defined `lamp_memcached` Memcached host defined in the playbook inventory, confirming the ability to connect with the cache and to create, retrieve, or delete a cached value.
  - (41-76) Define the `mysql_test_connection()` function, which tests the ability to connect to a MySQL server and also returns its replication status.
  - (78-91) Print the results of all the MySQL and Memcached tests, along with `{{ inventory_hostname }}` as the page title, so we can easily see which web server is serving the viewed page.

At this point, the heart of our infrastructure---the application that will test and display the status of all our servers---is ready to go.

**Memcached**

Compared to the earlier playbooks, the Memcached playbook is quite simple. Create `playbooks/memcached/main.yml` with the following contents:

{lang="yaml"}
```
---
- hosts: lamp_memcached
  become: yes

  vars_files:
    - vars.yml

  roles:
    - geerlingguy.firewall
    - geerlingguy.memcached
```

As with the other servers, we need to ensure only the required TCP ports are open using the simple `geerlingguy.firewall` role. Next we install Memcached using the `geerlingguy.memcached` role.

In our `vars.yml` file (again, alongside `main.yml`), add the following:

{lang="yaml"}
```
---
firewall_allowed_tcp_ports:
  - "22"
firewall_additional_rules:
  - "iptables -A INPUT -p tcp --dport 11211 -s \
  {{ groups['lamp_www'][0] }} -j ACCEPT"
  - "iptables -A INPUT -p tcp --dport 11211 -s \
  {{ groups['lamp_www'][1] }} -j ACCEPT"

memcached_listen_ip: "0.0.0.0"
```

We need port 22 open for remote access, and for Memcached, we're adding manual iptables rules to allow access on port 11211 for the web servers *only*. We add one rule per `lamp_www` server by drilling down into each item in the generated `groups` variable that Ansible uses to track all inventory groups currently available. We also bind Memcached to all interfaces so it will accept connections through the server's network interface.

W> The **principle of least privilege** "requires that in a particular abstraction layer of a computing environment, every module ... must be able to access only the information and resources that are necessary for its legitimate purpose" (Source: [Wikipedia](http://en.wikipedia.org/wiki/Principle_of_least_privilege)). Always restrict services and ports to only those servers or users that need access!

**MySQL**

The MySQL configuration is more complex than the other servers because we need to configure MySQL users per-host and configure replication. Because we want to maintain an independent and flexible playbook, we also need to dynamically create some variables so MySQL will get the right server addresses in any potential environment.

Let's first create the main playbook, `playbooks/db/main.yml`:

{lang="yaml"}
```
---
- hosts: lamp_db
  become: yes

  vars_files:
    - vars.yml

  pre_tasks:
    - name: Create dynamic MySQL variables.
      set_fact:
        mysql_users:
          - name: mycompany_user
            host: "{{ groups['lamp_www'][0] }}"
            password: secret
            priv: "*.*:SELECT"
          - name: mycompany_user
            host: "{{ groups['lamp_www'][1] }}"
            password: secret
            priv: "*.*:SELECT"
        mysql_replication_master: "{{ groups['a4d.lamp.db.1'][0] }}"

  roles:
    - geerlingguy.firewall
    - geerlingguy.mysql
```

Most of the playbook is straightforward, but in this instance, we're using `set_fact` as a `pre_task` (to be run before the `geerlingguy.firewall` and `geerlingguy.mysql` roles) to dynamically create variables for MySQL configuration.

`set_fact` allows us to define variables at runtime, so we can have all server IP addresses available, even if the servers were freshly provisioned at the beginning of the playbook's run. We'll create two variables:

  - `mysql_users` is a list of users the `geerlingguy.mysql` role will create when it runs. This variable will be used on all database servers so both of the two `lamp_www` servers get `SELECT` privileges on all databases.
  - `mysql_replication_master` is used to indicate to the `geerlingguy.mysql` role which database server is the master; it will perform certain steps differently depending on whether the server being configured is a master or slave, and ensure that all the slaves are configured to replicate data from the master.

We'll need a few other normal variables to configure MySQL, so we'll add them alongside the firewall variable in `playbooks/db/vars.yml`:

{lang="yaml"}
```
---
firewall_allowed_tcp_ports:
  - "22"
  - "3306"

mysql_replication_user:
  name: replication
  password: secret

mysql_databases:
  - name: mycompany_database
    collation: utf8_general_ci
    encoding: utf8
```

We're opening port 3306 to anyone, but according to the **principle of least privilege** discussed earlier, you would be justified in restricting this port to only the servers and users that need access to MySQL (similar to the memcached server configuration). In this case, the attack vector is mitigated because MySQL's own authentication layer is used through the `mysql_user` variable generated in `main.yml`.

We are defining two MySQL variables: `mysql_replication_user` to be used for master and slave replication, and `mysql_databases` to define a list of databases that will be created (if they don't already exist) on the database servers.

With the configuration of the database servers complete, the server-specific playbooks are ready to go.

### Main Playbook for Configuring All Servers

A simple playbook including each of the group-specific playbooks is all we need for the overall configuration to take place. Create `configure.yml` in the project's root directory, with the following contents:

{lang="yaml"}
```
---
- import_playbook: playbooks/varnish/main.yml
- import_playbook: playbooks/www/main.yml
- import_playbook: playbooks/db/main.yml
- import_playbook: playbooks/memcached/main.yml
```

At this point, if you had some already-booted servers and statically defined inventory groups like `lamp_www`, `lamp_db`, etc., you could run `ansible-playbook configure.yml` and have a full HA infrastructure at the ready!

But we're going to continue to make our playbooks more flexible and useful.

### Getting the required roles

As mentioned in the Chapter 6, Ansible allows you to define all the required Ansible Galaxy roles for a given project in a `requirements.yml` file. Instead of having to remember to run `ansible-galaxy role install -y [role1] [role2] [role3]` for each of the roles we're using, we can create `requirements.yml` in the root of our project, with the following contents:

{lang="yaml"}
```
---
roles:
  - name: geerlingguy.firewall
  - name: geerlingguy.repo-epel
  - name: geerlingguy.varnish
  - name: geerlingguy.apache
  - name: geerlingguy.php
  - name: geerlingguy.php-mysql
  - name: geerlingguy.php-memcached
  - name: geerlingguy.mysql
  - name: geerlingguy.memcached
```

To make sure all the required dependencies are installed, run `ansible-galaxy install -r requirements.yml` from within the project's root.

### Vagrantfile for Local Infrastructure via VirtualBox

As with many other examples in this book, we can use Vagrant and VirtualBox to build and configure the infrastructure locally. This lets us test things as much as we want with zero cost, and usually results in faster testing cycles, since everything is orchestrated over a local private network on a (hopefully) beefy workstation.

Our basic Vagrantfile layout will be something like the following:

  1. Define a base box (in this case, CentOS 7) and VM hardware defaults.
  2. Define all the VMs to be built, with VM-specific IP addresses and hostname configurations.
  3. Define the Ansible provisioner along with the last VM, so Ansible can run once at the end of Vagrant's build cycle.

Here's the Vagrantfile in all its glory:

{lang="ruby"}
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base VM OS configuration.
  config.vm.box = "geerlingguy/centos7"
  config.ssh.insert_key = false
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # General VirtualBox VM configuration.
  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.cpus = 1
    v.linked_clone = true
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Varnish.
  config.vm.define "varnish" do |varnish|
    varnish.vm.hostname = "varnish.test"
    varnish.vm.network :private_network, ip: "192.168.56.2"
  end

  # Apache.
  config.vm.define "www1" do |www1|
    www1.vm.hostname = "www1.test"
    www1.vm.network :private_network, ip: "192.168.56.3"

    www1.vm.provision "shell",
      inline: "sudo yum update -y"

    www1.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 512]
    end
  end

  # Apache.
  config.vm.define "www2" do |www2|
    www2.vm.hostname = "www2.test"
    www2.vm.network :private_network, ip: "192.168.56.4"

    www2.vm.provision "shell",
      inline: "sudo yum update -y"

    www2.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 512]
    end
  end

  # MySQL.
  config.vm.define "db1" do |db1|
    db1.vm.hostname = "db1.test"
    db1.vm.network :private_network, ip: "192.168.56.5"
  end

  # MySQL.
  config.vm.define "db2" do |db2|
    db2.vm.hostname = "db2.test"
    db2.vm.network :private_network, ip: "192.168.56.6"
  end

  # Memcached.
  config.vm.define "memcached" do |memcached|
    memcached.vm.hostname = "memcached.test"
    memcached.vm.network :private_network, ip: "192.168.56.7"

    # Run Ansible provisioner once for all VMs at the end.
    memcached.vm.provision "ansible" do |ansible|
      ansible.playbook = "configure.yml"
      ansible.inventory_path = "inventories/vagrant/inventory"
      ansible.limit = "all"
      ansible.extra_vars = {
        ansible_user: 'vagrant',
        ansible_ssh_private_key_file: \
"~/.vagrant.d/insecure_private_key"
      }
    end
  end
end
```

Most of the Vagrantfile is straightforward, and similar to other examples used in this book. The last block of code, which defines the `ansible` provisioner configuration, contains three extra values that are important for our purposes:

{lang="ruby"}
```
ansible.inventory_path = "inventories/vagrant/inventory"
ansible.limit = "all"
ansible.extra_vars = {
  ansible_user: 'vagrant',
  ansible_ssh_private_key_file: "~/.vagrant.d/insecure_private_key"
}
```

  1. `ansible.inventory_path` defines the inventory file for the `ansible.playbook`. You could certainly create a dynamic inventory script for use with Vagrant, but because we know the IP addresses ahead of time, and are expecting a few specially-crafted inventory group names, it's simpler to build the inventory file for Vagrant provisioning by hand (we'll do this next).
  2. `ansible.limit` is set to `all` so Vagrant knows it should run the Ansible playbook connected to all VMs, and not just the current VM. You could technically use `ansible.limit` with a provisioner configuration for each of the individual VMs, and just run the VM-specific playbook through Vagrant, but our live production infrastructure will be using one playbook to configure all the servers, so we'll do the same locally.
  3. `ansible.extra_vars` contains the vagrant SSH user configuration for Ansible. It's more standard to include these settings in a static inventory file or use Vagrant's automatically-generated inventory file, but it's easiest to set them once for all servers here.

Before running `vagrant up` to see the fruits of our labor, we need to create an inventory file for Vagrant at `inventories/vagrant/inventory`:

{lang="text"}
```
[lamp_varnish]
192.168.56.2

[lamp_www]
192.168.56.3
192.168.56.4

[a4d.lamp.db.1]
192.168.56.5

[lamp_db]
192.168.56.5 mysql_replication_role=master
192.168.56.6 mysql_replication_role=slave

[lamp_memcached]
192.168.56.7
```

Now `cd` into the project's root directory, run `vagrant up`, and after ten or fifteen minutes, load `http://192.168.56.2/` in your browser. Voila!

{width=80%}
![Highly Available Infrastructure - Success!](images/9-ha-infrastructure-success.png)

You should see something like the above screenshot. The PHP app displays the current app server's IP address, the individual MySQL servers' status, and the Memcached server status. Refresh the page a few times to verify Varnish is distributing requests randomly between the two app servers.

We now have local infrastructure development covered, and Ansible makes it easy to use the exact same configuration to build our infrastructure in the cloud.

### Provisioner Configuration: DigitalOcean

In Chapter 8, we learned provisioning and configuring DigitalOcean droplets in an Ansible playbook is fairly simple. But we need to take provisioning a step further by provisioning multiple droplets (one for each server in our infrastructure) and dynamically grouping them so we can configure them after they are booted and online.

For the sake of flexibility, let's create a playbook for our DigitalOcean droplets in `provisioners/digitalocean.yml`. This will allow us to add other provisioner configurations later, alongside the `digitalocean.yml` playbook. As with our example in Chapter 7, we will use a local connection to provision cloud instances. Begin the playbook with:

{lang="yaml"}
```
---
- hosts: localhost
  connection: local
  gather_facts: false
```

Next we need to define some metadata to describe each of our droplets. For simplicity's sake, we'll inline the `droplets` variable in this playbook:

{lang="yaml",starting-line-number=6}
```
  vars:
    droplets:
      - { name: a4d.lamp.varnish, group: "lamp_varnish" }
      - { name: a4d.lamp.www.1, group: "lamp_www" }
      - { name: a4d.lamp.www.2, group: "lamp_www" }
      - { name: a4d.lamp.db.1, group: "lamp_db" }
      - { name: a4d.lamp.db.2, group: "lamp_db" }
      - { name: a4d.lamp.memcached, group: "lamp_memcached" }
```

Each droplet is an object with two keys:

  - `name`: The name of the Droplet for DigitalOcean's listings and Ansible's host inventory.
  - `group`: The Ansible inventory group for the droplet.

Next we need to add a task to create the droplets, using the `droplets` list as a guide, and as part of the same task, register each droplet's information in a separate dictionary, `created_droplets`:

{lang="yaml",starting-line-number=15}
```
  tasks:
    - name: Provision DigitalOcean droplets.
      digital_ocean_droplet:
        state: "{{ item.state | default('present') }}"
        name: "{{ item.name }}"
        private_networking: yes
        size: "{{ item.size | default('1gb') }}"
        image: "{{ item.image | default('centos-7-x64') }}"
        region: "{{ item.region | default('nyc3') }}"
        # Customize this default for your account.
        ssh_keys:
          - "{{ item.ssh_key | default('138954') }}"
        unique_name: yes
      register: created_droplets
      with_items: "{{ droplets }}"
```

Many of the options (e.g. `size`) are defined as `{{ item.property | default('default_value') }}`, which allows us to use optional variables per droplet. For any of the defined droplets, we could add `size: 2gb` (or another valid value), and it would override the default value set in the task.

T> You could specify an SSH public key per droplet, or use the same key for all hosts by providing a default (as I did above). In this example, I added an SSH key to my DigitalOcean account, then used the DigitalOcean API to retrieve the key's numeric ID (as described in the previous chapter).
T> 
T> It's best to use key-based authentication and add at least one SSH key to your DigitalOcean account so Ansible can connect using secure keys instead of insecure passwords---especially since these instances will be created with only a root account.

We loop through all the defined `droplets` using `with_items: droplets`, and after each droplet is created, we add the droplet's metadata (name, IP address, etc.) to the `created_droplets` variable. Next, we'll loop through that variable to build our inventory on-the-fly so our configuration applies to the correct servers:

{lang="yaml",starting-line-number=31}
```
    - name: Add DigitalOcean hosts to inventory groups.
      add_host:
        name: "{{ item.1.data.ip_address }}"
        groups: "do,{{ droplets[item.0].group }},{{ item.1.data.droplet.name }}"
        # You can dynamically add inventory variables per-host.
        ansible_user: root
        mysql_replication_role: >-
          {{ 'master' if (item.1.data.droplet.name == 'a4d.lamp.db.1')
          else 'slave' }}
        mysql_server_id: "{{ item.0 }}"
      when: item.1.data is defined
      with_indexed_items: "{{ created_droplets.results }}"
```

You'll notice a few interesting things happening in this task:

  - This is the first time we've used `with_indexed_items`. Though less common, this is a valuable loop feature because it adds a sequential and unique `mysql_server_id`. Though only the MySQL servers need a server ID set, it's more simple to dynamically create the variable for every server so each is available when needed. `with_indexed_items` sets `item.0` to the key of the item and `item.1` to the value of the item.
  - In addition to helping us create server IDs, `with_indexed_items` also helps us to reliably set each droplet's group. We could also consider using tags for groups, but this example configures groups manually. By using the `droplets` variable we manually created earlier, we can set the proper group for a particular droplet.
  - Finally, we add inventory variables per-host in `add_host`. To do this, we add the variable name as a key and the variable value as that key's value. Simple, but powerful!

T> There are a few different ways you can approach dynamic provisioning and inventory management for your infrastructure. There are ways to avoid using more exotic features of Ansible (e.g. `with_indexed_items`) and complex if/else conditions, especially if you only use one cloud infrastructure provider. This example is slightly more complex because the playbook is being created to be interchangeable with similar provisioning playbooks.

The final step in our provisioning is to make sure all the droplets are booted and can be reached via SSH. So at the end of the `digitalocean.yml` playbook, add another play to be run on hosts in the `do` group we just defined:

{lang="yaml",starting-line-number=44}
```
- hosts: do
  remote_user: root
  gather_facts: false

  tasks:
    - name: Wait for hosts to become reachable.
      wait_for_connection:
```

Once the server can be reached by Ansible (using the `wait_for_connection` module), we know the droplet is up and ready for configuration.

We're now *almost* ready to provision and configure our entire infrastructure on DigitalOcean, but first we need to create one last playbook to tie everything together. Create `provision.yml` in the project root with the following contents:

{lang="yaml"}
```
---
- import_playbook: provisioners/digitalocean.yml
- import_playbook: configure.yml
```

That's it! Now, assuming you set the environment variable `DO_API_TOKEN`, you can run `$ ansible-playbook provision.yml` to provision and configure the infrastructure on DigitalOcean.

The entire process should take about 15 minutes; once it's complete, you should see something like this:

{lang="text",linenos=off}
```
PLAY RECAP **********************************************************
107.170.27.137       : ok=19   changed=13   unreachable=0    failed=0
107.170.3.23         : ok=13   changed=8    unreachable=0    failed=0
107.170.51.216       : ok=40   changed=18   unreachable=0    failed=0
107.170.54.218       : ok=27   changed=16   unreachable=0    failed=0
162.243.20.29        : ok=24   changed=15   unreachable=0    failed=0
192.241.181.197      : ok=40   changed=18   unreachable=0    failed=0
localhost            : ok=2    changed=1    unreachable=0    failed=0
```

Visit the IP address of the varnish server, and you will be greeted with a status page similar to the one generated by the Vagrant-based infrastructure:

{width=80%}
![Highly Available Infrastructure on DigitalOcean.](images/9-ha-infrastructure-digitalocean.png)

Because everything in this playbook is idempotent, running `$ ansible-playbook provision.yml` again should report no changes, and this will help you verify that everything is running correctly.

Ansible will also rebuild and reconfigure any droplets that might be missing from your infrastructure. If you're daring and would like to test this feature, just log into your DigitalOcean account, delete one of the droplets just created by this playbook (perhaps one of the two app servers), and then run the playbook again.

Now that we've tested our infrastructure on DigitalOcean, we can destroy the droplets just as easily as we can create them. To do this, change the `state` parameter in `provisioners/digitalocean.yml` to default to `'absent'` and run `$ ansible-playbook provision.yml` once more.

Next up, we'll build the infrastructure a third time---on Amazon's infrastructure.

### Provisioner Configuration: Amazon Web Services (EC2)

For Amazon Web Services, provisioning is slightly different. Amazon has a broader ecosystem of services surrounding EC2 instances, so for our particular example we will need to configure security groups prior to provisioning instances.

To begin, create `aws.yml` inside the `provisioners` directory and begin the playbook the same way as for DigitalOcean:

{lang="yaml"}
```
---
- hosts: localhost
  connection: local
  gather_facts: false
```

First, we'll define three variables to describe what AWS resources and region to use for provisioning.

{lang="yaml",starting-line-number=6}
```
  vars:
    aws_profile: default
    aws_region: us-east-1 # North Virginia
    aws_ec2_ami: ami-06cf02a98a61f9f5e # CentOS 7
```

EC2 instances use security groups as an AWS-level firewall (which operates outside the individual instance's OS). We will need to define a list of `security_groups` alongside our EC2 `instances`. First, the `instances`:

{lang="yaml",starting-line-number=11}
```
    instances:
      - name: a4d.lamp.varnish
        group: "lamp_varnish"
        security_group: ["default", "a4d_lamp_http"]
      - name: a4d.lamp.www.1
        group: "lamp_www"
        security_group: ["default", "a4d_lamp_http"]
      - name: a4d.lamp.www.2
        group: "lamp_www"
        security_group: ["default", "a4d_lamp_http"]
      - name: a4d.lamp.db.1
        group: "lamp_db"
        security_group: ["default", "a4d_lamp_db"]
      - name: a4d.lamp.db.2
        group: "lamp_db"
        security_group: ["default", "a4d_lamp_db"]
      - name: a4d.lamp.memcached
        group: "lamp_memcached"
        security_group: ["default", "a4d_lamp_memcached"]
```

Inside the `instances` variable, each instance is an object with three keys:

  - `name`: The name of the instance, which we'll use to tag the instance and ensure only one instance is created per name.
  - `group`: The Ansible inventory group in which the instance should belong.
  - `security_group`: A list of security groups into which the instance will be placed. The `default` security group is added to your AWS account upon creation, and has one rule to allow outgoing traffic on any port to any IP address.

I> If you use AWS exclusively, it would be best to use autoscaling groups and change the design of this infrastructure. For this example, we just need to ensure that the six instances we explicitly define are created, so we're using particular `name`s and an `exact_count` to enforce the 1:1 relationship.

With our instances defined, we'll next define a `security_groups` variable containing all the required security group configuration for each server:

{lang="yaml",starting-line-number=31}
```
    security_groups:
      - name: a4d_lamp_http
        rules:
          - proto: tcp
            from_port: 80
            to_port: 80
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 22
            to_port: 22
            cidr_ip: 0.0.0.0/0
        rules_egress: []

      - name: a4d_lamp_db
        rules:
          - proto: tcp
            from_port: 3306
            to_port: 3306
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 22
            to_port: 22
            cidr_ip: 0.0.0.0/0
        rules_egress: []

      - name: a4d_lamp_memcached
        rules:
          - proto: tcp
            from_port: 11211
            to_port: 11211
            cidr_ip: 0.0.0.0/0
          - proto: tcp
            from_port: 22
            to_port: 22
            cidr_ip: 0.0.0.0/0
        rules_egress: []
```

Each security group has a `name` (which was used to identify the security group in the `instances` list), `rules` (a list of firewall rules---like protocol, ports, and IP ranges---to limit *incoming* traffic), and `rules_egress` (a list of firewall rules to limit *outgoing* traffic).

We need three security groups: `a4d_lamp_http` to open port 80, `a4d_lamp_db` to open port 3306, and `a4d_lamp_memcached` to open port 11211.

Now that we have all the data we need to set up security groups and instances, our first task is to create or verify the existence of the security groups:

{lang="yaml",starting-line-number=68}
```
  tasks:
    - name: Configure EC2 Security Groups.
      ec2_group:
        name: "{{ item.name }}"
        description: Example EC2 security group for A4D.
        state: present
        rules: "{{ item.rules }}"
        rules_egress: "{{ item.rules_egress }}"
        profile: "{{ aws_profile }}"
        region: "{{ aws_region }}"
      with_items: "{{ security_groups }}"
```

The `ec2_group` requires a name, region, and rules for each security group. Security groups will be created if they don't exist, modified to match the supplied values if they do exist, or verified if they both exist and match the given values.

With the security groups configured, we can provision the defined EC2 instances by looping through `instances` with the `ec2` module:

{lang="yaml",starting-line-number=75}
```
    - name: Provision EC2 instances.
      ec2:
        key_name: "{{ item.ssh_key | default('lamp_aws') }}"
        instance_tags:
          Name: "{{ item.name | default('') }}"
          Application: lamp_aws
          inventory_group: "{{ item.group | default('') }}"
          inventory_host: "{{ item.name | default('') }}"
        group: "{{ item.security_group | default('') }}"
        instance_type: "{{ item.type | default('t2.micro')}}"
        image: "{{ aws_ec2_ami }}"
        wait: yes
        wait_timeout: 500
        exact_count: 1
        count_tag:
          inventory_host: "{{ item.name | default('') }}"
        profile: "{{ aws_profile }}"
        region: "{{ aws_region }}"
      register: created_instances
      with_items: "{{ instances }}"
```

This example is slightly more complex than the DigitalOcean example, and a few parts warrant a deeper look:

  - EC2 allows SSH keys to be defined by name---in my case, I have a key `lamp_aws` in my AWS account. You should set the `key_name` default to a key that you have in your account.
  - Instance tags are tags that AWS will attach to your instance, for categorization purposes. Besides the `Name` tag (which is used for display purposes in the AWS Console), you can add whatever tags you want, to help categorize instances.
  - `t2.micro` was used as the default instance type, since it falls within EC2's free tier usage. If you just set up an account and keep all AWS resource usage within free tier limits, you won't be billed anything.
  - `exact_count` and `count_tag` work together to ensure AWS provisions only one of each of the instances we defined. The `count_tag` tells the `ec2` module to match on the `inventory_host` value, and `exact_count` tells the module to only provision `1` instance. If you wanted to *remove* all your instances, you could set `exact_count` to 0 and run the playbook again.

Each provisioned instance will have its metadata added to the registered `created_instances` variable, which we will use to build Ansible inventory groups for the server configuration playbooks.

{lang="yaml",starting-line-number=100}
```
    - name: Add EC2 instances to inventory groups.
      add_host:
        name: "{{ item.1.tagged_instances.0.public_ip }}"
        groups: "aws,{{ item.1.item.group }},{{ item.1.item.name }}"
        # You can dynamically add inventory variables per-host.
        ansible_user: centos
        host_key_checking: false
        mysql_replication_role: >-
          {{ 'master' if (item.1.item.name == 'a4d.lamp.db.1')
          else 'slave' }}
        mysql_server_id: "{{ item.0 }}"
      when: item.1.instances is defined
      with_indexed_items: "{{ created_instances.results }}"
```

This `add_host` example is slightly simpler than the one for DigitalOcean, because AWS attaches metadata to EC2 instances which we can re-use when building groups or hostnames (e.g. `item.1.item.group`). We don't have to use list indexes to fetch group names from the original `instances` variable.

We still use `with_indexed_items` so we can use the index to generate a unique ID per server for use in building the MySQL master-slave replication.

The final step in provisioning the EC2 instances is to ensure they are booted and able to accept connections.

{lang="yaml",starting-line-number=114}
```
- hosts: aws
  gather_facts: false

  tasks:
    - name: Wait for hosts to become available.
      wait_for_connection:
```

Now, modify the `provision.yml` file in the root of the project folder and change the provisioners import to look like the following:

{lang="yaml"}
```
---
- import_playbook: provisioners/aws.yml
- import_playbook: configure.yml
```

Assuming the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set in your current terminal session, you can run `$ ansible-playbook provision.yml` to provision and configure the infrastructure on AWS.

The entire process should take about 15 minutes, and once it's complete, you should see something like this:

{lang="text",linenos=off}
```
PLAY RECAP **********************************************************
54.148.100.44        : ok=24   changed=16   unreachable=0    failed=0
54.148.120.23        : ok=40   changed=19   unreachable=0    failed=0
54.148.41.134        : ok=40   changed=19   unreachable=0    failed=0
54.148.56.137        : ok=13   changed=9    unreachable=0    failed=0
54.69.160.32         : ok=27   changed=17   unreachable=0    failed=0
54.69.86.187         : ok=19   changed=14   unreachable=0    failed=0
localhost            : ok=3    changed=1    unreachable=0    failed=0
```

Visit the IP address of the Varnish server, and you will be greeted with a status page similar to the one generated by the Vagrant and DigitalOcean-based infrastructure:

{width=80%}
![Highly Available Infrastructure on AWS EC2.](images/9-ha-infrastructure-aws.png)

As with the earlier examples, running `ansible-playbook provision.yml` again should produce no changes, because everything in this playbook is idempotent. If one of your instances was somehow terminated, running the playbook again would recreate and reconfigure the instance in a few minutes.

To terminate all the provisioned instances, you can change the `exact_count` in the `ec2` task to `0`, and run `$ ansible-playbook provision.yml` again.

#### AWS EC2 Dynamic inventory plugin

If you'd like to connect to the EC2 servers provisioned in AWS in another playbook, you don't need to get the information in a play and use `add_hosts` to build the inventory inside a playbook.

Like the DigitalOcean example in the previous chapter, you can use the `aws_ec2` dynamic inventory plugin to work with the servers in an AWS account.

Create an `aws_ec2.yml` inventory configuration file in an `inventories/aws` directory under the main playbook directory, and add the following:

{lang=yaml}
```
---
plugin: aws_ec2

regions:
  - us-east-1

hostnames:
  - ip-address

keyed_groups:
  - key: tags.inventory_group
```

To verify the inventory source works correctly, use the `ansible-inventory` command:

{lang=text,linenos=off}
```
$ ansible-inventory -i inventories/aws/aws_ec2.yml --graph
@all:
  |--@aws_ec2:
  |  |--54.148.41.134
  |  |--54.148.100.44
  |  |--54.69.160.32
  |  |--54.69.86.187
  |  |--54.148.120.23
  |  |--54.148.56.137
  |--@lamp_aws:
  |  |--54.148.41.134
  |  |--54.148.100.44
  |  |--54.69.160.32
  |  |--54.69.86.187
  |  |--54.148.120.23
  |  |--54.148.56.137
  |--@lamp_db:
  |  |--54.148.100.44
  |  |--54.148.120.23
  |--@lamp_memcached:
  |  |--54.148.41.134
  |--@lamp_varnish:
  |  |--54.148.56.137
  |--@lamp_www:
  |  |--54.69.160.32
  |  |--54.69.86.187
  |--@ungrouped:
```

You can then use these dynamic inventory groups in other playbooks to run tasks on all the LAMP servers (e.g. `lamp_aws`), or just one subset (e.g. `lamp_db` or `lamp_www`).

### Summary

We defined an entire highly-available PHP application infrastructure in a series of short Ansible playbooks, and then created provisioning configuration to build the infrastructure on either local VMs, DigitalOcean droplets, or AWS EC2 instances.

Once you start working on building infrastructure this way---by abstracting individual servers, then abstracting cloud provisioning---you'll start to see some of Ansible's true power of being more than just a configuration management tool. Imagine being able to create your own multi-datacenter, multi-provider infrastructure with Ansible and some basic configuration.

Amazon, DigitalOcean, Rackspace and other hosting providers have their own tooling and unique infrastructure merits. However, building infrastructure in a provider-agnostic fashion provides the agility and flexibility that allow you to treat hosting providers as commodities, and gives you the freedom to build more reliable and more performant application infrastructure.

Even if you plan on running everything within one hosting provider's network (or in a private cloud, or even on a few bare metal servers), Ansible provides deep stack-specific integration so you can do whatever you need to do and manage the provider's services within your playbooks.

I> You can find the entire contents of this example in the [Ansible for DevOps GitHub repository](https://github.com/geerlingguy/ansible-for-devops), in the `lamp-infrastructure` directory.

## ELK Logging with Ansible

Though application, database, and backup servers may be some of the most mission-critical components of a well-rounded infrastructure, one area that is equally important is a decent logging system.

In the old days when one or two servers could handle an entire website or application, you could work with built-in logfiles and rsyslog to troubleshoot issues or check trends in performance, errors, or overall traffic. With a typical modern infrastructure---like the example above, with six separate servers---it pays dividends to find a better solution for application, server, and firewall/authentication logging. Plain text files, logrotate, and grep don't cut it anymore.

Among various modern logging and reporting toolsets, the 'ELK' stack (Elasticsearch, Logstash, and Kibana) has come to the fore as one of the best-performing and easiest-to-configure open source centralized logging solutions.

{width=80%}
![An example Kibana logging dashboard.](images/9-elk-kibana-example.png)

In our example, we'll configure a single ELK server to handle aggregation, searching, and graphical display of logged data from a variety of other servers, and give a configuration example to aggregate common system and web server logs.

### ELK Playbook

Just like our previous example, we're going to let a few roles from Ansible Galaxy do the heavy lifting of actually installing and configuring Elasticsearch, Logstash, Filebeat, and Kibana. If you're interested in reading through the roles that do this work, feel free to peruse them after they've been downloaded.

In this example, I'm going to highlight the important parts rather than walk through each role and variable in detail. Then I'll show how you can use this base server to aggregate logs, then how to point other servers' log files to the central server using Filebeat.

Here's our main playbook, saved as `provisioning/elk/main.yml`:

{lang="yaml"}
```
---
- hosts: logs
  gather_facts: yes

  vars_files:
    - vars/main.yml

  pre_tasks:
    - name: Update apt cache if needed.
      apt: update_cache=yes cache_valid_time=86400

  roles:
    - geerlingguy.java
    - geerlingguy.nginx
    - geerlingguy.pip
    - geerlingguy.elasticsearch
    - geerlingguy.elasticsearch-curator
    - geerlingguy.kibana
    - geerlingguy.logstash
    - geerlingguy.filebeat
```

This assumes you have a `logs` group in your inventory with at least one server listed. It also assumes you have all of those roles installed via Galaxy, using the following `requirements.yml`:

{lang="yaml"}
```
---
roles:
- name: geerlingguy.java
- name: geerlingguy.nginx
- name: geerlingguy.pip
- name: geerlingguy.elasticsearch
  version: 5.0.0
- name: geerlingguy.elasticsearch-curator
  version: 2.1.0
- name: geerlingguy.kibana
  version: 4.0.0
- name: geerlingguy.logstash
  version: 5.1.0
- name: geerlingguy.filebeat
  version: 3.0.1
```

T> This example sets specific `version`s for some of the roles, because the ELK stack tools only work together well if you install a specific set of versions. For many projects, I specify a `version` for every dependency so I can choose when to upgrade to a newer role version that might have breaking changes.

The playbook includes a vars file located in `provisioning/elk/vars/main.yml`, so create that file and put the following inside:

{lang="yaml"}
```
---
java_packages:
  - openjdk-11-jdk

nginx_user: www-data
nginx_remove_default_vhost: true
nginx_vhosts:
  # Kibana proxy.
  - listen: "80 default_server"
    filename: kibana.conf
    server_name: logs.test
    extra_parameters: |
      location / {
          include /etc/nginx/proxy_params;
          proxy_pass          http://localhost:5601;
          proxy_set_header   Authorization "";
          proxy_read_timeout  90s;
      }

elasticsearch_curator_pip_package: python3-pip

logstash_ssl_key_file: elk-example.p8
logstash_ssl_certificate_file: elk-example.crt

filebeat_output_logstash_enabled: true
filebeat_output_logstash_hosts:
  - "logs.test:5044"

filebeat_ssl_key_file: elk-example.p8
filebeat_ssl_certificate_file: elk-example.crt
filebeat_ssl_insecure: "true"

filebeat_inputs:
  - type: log
    paths:
      - /var/log/auth.log
```

The Nginx variables define one `server` directive, which proxies requests on port 80 to the Kibana instance running on port 5601 (Kibana's default port).

The Logstash SSL variables give the name of a local file which will be copied into place and used by Logstash to encrypt log traffic to and from Logstash. You can generate the certificate using the command:

{lang="text",linenos=off}
```
openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout elk-example.key -out elk-example.crt -subj '/CN=logs.test'
```

Set the `CN` value to the hostname of your ELK server (in our example, `logs.test`. Then convert the key format to pkcs8 (the format required by Logstash) using the command:

{lang="text",linenos=off}
```
openssl pkcs8 -in elk-example.key -topk8 -nocrypt -out elk-example.p8
```

The Filebeat variables tell Filebeat to connect to the Logstash server (in this case, the hostname `logs.test` on the default Logstash port `5044`), and supply the certificate and key Filebeat should use to encrypt log traffic. The `filebeat_ssl_insecure` variable tells Logstash to accept a self-signed certificate like the one we generated with `openssl`.

The last variable, `filebeat_inputs`, supplies a list of `inputs` Filebeat will pick up and stream to Logstash. In this case, it's just one input, the `auth.log` file which logs all authentication-related events on a Debian-based server.

If you want to get this ELK server up and running quickly, you can create a local VM using Vagrant like you have in most other examples in the book. Create a `Vagrantfile` in the same directory as the `provisioning` folder, with the following contents:

{lang="ruby"}
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.ssh.insert_key = false

  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # ELK server.
  config.vm.define "logs" do |logs|
    logs.vm.hostname = "logs.test"
    logs.vm.network :private_network, ip: "192.168.56.90"

    logs.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/elk/main.yml"
      ansible.inventory_path = "provisioning/elk/inventory"
      ansible.become = true
    end
  end

end
```

This Vagrant configuration expects an inventory file at `provisioning/elk/inventory`, so create one with the following contents:

{lang="text"}
```
[logs]
logs.test ansible_ssh_host=192.168.56.90 ansible_ssh_port=22
```

Now, run `vagrant up`. The build should take about five minutes, and upon completion, if you add a line like `logs.test  192.168.56.90` to your `/etc/hosts` file, you can visit `http://logs.test/` in your browser and see Kibana's default homepage:

{width=80%}
![Kibana's default homepage.](images/9-elk-kibana-default.png)

You can start exploring log data after configuring Kibana to search filebeat indices:

  1. Click on the home page link to 'Connect to your Elasticsearch index'
  2. Enter an index pattern like `filebeat-*` (which will match all Filebeat indices), and click 'Next step'
  3. Choose `@timestamp` for the Time Filter field name, and click 'Create index pattern'

Now that Kibana knows how to read the filebeat index, you can discover and search through log data in the 'Discover' UI, which is the top link in the sidebar:

{width=80%}
![Exploring log data from filebeat.](images/9-elk-kibana-logstash-dashboard.png)

We won't dive too deep into customizing Kibana's interface with saved searches, visualizations, and dashboards, since there are many guides to using Kibana, including [Kibana's official guide](https://www.elastic.co/guide/en/kibana/current/tutorial-build-dashboard.html).

I> The screenshots in this example are from Kibana 7.x; other versions may have a slightly different interface.

### Forwarding Logs from Other Servers

It's great that we have the ELK stack running. Elasticsearch will store and make available log data with one search index per day, Logstash will listen for log entries, Filebeat will send entries in `/var/log/auth.log` to Logstash, and Kibana will organize the logged data in useful visualizations.

Configuring additional servers to direct their logs to our new Logstash server is fairly simple using Filebeat. The basic steps we'll follow are:

  1. Set up another server in the Vagrantfile.
  2. Set up an Ansible playbook to install and configure Filebeat alongside the application running on the server.
  3. Boot the server and watch as the logs are forwarded to the main ELK server.

Let's begin by creating a new Nginx web server. It's useful to monitor web server access logs for a variety of reasons, especially to watch for traffic spikes and increases in non-200 responses for certain resources. Add the following server definition inside the Vagrantfile, just after the `end` of the ELK server definition:

{lang="ruby",starting-line-number=30}
```
  # Web server.
  config.vm.define "web" do |web|
    web.vm.hostname = "web.test"
    web.vm.network :private_network, ip: "192.168.56.91"

    web.vm.provider :virtualbox do |v|
      v.memory = 512
      v.cpus = 1
    end

    web.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/web/main.yml"
      ansible.inventory_path = "provisioning/web/inventory"
      ansible.become = true
    end
  end
```

We'll next set up the playbook to install and configure both Nginx and Filebeat, at `provisioning/web/main.yml`:

{lang="yaml"}
```
---
- hosts: web
  gather_facts: yes

  vars_files:
    - vars/main.yml

  pre_tasks:
    - name: Update apt cache if needed.
      apt: update_cache=yes cache_valid_time=86400

  roles:
    - geerlingguy.nginx
    - geerlingguy.filebeat

  tasks:
    - name: Set up virtual host for testing.
      copy:
        src: files/example.conf
        dest: /etc/nginx/sites-enabled/example.conf
        owner: root
        group: root
        mode: 0644
      notify: restart nginx

    - name: Ensure logs server is in hosts file.
      lineinfile:
        dest: /etc/hosts
        regexp: '.*logs\.test$'
        line: "192.168.56.90 logs.test"
        state: present
```

This playbook runs the `geerlingguy.nginx` and `geerlingguy.filebeat` roles, and in the `tasks`, there are two additional tasks: one to configure a server in Nginx's configuration (`example.conf`), and one to ensure the webserver knows the correct IP address for the `logs.test` server.

Create the Nginx configuration file at the path `provisioning/web/files/example.conf`, and define one Nginx virtualhost for our testing:

{lang="text"}
```
server {
  listen 80 default_server;

  root /usr/share/nginx/www;
  index index.html index.htm;

  access_log /var/log/nginx/access.log combined;
  error_log /var/log/nginx/error.log debug;
}
```

Since this is the only `server` definition, and it's set as the `default_server` on port 80, all requests will be directed to it. We routed the `access_log` to `/var/log/nginx/access.log`, and told Nginx to write log entries using the `combined` format, which is how our Logstash server expects nginx access logs to be formatted.

Next, set up the required variables to tell the `nginx` and `logstash-forwarder` roles how to configure their respective services. Inside `provisioning/web/vars/main.yml`:

{lang="yaml"}
```
---
nginx_user: www-data
nginx_remove_default_vhost: true

filebeat_output_logstash_enabled: true
filebeat_output_logstash_hosts:
  - "logs.test:5044"

filebeat_ssl_key_file: elk-example.p8
filebeat_ssl_certificate_file: elk-example.crt
filebeat_ssl_insecure: "true"

filebeat_inputs:
  - type: log
    paths:
      - /var/log/auth.log
  - type: log
    paths:
      - /var/log/nginx/access.log
```

The `nginx` variables remove the default virtualhost entry and ensure Nginx will run optimally on our Ubuntu server. The `filebeat` variables tell the filebeat role how to connect to the central ELK server, and which logs to deliver to Logstash:

  - `filebeat_output_logstash_enabled` and `_hosts`: Tells the role to configure Filebeat to connect to Logstash, and the host and port to use.
  - `logstash_ssl_*`: Provide a key and certificate to use for encrypted log transport (note that these files should be in the same directory as the playbook, copied over from the `elk` playbook).
  - `filebeat_inputs`: Defines a list of inputs, which identify log files or other types of log inputs. In this case, we're configuring the authentication log (`/var/log/auth.log`), which is a `syslog`-formatted log file, and the combined-format access log from Nginx (`/var/log/nginx/access.log`).

To allow Vagrant to pass the proper connection details to Ansible, create a file named `provisioning/web/inventory` with the `web.test` host details:

{lang="text"}
```
[web]
web.test ansible_ssh_host=192.168.56.91 ansible_ssh_port=22
```

Run `vagrant up` again. Vagrant should verify that the first server (`logs`) is running, then create and run the Ansible provisioner on the newly-defined `web` Nginx server.

You can load `http://192.168.56.91/` or `http://web.test/` in your browser, and you should see a `Welcome to nginx!` message on the page. You can refresh the page a few times, then switch back over to `http://logs.test/` to view some new log entries on the ELK server:

{width=80%}
![Entries populating the Logstash Search Kibana dashboard.](images/9-logstash-forwarding-nginx.png)

T> If you refresh the page a few times, and no entries show up in the Kibana search, Nginx may be buffering the log entries. In this case, keep refreshing a while (so you generate a few dozen or hundred entries), and Nginx will eventually write the entries to disk (thus allowing Filebeat to convey the logs to the Logstash server). Read more about Nginx log buffering in the [Nginx's ngx_http_log_module documentation](http://nginx.org/en/docs/http/ngx_http_log_module.html).

A few requests being logged through logstash forwarder isn't all that exciting. Let's use the popular `ab` tool available most anywhere to put some load on the web server. On a modest laptop, running the command below resulted in Nginx serving around 1,200 requests per second.

{lang="text",linenos=off}
```
ab -n 20000 -c 50 http://web.test/
```

During the course of the load test, I set Kibana to show only the past 5 minutes of log data (automatically refreshed every 5 seconds) and I could monitor the requests on the ELK server just a few seconds after they were served by Nginx:

{width=80%}
![Monitoring a deluge of Nginx requests in near-realtime.](images/9-logstash-forwarding-ab-load.png)

Filebeat uses a highly-efficient TCP-like protocol, Lumberjack, to transmit log entries securely between servers. With the right tuning and scaling, you can efficiently process and display thousands of requests per second across your infrastructure! For most, even the simple example demonstrated above would adequately cover an entire infrastructure's logging and log analysis needs.

### Summary

Log aggregation and analysis are two fields that see constant improvements and innovation. There are many SaaS products and proprietary solutions that can assist with logging, but few match the flexibility, security, and TCO of Elasticsearch, Logstash and Kibana.

Ansible is the simplest way to configure an ELK server and direct all your infrastructure's pertinent log data to the server.

## GlusterFS Distributed File System Configuration with Ansible

Modern infrastructure often involves some amount of horizontal scaling; instead of having one giant server with one storage volume, one database, one application instance, etc., most apps use two, four, ten, or dozens of servers.

{width=80%}
![GlusterFS is a distributed filesystem for servers.](images/9-glusterfs-architecture.png)

Many applications can be scaled horizontally with ease. But what happens when you need shared resources, like files, application code, or other transient data, to be shared on all the servers? And how do you have this data scale out with your infrastructure, in a fast but reliable way? There are many different approaches to synchronizing or distributing files across servers:

  - Set up rsync either on cron or via inotify to synchronize smaller sets of files on a regular basis.
  - Store everything in a code repository (e.g. Git, SVN, etc.) and deploy files to each server using Ansible.
  - Have one large volume on a file server and mount it via NFS or some other file sharing protocol.
  - Have one master SAN that's mounted on each of the servers.
  - Use a distributed file system, like Gluster, Lustre, Fraunhofer, or Ceph.

Some options are easier to set up than others, and all have benefits---and drawbacks. Rsync, git, or NFS offer simple initial setup, and low impact on filesystem performance (in many scenarios). But if you need more flexibility and scalability, less network overhead, and greater fault tolerance, you will have to consider something that requires more configuration (e.g. a distributed file system) and/or more hardware (e.g. a SAN).

GlusterFS is licensed under the AGPL license, has good documentation, and a fairly active support community (especially in the #gluster IRC channel). But to someone new to distributed file systems, it can be daunting to get set it up the first time.

### Configuring Gluster - Basic Overview

To get Gluster working on a basic two-server setup (so you can have one folder synchronized and replicated across the two servers---allowing one server to go down completely, and the other to still have access to the files), you need to do the following:

  1. Install Gluster server and client on each server, and start the server daemon.
  2. (On both servers) Create a 'brick' directory (where Gluster will store files for a given volume).
  3. (On both servers) Create a directory to be used as a mount point (a directory where you'll have Gluster mount the shared volume).
  4. (On both servers) Use `gluster peer probe` to have Gluster connect to the other server.
  5. (On one server) Use `gluster volume create` to create a new Gluster volume.
  6. (On one server) Use `gluster volume start` to start the new Gluster volume.
  7. (On both servers) Mount the gluster volume (adding a record to `/etc/fstab` to make the mount permanent).

Additionally, you need to make sure you have the following ports open on both servers (so Gluster can communicate): TCP ports 111, 24007-24011, 49152-49153, and UDP port 111. For each extra server in your Gluster cluster, you need to add an additional TCP port in the 49xxx range.

### Configuring Gluster with Ansible

For demonstration purposes, we'll set up a simple two-server infrastructure using Vagrant, and create a shared volume between the two, with two replicas (meaning all files will be replicated on each server). As your infrastructure grows, you can set other options for data consistency and transport according to your needs.

To build the two-server infrastructure locally, create a folder `gluster` containing the following `Vagrantfile`:

{lang="ruby"}
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base VM OS configuration.
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.ssh.insert_key = false

  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.cpus = 1
  end

  # Define two VMs with static private IP addresses.
  boxes = [
    { :name => "gluster1", :ip => "192.168.56.2" },
    { :name => "gluster2", :ip => "192.168.56.3" }
  ]

  # Provision each of the VMs.
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network :private_network, ip: opts[:ip]

      # Provision both VMs using Ansible after the last VM is booted.
      if opts[:name] == "gluster2"
        config.vm.provision "ansible" do |ansible|
          ansible.playbook = "playbooks/provision.yml"
          ansible.inventory_path = "inventory"
          ansible.limit = "all"
        end
      end
    end
  end

end
```

This configuration creates two servers, `gluster1` and `gluster2`, and will run a playbook at `playbooks/provision.yml` on the servers defined in an `inventory` file in the same directory as the Vagrantfile.

Create the `inventory` file to help Ansible connect to the two servers:

{lang="text"}
```
[gluster]
192.168.56.2
192.168.56.3

[gluster:vars]
ansible_user=vagrant
ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key
```

Now, create a playbook named `provision.yml` inside a `playbooks` directory:

{lang="yaml"}
```
---
- hosts: gluster
  become: yes

  vars_files:
    - vars.yml

  roles:
    - geerlingguy.firewall
    - geerlingguy.glusterfs

  tasks:
    - name: Ensure Gluster brick and mount directories exist.
      file:
        path: "{{ item }}"
        state: directory
        mode: 0775
      with_items:
        - "{{ gluster_brick_dir }}"
        - "{{ gluster_mount_dir }}"

    - name: Configure Gluster volume.
      gluster_volume:
        state: present
        name: "{{ gluster_brick_name }}"
        brick: "{{ gluster_brick_dir }}"
        replicas: 2
        cluster: "{{ groups.gluster | join(',') }}"
        host: "{{ inventory_hostname }}"
        force: yes
      run_once: true

    - name: Ensure Gluster volume is mounted.
      mount:
        name: "{{ gluster_mount_dir }}"
        src: "{{ inventory_hostname }}:/{{ gluster_brick_name }}"
        fstype: glusterfs
        opts: "defaults,_netdev"
        state: mounted
```

This playbook uses two roles to set up a firewall and install the required packages for GlusterFS to work. You can manually install both of the required roles with the command `ansible-galaxy role install geerlingguy.firewall geerlingguy.glusterfs`, or add them to a `requirements.yml` file and install with `ansible-galaxy install -r requirements.yml`.

Gluster requires a 'brick' directory to use as a virtual filesystem, and our servers also need a directory where the filesystem can be mounted, so the first `file` task ensures both directories exist (`gluster_brick_dir` and `gluster_mount_dir`). Since we need to use these directory paths more than once, we use variables which will be defined later, in `vars.yml`.

Ansible's `gluster_volume` module (added in Ansible 1.9) does all the hard work of probing peer servers, setting up the brick as a Gluster filesystem, and configuring the brick for replication. Some of the most important configuration parameters for the `gluster_volume` module include:

  - `state`: Setting this to `present` makes sure the brick is present. It will also start the volume when it is first created by default, though this behavior can be overridden by the `start_on_create` option.
  - `name` and `brick` give the Gluster brick a name and location on the server, respectively. In this example, the brick will be located on the boot volume, so we also have to add `force: yes`, or Gluster will complain about not having the brick on a separate volume.
  - `replicas` tells Gluster how many replicas should exist; this number can vary depending on how many servers you have in the brick's `cluster`, and how much tolerance you have for server outages. We won't get much into tuning GlusterFS for performance and resiliency, but most situations warrant a value of `2` or `3`.
  - `cluster` defines all the hosts which will contain the distributed filesystem. In this case, all the `gluster` servers in our Ansible inventory should be included, so we use a Jinja `join` filter to join all the addresses into a list.
  - `host` sets the host for peer probing explicitly. If you don't set this, you can sometimes get errors on brick creation, depending on your network configuration.

We only need to run the `gluster_volume` module once for all the servers, so we add `run_once: true`.

The last task in the playbook uses Ansible's `mount` module to ensure the Gluster volume is mounted on each of the servers, in the `gluster_mount_dir`.

After the playbook is created, we need to define all the variables used in the playbook. Create a `vars.yml` file inside the `playbooks` directory, with the following variables:

{lang="yaml"}
```
---
# Firewall configuration.
firewall_allowed_tcp_ports:
  - 22
  # For Gluster.
  - 111
  # Port-mapper for Gluster 3.4+.
  # - 2049
  # Gluster Daemon.
  - 24007
  # 24009+ for Gluster <= 3.3; 49152+ for Gluster 3.4+.
  - 24009
  - 24010
  - 49152
  - 49153
  # Gluster inline NFS server.
  - 38465
  - 38466
firewall_allowed_udp_ports:
  - 111

# Gluster configuration.
gluster_mount_dir: /mnt/gluster
gluster_brick_dir: /srv/gluster/brick
gluster_brick_name: gluster
```

This variables file should be pretty self-explanatory; all the ports required for Gluster are opened in the firewall, and the three Gluster-related variables we use in the playbook are defined.

Now that we have everything set up, the folder structure should look like this:

{lang="text",linenos=off}
```
gluster/
  playbooks/
    provision.yml
    main.yml
  inventory
  Vagrantfile
```

Change directory into the `gluster` directory, and run `vagrant up`. After a few minutes, provisioning should have completed successfully. To ensure Gluster is working properly, you can run the following two commands, which should give information about Gluster's peer connections and the configured `gluster` volume:

{lang="text",linenos=off}
```
$ ansible gluster -i inventory -a "gluster peer status" -b
192.168.56.2 | success | rc=0 >>
Number of Peers: 1

Hostname: 192.168.56.3
Port: 24007
Uuid: 1340bcf1-1ae6-4e55-9716-2642268792a4
State: Peer in Cluster (Connected)

192.168.56.3 | success | rc=0 >>
Number of Peers: 1

Hostname: 192.168.56.2
Port: 24007
Uuid: 63d4a5c8-6b27-4747-8cc1-16af466e4e10
State: Peer in Cluster (Connected)
```

{lang="text",linenos=off}
```
$ ansible gluster -i inventory -a "gluster volume info" -b
192.168.56.3 | SUCCESS | rc=0 >>

Volume Name: gluster
Type: Replicate
Volume ID: b75e9e45-d39b-478b-a642-ccd16b7d89d8
Status: Started
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: 192.168.56.2:/srv/gluster/brick
Brick2: 192.168.56.3:/srv/gluster/brick

192.168.56.2 | SUCCESS | rc=0 >>

Volume Name: gluster
Type: Replicate
Volume ID: b75e9e45-d39b-478b-a642-ccd16b7d89d8
Status: Started
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: 192.168.56.2:/srv/gluster/brick
Brick2: 192.168.56.3:/srv/gluster/brick
```

You can also do the following to confirm that files are being replicated/distributed correctly:

  1. Log into the first server: `vagrant ssh gluster1`
  2. Create a file in the mounted gluster volume: `sudo touch /mnt/gluster/test`
  3. Log out of the first server: `exit`
  4. Log into the second server: `vagrant ssh gluster2`
  5. List the contents of the gluster directory: `ls /mnt/gluster`

You should see the `test` file you created in step 2; this means Gluster is working correctly!

### Summary

Deploying distributed file systems like Gluster can seem challenging, but Ansible simplifies the process, and more importantly, does so idempotently; each time you run the playbook again, it will ensure everything stays configured as you've set it.

This example Gluster configuration can be found in its entirety on GitHub, in the [Gluster example](https://github.com/geerlingguy/ansible-for-devops/tree/master/gluster) directory.

## Mac Provisioning with Ansible and Homebrew

The next example will be specific to the Mac, but the principle behind it applies universally. How many times have you wanted to hit the 'reset' button on your day-to-day workstation or personal computer? How much time do you spend automating configuration and testing of applications and infrastructure at your day job, and how little do you spend automating your *own* local environment?

Over the past few years, as I've gone through four Macs (one personal, three employer-provided), I decided to start fresh on each new Mac (rather than transfer all my cruft from my old Mac to my new Mac through Apple's Migration Assistant). I had a problem, though; I had to spend at least 4-6 hours on each Mac, downloading, installing, and configuring everything. And I had another problem---since I actively used at least two separate Macs, I had to manually install and configure new software on both Macs whenever I wanted to try a new tool.

To restore order to this madness, I wrapped up all the configuration I could into a set of [dotfiles](https://github.com/geerlingguy/dotfiles) and used git to synchronize the dotfiles to all my workstations.

However, even with the assistance of [Homebrew](http://brew.sh/), an excellent package manager for macOS, there was still a lot of manual labor involved in installing and configuring my favorite apps and command line tools.

### Running Ansible playbooks locally

We saw examples of running playbooks with `connection: local` earlier while provisioning virtual machines in the cloud through our local workstation. But in fact, you can perform _any_ Ansible task using a local connection. This is how we will configure our local workstation, using Ansible.

I usually begin building a playbook by adding the basic scaffolding first, then filling in details as I go. You can follow along by creating the playbook `main.yml` with:

{lang="yaml"}
```
---
- hosts: localhost
  user: jgeerling
  connection: local

  vars_files:
    - vars/main.yml

  roles: []

  tasks: []
```

We'll store any variables we need in the included `vars/main.yml` file. The `user` is set to my local user account (in this case, `jgeerling`), so file permissions are set for my account, and tasks are run under my own account in order to minimize surprises.

T> If certain tasks need to be run with sudo privileges, you can add `become: yes` to the task, and either run the playbook with `--ask-sudo-pass` (in which case, Ansible will prompt you for your sudo password before running the playbook) or run the playbook normally, and wait for Ansible to prompt you for your sudo password.

### Automating Homebrew package and app management

Since I use Homebrew (billed as "the missing package manager for macOS") for most of my application installation and configuration, I created the role `geerlingguy.homebrew`, which first installs Homebrew and then installs all the applications and packages I configure in a few simple variables.

The next step, then, is to add the Homebrew role and configure the required variables. Inside `main.yml`, update the `roles` section:

{lang="yaml",starting-line-number=9}
```
  roles:
    - geerlingguy.homebrew
```

Then add the following into `vars/main.yml`:

{lang="yaml"}
```
---
homebrew_installed_packages:
  - sqlite
  - mysql
  - php
  - python
  - ssh-copy-id
  - cowsay
  - pv
  - wget
  - brew-cask

homebrew_taps:
  - homebrew/core
  - homebrew/cask

homebrew_cask_appdir: /Applications
homebrew_cask_apps:
  - docker
  - google-chrome
  - sequel-pro
  - slack
```

Homebrew has a few tricks up its sleeve, like being able to manage general packages like PHP, MySQL, Python, Pipe Viewer, etc. natively (using commands like `brew install [package]` and `brew uninstall package`), and can also install and manage general application installation for many Mac apps, like Chrome, Firefox, VLC, etc. using `brew cask`.

To anyone who's set up a new Mac the old-fashioned way---download 15 .dmg files, mount them, drag the applications to the Applications folder, eject them, delete the .dmg files---Homebrew's simplicity and speed are a true godsend. This Ansible playbook has so far automated that process completely, so you don't even have to run the Homebrew commands manually! The `geerlingguy.homebrew` role uses Ansible's built-in `homebrew` module to manage package installation, along with some custom tasks to manage cask applications.

### Configuring macOS through dotfiles

Just like there's a `homebrew` role on Ansible Galaxy, made for configuring and installing packages via Homebrew, there's a `dotfiles` role you can use to download and configure your local dotfiles.

I> Dotfiles are named as such because they are files in your home directory that begin with a `.`. Many programs and shell environments read local configuration from dotfiles, so dotfiles are a simple, efficient, and easily-synchronized method of customizing your development environment for maximum efficiency.

In this example, we'll use the author's dotfiles, but you can tell the role to use whatever set of dotfiles you want.

Add another role to the `roles` list:

{lang="yaml",starting-line-number=9}
```
  roles:
    - geerlingguy.homebrew
    - geerlingguy.dotfiles
```

Then, add the following three variables to your `vars/main.yml` file:

{lang="yaml",starting-line-number=2}
```
dotfiles_repo: https://github.com/geerlingguy/dotfiles.git
dotfiles_repo_local_destination: ~/repositories/dotfiles
dotfiles_files:
  - .bash_profile
  - .gitignore
  - .inputrc
  - .osx
  - .vimrc
```

The first variable gives the git repository URL for the dotfiles to be cloned. The second gives a local path for the repository to be stored, and the final variable tells the role which dotfiles it should use from the specified repository.

The `dotfiles` role clones the specified dotfiles repository locally, then symlinks every one of the dotfiles specified in `dotfiles_files` into your home folder (removing any existing dotfiles of the same name).

If you want to run the `.osx` dotfile, which adjusts many system and application settings, add in a new task under the `tasks` section in the main playbook:

{lang="yaml",starting-line-number=13}
```
  tasks:
    - name: Run .osx dotfiles.
      shell: ~/.osx --no-restart
      changed_when: false
```

In this case, the `.osx` dotfile allows a `--no-restart` flag to be passed to prevent the script from restarting certain apps and services including Terminal---which is good, since you'd likely be running the playbook from within Terminal.

At this point, you already have the majority of your local environment set up. Copying additional settings and tweaking things further is an exercise in adjusting your dotfiles or including another playbook that copies or links preference files into the right places.

I'm constantly tweaking my own development workstation, and for the most part, all my configuration is wrapped up in my [Mac Development Ansible Playbook](https://github.com/geerlingguy/mac-dev-playbook), available on GitHub. I'd encourage you to fork that project, as well as my dotfiles, if you'd like to get started automating the build of your own development workstation. Even if you don't use a Mac, most of the structure is similar; just substitute a different package manager, and start automating!

### Summary

Ansible is the best way to automate infrastructure provisioning and configuration. Ansible can also be used to configure your own workstation, saving you the time and frustration it takes to do so yourself. Unfortunately, you can't yet provision yourself a new top-of-the-line workstation with Ansible!

You can find the full playbook I'm currently using to configure my Macs on GitHub: [Mac Development Ansible Playbook](https://github.com/geerlingguy/mac-dev-playbook).

{lang="text",linenos=off}
```
 ________________________________
/ Do or do not. There is no try. \
\ (Yoda)                         /
 --------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
