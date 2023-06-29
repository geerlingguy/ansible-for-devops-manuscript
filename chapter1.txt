# Chapter 1 - Getting Started with Ansible

## Ansible and Infrastructure Management

### On snowflakes and shell scripts

Many developers and system administrators manage servers by logging into them via SSH, making changes, and logging off. Some of these changes would be documented, some would not. If an admin needed to make the same change to many servers (for example, changing one value in a config file), the admin would manually log into *each* server and repeatedly make this change.

If there were only one or two changes in the course of a server's lifetime, and if the server were extremely simple (running only one process, with one configuration, and a very simple firewall), *and* if every change were thoroughly documented, this process wouldn't be a problem.

But for almost every company in existence, servers are more complex---most run tens, sometimes hundreds of different applications or application containers. Most servers have complicated firewalls and dozens of tweaked configuration files. And even with change documentation, the manual process usually results in some servers or some steps being forgotten.

If the admins at these companies wanted to set up a new server *exactly* like one that is currently running, they would need to spend a good deal of time going through all of the installed packages, documenting configurations, versions, and settings; and they would spend a lot of unnecessary time manually reinstalling, updating, and tweaking everything to get the new server to run close to how the old server did.

Some admins may use shell scripts to try to reach some level of sanity, but I've yet to see a complex shell script that handles all edge cases correctly while synchronizing multiple servers' configuration and deploying new code.

### Configuration management

