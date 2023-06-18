# Chapter 2 - Local Infrastructure Development: Ansible and Vagrant

## Prototyping and testing with local virtual machines

Ansible works well with any server to which you can connect---remote *or* local. For speedier testing and development of Ansible playbooks, and for testing in general, it's a very good idea to work locally. Local development and testing of infrastructure is both safer and faster than doing it on remote/live machines---especially in production environments!

I> In the past decade, test-driven development (TDD), in one form or another, has become the norm for much of the software industry. Infrastructure development hasn't been as organized until recently, and best practices dictate that infrastructure (which is becoming more and more important to the software that runs on it) should be thoroughly tested as well.
I> 
I> Changes to software are tested either manually or in some automated fashion; there are now systems that integrate both with Ansible and with other deployment and configuration management tools, to allow some amount of infrastructure testing as well. Even if it's just testing a configuration change locally before applying it to production, that approach is a thousand times better than what, in the software development world, would be called 'cowboy coding'---working directly in a production environment, not documenting or encapsulating changes in code, and not having a way to roll back to a previous version.

The past decade has seen the growth of many virtualization tools that allow for flexible and very powerful infrastructure emulation, all from your local workstation! It's empowering to be able to play around with a config file, or to tweak the order of a server update to perfection, over and over again, with no fear of breaking an important server. If you use a local virtual machine, there's no downtime for a server rebuild; just re-run the provisioning on a new VM, and you're back up and running in minutes---with no one the wiser.