Lucky for you, there are tools to help you avoid having these *snowflake servers*---servers that are uniquely configured and impossible to recreate from scratch because they were hand-configured without documentation. Tools like [CFEngine](http://cfengine.com/), [Puppet](http://puppetlabs.com/) and [Chef](http://www.getchef.com/chef/) became very popular in the mid-to-late 2000s.

But there's a reason why many developers and sysadmins stick to shell scripting and command-line configuration: it's simple and easy-to-use, and they've had years of experience using bash and command-line tools. Why throw all that out the window and learn a new configuration language and methodology?

Enter Ansible. Ansible was built (and continues to be improved) by developers and sysadmins who know the command line---and want to make a tool that helps them manage their servers exactly the same as they have in the past, but in a repeatable and centrally managed way. Ansible also has other tricks up its sleeve, making it a true Swiss Army knife for people involved in DevOps (not just the operations side).

One of Ansible's greatest strengths is its ability to run regular shell commands verbatim, so you can take existing scripts and commands and work on converting them into idempotent playbooks as time allows. For someone (like me) who was comfortable with the command line, but never became proficient in more complicated tools like Puppet or Chef (which both required at least a *slight* understanding of Ruby and/or a custom language just to get started), Ansible was a breath of fresh air.

Ansible works by pushing changes out to all your servers (by default), and requires no extra software to be installed on your servers (thus no extra memory footprint, and no extra daemon to manage), unlike most other configuration management tools.

I> **Idempotence** is the ability to run an operation which produces the same result whether run once or multiple times ([source](http://en.wikipedia.org/wiki/Idempotence#Computer_science_meaning)).
I> 
I> An important feature of a configuration management tool is its ability to ensure the same configuration is maintained whether you run it once or a thousand times. Many shell scripts have unintended consequences if run more than once, but Ansible deploys the same configuration to a server over and over again without making any changes after the first deployment.
I> 
I> In fact, almost every aspect of Ansible modules and commands is idempotent, and for those that aren't, Ansible allows you to define when the given command should be run, and what constitutes a changed or failed command, so you can easily maintain an idempotent configuration on all your servers.

## Installing Ansible

Ansible's only real dependency is Python. Once Python is installed, the simplest way to get Ansible running is to use `pip`, a simple package manager for Python.

**If you're on a Mac**, installing Ansible is a piece of cake:

  1. Check if `pip` is installed (`which pip`). If not, install it: `sudo easy_install pip`
  2. Install Ansible: `pip install ansible`

You could also install Ansible via [Homebrew](http://brew.sh/) with `brew install ansible`. Either way (`pip` or `brew`) is fine, but make sure you update Ansible using the same system with which it was installed!

**If you're running Windows**, it will take a little extra work to set everything up. Typically, people run Ansible inside the Windows Subsystem for Linux. For detailed instructions setting up Ansible under the WSL, see [Appendix A - Using Ansible on Windows workstations](#appendix-a).

**If you're running Linux**, chances are you already have Ansible's dependencies installed, but we'll cover the most common installation methods.

If you have `python-pip` and `python-devel` (`python-dev` on Debian/Ubuntu) installed, use `pip` to install Ansible (this assumes you also have the 'Development Tools' package installed, so you have `gcc`, `make`, etc. available):

{lang="text",linenos=off}
```
$ pip install ansible
```

Using pip allows you to upgrade Ansible with `pip install --upgrade ansible`.

### Fedora/Red Hat Enterprise Linux

The easiest way to install Ansible on an RPM-based OS is to use the official dnf package. If you're running Red Hat Enterprise Linux (RHEL) or CentOS/Rocky/Alma Linux, you need to install EPEL's RPM before you install Ansible (see the info section below for instructions):

{lang="text",linenos=off}
```
$ dnf -y install ansible
```

I> On RPM-based systems, `python-pip` and `ansible` are available via the [EPEL repository](https://fedoraproject.org/wiki/EPEL). If you run the command `dnf repolist | grep epel` (to see if the EPEL repo is already available) and there are no results, you need to install it with the following commands:
I>
I> {lang="text",linenos=off}
I> ~~~
I> # If you're on RHEL/CentOS 6:
I> $ rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/\
I> epel-release-6-8.noarch.rpm
I> # If you're on RHEL/CentOS 7:
I> $ yum install epel-release
I> # If you're on RHEL 8+/Fedora:
I> $ dnf install epel-release
I> ~~~

### Debian/Ubuntu

The easiest way to install Ansible on a Debian or Ubuntu system is to use the official apt package.

{lang="text",linenos=off}
```
$ sudo apt-add-repository -y ppa:ansible/ansible
$ sudo apt-get update
$ sudo apt-get install -y ansible
```

I> If you get an error like "sudo: add-apt-repository: command not found", you're probably missing the `software-properties-common` package. Install it with the command:
I>
I> {lang="text",linenos=off}
I> ~~~
I> $ sudo apt-get install software-properties-common
I> ~~~

**Once Ansible is installed**, make sure it's working properly by entering `ansible --version` on the command line. You should see the currently-installed version information:

{lang="text",linenos=off}
```
$ ansible --version
ansible [core 2.14.6]
  ...
  python version = 3.10.11
  jinja version = 3.1.2
  libyaml = True
```

I> **What about Python 3?** If you have both Python 2 and Python 3 installed, and `pip` is aliased to an older Python 2 version of `pip`, you should consider installing Python 3 and `pip3`, and using that version instead. Ansible is fully compatible with Python 3, and unless you're running on a very old system that doesn't have Python 3 available for it, you should use Python 3.

## Creating a basic inventory file {#basic-inventory}

Ansible uses an inventory file (basically, a list of servers) to communicate with your servers. Like a hosts file (at `/etc/hosts`) that matches IP addresses to domain names, an Ansible inventory file matches servers (IP addresses or domain names) to groups. Inventory files can do a lot more, but for now, we'll just create a simple file with one server. Create a file named `hosts.ini` in a test project folder:

{lang="text",linenos=off}
```
$ mkdir test-project
$ cd test-project
$ touch hosts.ini
```

T> Inventory file names do not have to follow any particular naming convention. I often use the file name `hosts.ini` for Ansible's default 'ini-style' syntax, but I also sometimes call the file `inventory` (with no file extension).

Edit this hosts file with nano, vim, or whatever editor you'd like. Put the following into the file:

{lang="text"}
```
[example]
www.example.com
```

...where `example` is the group of servers you're managing and `www.example.com` is the domain name (or IP address) of a server in that group. If you're not using port 22 for SSH on this server, you will need to add it to the address, like `www.example.com:2222`, since Ansible defaults to port 22 and won't get this value from your ssh config file.

I> This first example assumes you have a server set up that you can test with; if you don't already have a spare server somewhere that you can connect to, you might want to create a small VM using DigitalOcean, Amazon Web Services, Linode, or some other service that bills by the hour. That way you have a full server environment to work with when learning Ansible---and when you're finished testing, delete the server and you'll only be billed a few pennies!
I>
I> Replace the `www.example.com` in the above example with the name or IP address of your server.

T> You can also place your inventory in Ansible's global inventory file, `/etc/ansible/hosts`, and any playbook will default to that if no other inventory is specified. However, that file requires `sudo` permissions and it is usually better to maintain inventory alongside your Ansible projects.

## Running your first Ad-Hoc Ansible command

Now that you've installed Ansible and created an inventory file, it's time to run a command to see if everything works! Enter the following in the terminal (we'll do something safe so it doesn't make any changes on the server):

{lang="text",linenos=off}
```
$ ansible -i hosts.ini example -m ping -u [username]
```

...where `[username]` is the user you use to log into the server. If everything worked, you should see a message that shows `www.example.com | SUCCESS >>`, then the result of your ping. If it didn't work, run the command again with `-vvvv` on the end to see verbose output. Chances are you don't have SSH keys configured properly---if you login with `ssh username@www.example.com` and that works, the above Ansible command should work, too.

W> Ansible assumes you're using passwordless (key-based) login for SSH (e.g. you login by entering `ssh username@example.com` and don't have to type a password). If you're still logging into your remote servers with a username and password, or if you need a primer on Linux remote authentication and security best practices, please read [Chapter 11 - Server Security and Ansible](#chapter-11). If you insist on using passwords, add the `--ask-pass` (`-k`) flag to Ansible commands (you may also need to install the `sshpass` package for this to work). This entire book is written assuming passwordless authentication, so you'll need to keep this in mind every time you run a command or playbook.

T> Need a primer on SSH key-based authentication? Please read through Ubuntu's community documentation on [SSH/OpenSSH/Keys](https://help.ubuntu.com/community/SSH/OpenSSH/Keys).

Let's run a more useful command:

{lang="text",linenos=off}
```
$ ansible -i hosts.ini example -a "free -h" -u [username]
```

In this example, we quickly see memory usage (in a human-readable format) on all the servers (for now, just one) in the `example` group. Commands like this are helpful for quickly finding a server that has a value out of a normal range. I often use commands like `free -h` (to see memory statistics), `df -h` (to see disk usage statistics), and the like to make sure none of my servers is behaving erratically. While it's good to track these details in an external tool like [Nagios](http://www.nagios.org/), [Munin](http://munin-monitoring.org/), or [Cacti](http://www.cacti.net/), it's also nice to check these stats on all your servers with one simple command and one terminal window!

## Summary

That's it! You've just learned about configuration management and Ansible, installed it, told it about your server, and ran a couple commands on that server through Ansible. If you're not impressed yet, that's okay---you've only seen the *tip* of the iceberg.

{lang="text",linenos=off}
```
 _______________________________________
/ A doctor can bury his mistakes but an \
| architect can only advise his clients |
\ to plant vines. (Frank Lloyd Wright)  /
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