[Vagrant](https://www.vagrantup.com), a server provisioning tool, and [VirtualBox](https://www.virtualbox.org/), a local virtualization environment, make a potent combination for testing infrastructure and individual server configurations locally. Both applications are free and open source, and work well on Mac, Linux, or Windows hosts.

We're going to set up Vagrant and VirtualBox for easy testing with Ansible to provision a new server.

## Your first local server: Setting up Vagrant

To get started with your first local virtual server, you need to download and install Vagrant and VirtualBox, and set up a simple Vagrantfile, which will describe the virtual server.

  1. Download and install Vagrant and VirtualBox (whichever version is appropriate for your OS):
    - [Download Vagrant](https://www.vagrantup.com/downloads.html)
    - [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads) (when installing, make sure the command line tools are installed, so Vagrant works with it)
  2. Create a new folder somewhere on your hard drive where you will keep your Vagrantfile and provisioning instructions.
  3. Open a Terminal or PowerShell window, then navigate to the folder you just created.
  4. Add a Rocky Linux 8.x 64-bit 'box' using the [`vagrant box add`](https://www.vagrantup.com/docs/boxes.html) command:
    `vagrant box add geerlingguy/rockylinux8`
    (note: HashiCorp's [Vagrant Cloud](https://app.vagrantup.com/boxes/search) has a comprehensive list of different pre-made Linux boxes. Also, check out the 'official' Vagrant Ubuntu boxes in Vagrant's [Boxes documentation](https://www.vagrantup.com/docs/boxes.html).
  5. Create a default virtual server configuration using the box you just downloaded:
    `vagrant init geerlingguy/rockylinux8`
  6. Boot your Rocky Linux server:
    `vagrant up`

Vagrant downloaded a pre-built 64-bit Rocky Linux 8 virtual machine image (you can [build your own](https://www.vagrantup.com/docs/providers/virtualbox/boxes.html) virtual machine 'boxes', if you so desire), loaded the image into VirtualBox with the configuration defined in the default Vagrantfile (which is now in the folder you created earlier), and booted the virtual machine.

Managing this virtual server is extremely easy: `vagrant halt` will shut down the VM, `vagrant up` will bring it back up, and `vagrant destroy` will completely delete the machine from VirtualBox. A simple `vagrant up` again will re-create it from the base box you originally downloaded.

Now that you have a running server, you can use it just like you would any other server, and you can connect via SSH. To connect, enter `vagrant ssh` from the folder where the Vagrantfile is located. If you want to connect manually, or connect from another application, enter `vagrant ssh-config` to get the required SSH details.

## Using Ansible with Vagrant

Vagrant's ability to bring up preconfigured boxes is convenient on its own, but you could do similar things with the same efficiency using VirtualBox's (or VMWare's, or Parallels') GUI. Vagrant has some other tricks up its sleeve:

  - [**Network interface management**](https://www.vagrantup.com/docs/networking): You can forward ports to a VM, share the public network connection, or use private networking for inter-VM and host-only communication.
  - [**Shared folder management**](https://www.vagrantup.com/docs/synced-folders): Vagrant sets up shares between your host machine and VMs using NFS or (much slower) native folder sharing in VirtualBox.
  - [**Multi-machine management**](https://www.vagrantup.com/docs/multi-machine): Vagrant is able to configure and control multiple VMs within one Vagrantfile. This is important because, as stated in the documentation, "Historically, running complex environments was done by flattening them onto a single machine. The problem with that is that it is an inaccurate model of the production setup, which behaves far differently."
  - [**Provisioning**](https://www.vagrantup.com/docs/provisioning): When running `vagrant up` the first time, Vagrant automatically *provisions* the newly-minted VM using whatever provisioner you have configured in the Vagrantfile. You can also run `vagrant provision` after the VM has been created to explicitly run the provisioner again.

It's this last feature that is most important for us. Ansible is one of many provisioners integrated with Vagrant (others include basic shell scripts, Chef, Docker, Puppet, and Salt). When you call `vagrant provision` (or `vagrant up` the first time), Vagrant passes off the VM to Ansible, and tells Ansible to run a defined Ansible playbook. We'll get into the details of Ansible playbooks later, but for now, we're going to edit our Vagrantfile to use Ansible to provision our virtual machine.

Open the Vagrantfile that was created when we used the `vagrant init` command earlier. Add the following lines just before the final 'end' (Vagrantfiles use Ruby syntax, in case you're wondering):

{lang="ruby"}
```
# Provisioning configuration for Ansible.
config.vm.provision "ansible" do |ansible|
  ansible.playbook = "playbook.yml"
end
```

This is a very basic configuration to get you started using Ansible with Vagrant. There are [many other Ansible options](https://www.vagrantup.com/docs/provisioning/ansible_intro) you can use once we get deeper into using Ansible. For now, we just want to set up a very basic playbook---a simple file you create to tell Ansible how to configure your VM.

## Your first Ansible playbook

Let's create the Ansible `playbook.yml` file now. Create an empty text file in the same folder as your Vagrantfile, and put in the following contents:

{lang="yaml"}
```
---
- hosts: all
  become: yes

  tasks:
  - name: Ensure chrony (for time synchronization) is installed.
    dnf:
      name: chrony
      state: present

  - name: Ensure chrony is running.
    service:
      name: chronyd
      state: started
      enabled: yes
```

I'll get into what this playbook is doing in a minute. For now, let's run the playbook on our VM. Make sure you're in the same directory as the Vagrantfile and new playbook.yml file, and enter `vagrant provision`. You should see status messages for each of the 'tasks' you defined, and then a recap showing what Ansible did on your VM---something like the following:

{lang="text",linenos=off}
```
PLAY RECAP **********************************************************
default              : ok=3    changed=0    unreachable=0    failed=0
```

Ansible just took the simple playbook you defined, parsed the YAML syntax, and ran a bunch of commands via SSH to configure the server as you specified. Let's go through the playbook, step by step:

{lang="yaml"}
```
---
```

This first line is a marker showing that the rest of the document will be formatted in YAML (read [an introduction to YAML](https://yaml.org/spec/1.2.2/)).

{lang="yaml",starting-line-number=2}
```
- hosts: all
```

This line tells Ansible to which hosts this playbook applies. `all` works here, since Vagrant is invisibly using its own Ansible inventory file (instead of using a manually-created `hosts.ini` file), which just defines the Vagrant VM.

{lang="yaml",starting-line-number=3}
```
  become: yes
```

Since we need privileged access to install chrony and modify system configuration, this line tells Ansible to use `sudo` for all the tasks in the playbook (you're telling Ansible to 'become' the root user with `sudo`, or an equivalent).

{lang="yaml",starting-line-number=5}
```
  tasks:
```

All the tasks after this line will be run on all hosts (or, in our case, our one VM).

{lang="yaml",starting-line-number=6}
```
  - name: Ensure chrony (for time synchronization) is installed.
    dnf:
      name: chrony
      state: present
```

This command is the equivalent of running `dnf install chrony`, but is much more intelligent; it will check if chrony is installed, and, if not, install it. This is the equivalent of the following shell script:

{lang="text",linenos=off}
```
if ! rpm -qa | grep -qw chrony; then
    dnf install -y chrony
fi
```

However, the above script is still not quite as robust as Ansible's `dnf` command. What if some other package with `chrony` in its name is installed, but not `chrony`? This script would require extra tweaking and complexity to match the simple Ansible dnf command, especially after we explore the dnf module more intimately (or the `apt` module for Debian-flavored Linux, or `package` for OS-agnostic package installation).

{lang="yaml",starting-line-number=11}
```
  - name: Ensure chrony is running.
    service:
      name: chronyd
      state: started
      enabled: yes
```

This final task both checks and ensures that the `chronyd` service is started and running, and sets it to start at system boot. A shell script with the same effect would be:

{lang="text",linenos=off}
```
# Start chronyd if it's not already running.
if ps aux | grep -q "[c]hronyd"
then
    echo "chronyd is running." > /dev/null
else
    systemctl start chronyd.service > /dev/null
    echo "Started chronyd."
fi
# Make sure chronyd is enabled on system startup.
systemctl enable chronyd.service
```

You can see how things start getting complex in the land of shell scripts! And this shell script is still not as robust as what you get with Ansible. To maintain idempotency and handle error conditions, you'll have to do even more work with basic shell scripts than you do with Ansible.

We could be more terse (and demonstrate Ansible's powerful simplicity) ignoring Ansible's self-documenting `name` parameter and shorthand `key=value` syntax, resulting in the following playbook:

{lang="yaml"}
```
---
- hosts: all
  become: yes
  tasks:
  - dnf: name=chrony state=present
  - service: name=chronyd state=started enabled=yes
```

I> Just as with code and configuration files, documentation in Ansible (e.g. using the `name` parameter and/or adding comments to the YAML for complicated tasks) is not absolutely necessary. However, I'm a firm believer in thorough (but concise) documentation, so I always document what my tasks will do by providing a `name` for each one. This also helps when you're running the playbooks, so you can see what's going on in a human-readable format.

## Cleaning Up

Once you're finished experimenting with the Rocky Linux Vagrant VM, you can remove it from your system by running `vagrant destroy`. If you want to rebuild the VM again, run `vagrant up`. If you're like me, you'll soon be building and rebuilding hundreds of VMs and containers per week using Vagrant and Ansible!

## Summary

Your workstation is on the path to becoming an "infrastructure-in-a-box," and you can now ensure your infrastructure is as well-tested as the code that runs on top of it. With one small example, you've got a glimpse at the simple-yet-powerful Ansible playbook. We'll dive deeper into Ansible playbooks later, and we'll also explore Vagrant a little more as we go.

{lang="text",linenos=off}
```
 ______________________________________
/ I have not failed, I've just found   \
| 10,000 ways that won't work. (Thomas |
\ Edison)                              /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
