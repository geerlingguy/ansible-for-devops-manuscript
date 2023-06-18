# Chapter 15 - Docker and Ansible

Docker is a highly optimized platform for building and running containers on local machines and servers in a highly efficient manner. You can think of Docker containers as sort-of lightweight virtual machines. This book won't go into the details of how Docker and Linux containers work, but will provide an introduction to how Ansible can integrate with Docker to build, manage, and deploy containers.

I> Prior to running example Docker commands or building and managing containers using Ansible, you'll need to make sure Docker is installed either on your workstation or a VM or server where you'll be testing everything. Please see the [installation guide for Docker](https://docs.docker.com/installation/) for help installing Docker on whatever platform you're using.

## A brief introduction to Docker containers

Starting with an extremely simple example, let's build a Docker image from a Dockerfile. In this case, we want to show how Dockerfiles work and how we can use Ansible to build the image in the same way as if we were to use the command line with `docker build`.

Let's start with a Dockerfile:

{lang="docker"}
```
# Build an example Docker container image.
FROM busybox
LABEL maintainer="Jeff Geerling"

# Run a command when the container starts.
CMD ["/bin/true"]
```

This Docker container doesn't do much, but that's okay; we just want to build it and verify that it's present and working---first with Docker, then with Ansible.

Save the above file as `Dockerfile` inside a new directory, and then on the command line, run the following command to build the container:

{lang="text",linenos=off}
```
$ docker build -t test .
```

After a few seconds, the Docker image should be built, and if you list all local images with `docker image`, you should see your new test image (along with the busybox image, which was used as a base):

{lang="text",linenos=off}
```
$ docker images
REPOSITORY  TAG     IMAGE ID      CREATED             VIRTUAL SIZE
test        latest  50d6e6479bc7  About a minute ago  2.433 MB
busybox     latest  4986bf8c1536  2 weeks ago         2.433 MB
```

If you want to run the container image you just created, enter the following:

{lang="text",linenos=off}
```
$ docker run --name=test test
```

This creates a Docker container with the name `test`, and starts the container. Since the only thing our container does is calls `/bin/true`, the container will run the command, then exit. You can see the current status of all your containers (whether or not they're actively running) with the `docker ps -a` command:

{lang="text",linenos=off}
```
$ docker ps -a
CONTAINER ID  IMAGE        [...]  CREATED        STATUS
bae0972c26d4  test:latest  [...]  3 seconds ago  Exited (0) 2s ago
```

You can control the container using either the container ID (in this case, `bae0972c26d4`) or the name (`test`); start with `docker start [container]`, stop with `docker stop [container]`, delete/remove with `docker rm [container]`.

If you delete the container (`docker rm test`) and the image you built (`docker rmi test`), you can experiment with the Dockerfile by changing it and rebuilding the image with `docker build`, then running the resulting image with `docker run`. For example, if you change the command from `/bin/true` to `/bin/false`, then run build and run the container, `docker ps -a` will show the container exited with the status code `1` instead of `0`.

For our purposes, this is a good introduction to how Docker works. To summarize:

  - Dockerfiles contain the instructions Docker uses to build containers.
  - `docker build` builds Dockerfiles and generates container images.
  - `docker images` lists all images present on the system.
  - `docker run` runs created images.
  - `docker ps -a` lists all containers, both running and stopped.

When developing Dockerfiles to containerize your own applications, you will likely want to get familiar with the Docker CLI and how the process works from a manual perspective. But when building the final images and running them on your servers, Ansible can help ease the process.

## Using Ansible to build and manage containers

Ansible has built-in Docker modules that integrate nicely with Docker for container management. We're going to use them to automate the building and running of the container (managed by the Dockerfile) we just created.

Move the Dockerfile you had into a subdirectory, and create a new Ansible playbook (call it `main.yml`) in the project root directory. The directory layout should look like:

{lang="text",linenos=off}
```
docker/
  main.yml
  test/
    Dockerfile
```

Inside the new playbook, add the following:

{lang="yaml"}
```
---
- hosts: localhost
  connection: local

  tasks:
    - name: Ensure Docker image is built from the test Dockerfile.
      docker_image:
        name: test
        source: build
        build:
          path: test
        state: present
```

The playbook uses the `docker_image` module to build an image. Provide a name for the image, tell Ansible the source for the image is a `build`, then provide the path to the Dockerfile in the `build` parameters (in this case, inside the `test` directory). Finally, tell Ansible via the `state` parameter the image should be `present`, to ensure it is built and available.

I> Ansible's Docker integration may require you to install an extra Docker python library on the system running the Ansible playbook. For example, on ArchLinux, if you get the error "failed to import Python module", you will need to install the `python2-docker` package. On other distributions, you may need to install the `docker` Python library via Pip (`pip install docker`).

Run the playbook (`$ ansible-playbook main.yml`), and then list all the Docker images (`$ docker images`). If all was successful, you should see a fresh `test` image in the list.

Run `docker ps -a` again, though, and you'll see the new `test` image was never run and is absent from the output. Let's remedy that by adding another task to our Ansible playbook:

{lang="yaml",starting-line-number=12}
```
    - name: Ensure the test container is running.
      docker_container:
        image: test:latest
        name: test
        state: started
```

If you run the playbook again, Ansible will start the Docker container. Check the list of containers with `docker ps -a`, and you'll note the `test` container is again present.

You can remove the container and the image via ansible by changing the `state` parameter to `absent` for both tasks.

T> This playbook assumes you have both Docker and Ansible installed on whatever host you're using to test Docker containers. If this is not the case, you may need to modify the example so the Ansible playbook is targeting the correct `hosts` and using the right connection settings. Additionally, if the user account under which you run the playbook can't run `docker` commands, you may need to use `become` with this playbook.

I> The code example above can be found in the [Ansible for DevOps GitHub repository](https://github.com/geerlingguy/ansible-for-devops/tree/master/docker).

## Building a Flask app with Ansible and Docker

Let's build a more useful Docker-powered environment, with a container that runs our application (built with Flask, a lightweight Python web framework), and a container that runs a database (MySQL), along with a data container. We need a separate data container to persist the MySQL database, because data changed inside the MySQL container is lost every time the container stops.

{width=60%}
![Docker stack for Flask App](images/15-flask-docker-stack.png)

We'll create a VM using Vagrant to run our Docker containers so the same Docker configuration can be tested on any machine capable of running Ansible and Vagrant. Create a `docker` folder, and inside it, the following `Vagrantfile`:

{lang="ruby"}
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.network :private_network, ip: "192.168.56.39"
  config.ssh.insert_key = false

  config.vm.hostname = "docker-flask.test"
  config.vm.provider :virtualbox do |v|
    v.name = "docker-flask.test"
    v.memory = 1024
    v.cpus = 2
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Enable provisioning with Ansible.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/main.yml"
  end

end
```

We'll use Ubuntu for this example, and we've specified an `ansible.playbook` to set everything up. Inside `provisioning/main.yml`, we need to first install and configure Docker (which we'll do using the Ansible Galaxy role `geerlingguy.docker`), then run some additional setup tasks, and finally build and start the required Docker containers:

{lang="yaml"}
```
---
- hosts: all
  become: true

  vars:
    build_root: /vagrant/provisioning

  pre_tasks:
    - name: Update apt cache if needed.
      apt: update_cache=yes cache_valid_time=3600

  roles:
    - role: geerlingguy.docker

  tasks:
    - import_tasks: setup.yml
    - import_tasks: docker.yml
```

We're using `sudo` for everything because Docker either requires root privileges, or requires the current user account to be in the `docker` group. It's simplest for our purposes to set everything up with `sudo` by setting `become: true`.

We also set a `build_root` variable that we'll use later on to tell Docker to build the containers inside the VM using the default shared Vagrant volume.

The `geerlingguy.docker` role requires no additional settings or configuration, but it does need to be installed with `ansible-galaxy`, so add a `requirements.yml`:

{lang="yaml"}
```
roles:
  - name: geerlingguy.docker
```

And make sure the role is installed:

{lang="text",linenos=off}
```
$ ansible-galaxy install -r requirements.yml
```

Next, create `setup.yml` in the same `provisioning` directory alongside `main.yml`:

{lang="yaml"}
```
---
- name: Install Pip.
  apt: name=python3-pip state=present

- name: Install Docker Python library.
  pip: name=docker state=present
```

Ansible needs the `docker` Python library in order to control Docker via Python, so we install `pip`, then use it to install `docker`.

Next is the meat of the playbook: `docker.yml` (also in the `provisioning` directory). The first task is to build Docker images for our data, application, and database containers:

{lang="yaml"}
```
---
- name: Build Docker images from Dockerfiles.
  docker_image:
    name: "{{ item.name }}"
    tag: "{{ item.tag }}"
    source: build
    build:
      path: "{{ build_root }}/{{ item.directory }}"
      pull: false
    state: present
  with_items:
    - { name: data, tag: latest, directory: data }
    - { name: flask, tag: latest, directory: www }
    - { name: db, tag: latest, directory: db }
```

Don't worry that we haven't yet created the actual Dockerfiles required to create the Docker images; we'll do that after we finish structuring everything with Ansible.

Like our earlier usage of `docker_image`, we supply a `name`, `build.path`, and `source` for each image. In this example, we're also adding a `tag`, which behaves like a git tag, allowing future Docker commands to use the images we created at a specific version. We'll be building three containers, `data`, `flask`, and `db`, and we're pointing Docker to the path `/vagrant/provisioning/[directory]`, where `[directory]` contains the Dockerfile and any other helpful files to be used to build the Docker image.

After building the images, we will need to start each of them (or at least make sure a container is *present*, in the case of the `data` container---since you can use data volumes from non-running containers). We'll do that in three separate `docker_container` tasks:

{lang="yaml",starting-line-number=16}
```
# Data containers don't need to be running to be utilized.
- name: Run a Data container.
  docker_container:
    image: data:latest
    name: data
    state: present

- name: Run a Flask container.
  docker_container:
    image: www:latest
    name: www
    state: started
    command: python /opt/www/index.py
    ports: "80:80"

- name: Run a MySQL container.
  docker_container:
    image: db:latest
    name: db
    state: started
    volumes_from: data
    ports: "3306:3306"
    env:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: flask
      MYSQL_USER: flask
      MYSQL_PASSWORD: flask
```

Each of these containers' configuration is a little more involved than the previous. In the case of the first container, it's just `present`; Ansible will ensure a `data` container is present.

For the Flask container, we need to make sure our app is not only running, but *continues* to run. So, unlike our earlier usage of `/bin/true` to run a container briefly and exit, in this case we will provide an explicit command to run:

{lang="yaml",starting-line-number=25}
```
    command: python /opt/www/index.py
```

Calling the script directly will launch the app in the foreground and log everything to stdout, making it easy to inspect what's going on with `docker logs [container]` if needed.

Additionally, we want to map the container's port 80 to the host's port 80, so external users can load pages over HTTP. This is done using the `ports` option, passing data just as you would using Docker's `--publish` syntax.

The Flask container will have a static web application running on it, and has no need for extra non-transient file storage, but the MySQL container will mount a data volume from the `data` container, so it has a place to store data that won't vanish when the container dies and is restarted.

Thus, for the `db` container, we a special options: the `volumes_from` option mounts volumes from the specified container (in this case, the `data` container).

Now that we have the playbook structured to build our Docker-based infrastructure, we'll build out each of the three Dockerfiles and related configuration to support the `data`, `www`, and `db` containers.

At this point, we should have a directory structure like:

{lang="text",linenos=off}
```
docker/
  provisioning/
    data/
    db/
    www/
    docker.yml
    main.yml
    setup.yml
  Vagrantfile
```

W> It's best to use lightweight base images without any extra frills instead of heavyweight 'VM-like' images. Additionally, lightweight server environments where containers are built and run, like Fedora CoreOS, don't need the baggage of a standard Linux distribution. If you need Ansible available for configuration and container management in such an environment, you also need to have Python and other dependencies installed.

### Data storage container

For the data storage container, we don't need much; we just need to create a directory and set it as an exposed mount point using `VOLUME`:

{lang="docker"}
```
# Build a simple MySQL data volume Docker container.
FROM busybox
MAINTAINER Jeff Geerling <geerlingguy@mac.com>

# Create data volume for MySQL.
RUN mkdir -p /var/lib/mysql
VOLUME /var/lib/mysql
```

We create a directory (line 6), and expose the directory as a volume (line 7) which can be mounted by the host or other containers. Save the above into a new file, `docker/provisioning/data/Dockerfile`.

T> This container builds on top of the official `busybox` base image. Busybox is an extremely simple distribution that is Linux-like but does not contain every option or application generally found in popular distributions like Debian, Ubuntu, or RHEL. Since we only need to create and share a directory, we don't need any additional 'baggage' inside the container. In the Docker world, it's best to use the most minimal base images possible, and to only install and run the bare necessities inside each container to support the container's app.

### Flask container

[Flask](https://palletsprojects.com/p/flask/) is a lightweight Python web framework "based on Werkzeug, Jinja 2 and good intentions". It's a great web framework for small, fast, and robust websites and apps, or even an API. For our purposes, we need to build a Flask app that connects to a MySQL database and displays the status of the connection on a basic web page (very much like our PHP example, in the earlier Highly-Available Infrastructure example).

Here's the code for the Flask app (save it as `docker/provisioning/www/index.py.j2`):

{lang="python"}
```
# Infrastructure test page.
from flask import Flask
from flask import Markup
from flask import render_template
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

app = Flask(__name__)

# Configure MySQL connection.
db_uri = 'mysql://flask:flask@{{ host_ip_address }}/flask'
app.config['SQLALCHEMY_DATABASE_URI'] = db_uri
db = SQLAlchemy(app)

@app.route("/")
def test():
    mysql_result = False
    try:
        query = text('SELECT 1')
        result = db.engine.execute(query)
        if [row[0] for row in result][0] == 1:
            mysql_result = True
    except:
        pass

    if mysql_result:
        result = Markup('<span style="color: green;">PASS</span>')
    else:
        result = Markup('<span style="color: red;">FAIL</span>')

    # Return the page with the result.
    return render_template('index.html', result=result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

This app defines one route (`/`), listens on every interface on port 80, and shows a MySQL connection status page rendered by the template `index.html`. There's nothing particularly complicated in this application, but there is one Jinja variable (`{{ host_ip_address }}`) which an Ansible playbook will replace during deployment, and the app has a few dependencies (like `flask-sqlalchemy`) which will need to be installed via the Dockerfile.

Since we are using a Jinja template to render the page, let's create that template in `docker/provisioning/www/templates/index.html` (Flask automatically picks up any templates inside a `templates` directory):

{lang="html"}
```
<!DOCTYPE html>
<html>
<head>
  <title>Flask + MySQL Docker Example</title>
  <style>* { font-family: Helvetica, Arial, sans-serif }</style>
</head>
<body>
  <h1>Flask + MySQL Docker Example</h1>
  <p>MySQL Connection: {{ result }}</p>
</body>
</html>
```

In this case, the `.html` template contains a Jinja variable (`{{ result }}`), and Flask will fill in the variable with the status of the MySQL connection.

Now that we have the app defined, we need to build the container to run the app. Here is a Dockerfile that will install all the required dependencies, then copy an Ansible playbook and the app itself into place so we can do the more complicated configuration (like copying a template with variable replacement) through Ansible:

{lang="docker"}
```
# A simple Flask app container.
FROM geerlingguy/docker-ubuntu2004-ansible
MAINTAINER Jeff Geerling <geerlingguy@mac.com>

# Install Flask app dependencies.
RUN apt-get update
RUN apt-get install -y libmysqlclient-dev build-essential \
  python3-dev python3-pip
RUN pip3 install flask flask-sqlalchemy mysqlclient

# Install playbook and run it.
COPY playbook.yml /etc/ansible/playbook.yml
COPY index.py.j2 /etc/ansible/index.py.j2
COPY templates /etc/ansible/templates
RUN mkdir -m 755 /opt/www
RUN ansible-playbook /etc/ansible/playbook.yml --connection=local

EXPOSE 80
```

Instead of installing apt and pip packages using Ansible, we'll install them using `RUN` commands in the Dockerfile. This allows those commands to be cached by Docker. Generally, more complicated package installation and configuration is easier and more maintainable inside Ansible, but in the case of package installation, having Docker cache the steps so future `docker build` commands take seconds instead of minutes is worth the verbosity of the Dockerfile.

At the end of the Dockerfile, we run a playbook (which should be located in the same directory as the Dockerfile) and expose port 80 so the app can be accessed via HTTP by the outside world. Next we'll create the app deployment playbook.

W> Purists might cringe at the sight of an Ansible playbook inside a Dockerfile, and for good reason! Commands like the `ansible-playbook` command cover up configuration that might normally be done (and cached) within Docker. Additionally, using the `geerlingguy/docker-ubuntu1804-ansible` base image (which includes Ansible) requires an initial download that's 50+ MB larger than a comparable Debian or Ubuntu image without Ansible. However, for brevity and ease of maintenance, we're using Ansible to manage all the app configuration inside the container (otherwise we'd need to run a bunch of verbose and incomprehensible shell commands to replace Ansible's `template` functionality).
W> 
W> Using a tool like [ansible-bender](https://github.com/ansible-community/ansible-bender), or building containers with Ansible _directly_ (using the `docker` connection plugin, mentioned later in this chapter), are ways you can still automate container image builds without running Ansible inside the image.

In order for the Flask app to function properly, we need to get the `host_ip_address`, then replace the variable in the `index.py.j2` template. Create the Flask deployment playbook at `docker/provisioning/www/playbook.yml`:

{lang="yaml"}
```
---
- hosts: localhost
  become: true

  tasks:
    - name: Get host IP address.
      shell: "/sbin/ip route | awk '/default/ { print $3 }'"
      register: host_ip
      changed_when: false

    - name: Set host_ip_address variable.
      set_fact:
        host_ip_address: "{{ host_ip.stdout }}"

    - name: Copy Flask app into place.
      template:
        src: /etc/ansible/index.py.j2
        dest: /opt/www/index.py
        mode: 0755

    - name: Copy Flask templates into place.
      copy:
        src: /etc/ansible/templates
        dest: /opt/www
        mode: 0755
```

The shell command that registers the `host_ip` is an easy way to retrieve the IP while still letting Docker do its own virtual network management.

The last two tasks copy the flask app and templates directory into place.

The `docker/provisioning/www` directory should now contain the following:

{lang="text",linenos=off}
```
www/
  templates/
    index.html
  Dockerfile
  index.py.j2
  playbook.yml
```

### MySQL container

We've configured MySQL a few times throughout this book, so little time will be spent discussing how MySQL is set up. We'll instead dive into how MySQL works inside a Docker container, with a persistent data volume from the previously-configured `data` container.

For MySQL, there is already a very well-maintained and flexible community MySQL Docker image we can rely on. To use it, we'll wrap it in our own Dockerfile (in case we want to make further customizations in the future).

{lang="docker"}
```
# A simple MySQL container.
FROM mysql:5.7
MAINTAINER Jeff Geerling <geerlingguy@mac.com>

EXPOSE 3306
```

This Dockerfile tells Docker to pull from the mysql image on Docker Hub, and then expose port 3306.

The `docker/provisioning/db` directory should now contain the following:

{lang="text",linenos=off}
```
db/
  Dockerfile
```

### Ship it!

Now that everything's in place, you should be able to cd into the main `docker` directory, and run `vagrant up`. After 10 minutes or so, Vagrant should show Ansible provisioning was successful, and if you visit `http://192.168.56.39/` in your browser, you should see something like the following:

{width=80%}
![Docker orchestration success!](images/15-docker-success.png)

If you see "MySQL Connection: PASS", congratulations, everything worked! If it shows 'FAIL', you might need to give the MySQL a little extra time to finish its initialization, since it has to build it's environment on first launch. If the page doesn't show up at all, you might want to compare your code with the [Docker Flask example](https://github.com/geerlingguy/ansible-for-devops/tree/master/docker-flask) on GitHub.

The entire [Docker Flask example](https://github.com/geerlingguy/ansible-for-devops/tree/master/docker) is available on GitHub, if you'd like to clone it and try it locally.

## Building containers with Ansible from the outside

In the previous example, an Ansible playbook was run _inside_ a Docker container to build the Flask application image. While this approach works and is maintainable, it also makes for a lot of cruft. One major advantage of container-based app deployment is a nice tidy container image per service.

To use Ansible inside a container requires a lot of dependencies---Python, Ansible's dependencies, and Ansible itself.

One solution to this problem is to use [`ansible-bender`](https://github.com/ansible-community/ansible-bender). One of the key features of `ansible-bender` is a container image build system which applies Ansible tasks to a Docker image. So instead of Ansible running inside the container being built, you use Ansible to build the container.

I> Earlier in Ansible's history, there was a project called [Ansible Container], which used a sidecar container running Ansible to apply Ansible roles to a container image, and stored each role as one container image layer. That project never achieved critical mass and was left in a state of disrepair after around 2018.

### Build a Hubot Slack bot container with `ansible_connection: docker`

Most examples in this book use the default `ansible_connection` plugin, `ssh`, which connects to servers using SSH. A few examples also use the `local` plugin, which runs commands locally without SSH.

There are actually a few dozen connection plugins that ship with Ansible, including `kubectl` for interacting with Kubernetes pods, `saltstack` for piggybacking salt minions, `winrm` for connecting over Microsoft's WinRM, and `docker`, which runs tasks in Docker containers.

This last connection plugin is helpful if you want to build Docker container images using Ansible without the overhead of installing Ansible inside the container.

To learn how the `docker` connection plugin works, we'll build a Hubot Slack bot.

#### Hubot and Slack

To give a little background, [Hubot](https://hubot.github.com) is an open-source chat bot from GitHub, written in CoffeeScript, which can be connected to many different chat systems. [Slack](https://slack.com) is an popular chat platform used by many businesses to communicate. Many teams benefit from a bot like Hubot, as they can store data in Hubot for quick retrieval, or even connect Hubot to other services (like CI tools) and kick off deployments, check infrastructure health, and do other helpful things.

#### Building a Docker container with Ansible

The first step in setting up our bot project is to create a new directory (e.g. `docker-hubot`) and an Ansible playbook, we'll call it `main.yml`.

You'll have to have Docker installed and running on the computer where you'll run this playbook, and the first few setup steps will use `connection: local` to get the container build started:

{lang="text"}
```
---
- hosts: localhost
  connection: local
  gather_facts: no

  vars:
    base_image: node:14
    container_name: hubot_slack
    image_namespace: a4d
    image_name: hubot-slack
```

There are also a few variables defined which we'll use later in the playbook to define things like the Docker base image to be used, the name for the container we're building, and the namespace and name for the final generated Docker image. We don't need to `gather_facts` since we aren't going to do much on the local connection.

{lang="text",starting-line-number=12}
```
  pre_tasks:
    - name: Make the latest version of the base image available locally.
      docker_image:
        name: '{{ base_image }}'
        source: pull
        force_source: true

    - name: Create the Docker container.
      docker_container:
        image: '{{ base_image }}'
        name: '{{ container_name }}'
        command: sleep infinity

    - name: Add the newly created container to the inventory.
      add_host:
        hostname: '{{ container_name }}'
        ansible_connection: docker
```

In a `pre_tasks` area, we'll set up the Docker container so we can get Hubot on it:

  1. The `docker_image` task: Pull the `base_image` (Ansible's equivalent of `docker pull`), and make sure the latest version is always present when the playbook runs.
  2. The `docker_container` task: Create a Docker container (Ansible's equivalent of `docker run`) from the `base_image`.
  3. The `add_host` task: Add the just-created container to the Ansible inventory.

Now that we have a container running and in the inventory, we can build inside of it, using the `docker` connection plugin. Following the best practices we established earlier in the book, we'll put all the reusable logic inside an Ansible role, which we'll create in a moment. For now, we can call the role about to be created in the playbook's `roles` section:

{lang="text",starting-line-number=30}
```
  roles:
    - name: hubot-slack
      delegate_to: '{{ container_name }}'
```

Note the `delegate_to`. Any task, playbook, or role we want Ansible to run inside the Docker container needs to be delegated to the container.

Before building the `hubot-slack` role, let's finish off the container image build process and the rest of the main playbook:

{lang="text",starting-line-number=34}
```
  post_tasks:
    - name: Clean up the container.
      shell: >
        apt-get remove --purge -y python &&
        rm -rf /var/lib/apt/lists/*
      delegate_to: '{{ container_name }}'

    - name: Commit the container.
      command: >
        docker commit
        -c 'USER hubot'
        -c 'WORKDIR "/home/hubot"'
        -c 'CMD ["bin/hubot", "--adapter", "slack"]'
        -c 'VOLUME ["/home/hubot/scripts"]'
        {{ container_name }} {{ image_namespace }}/{{ image_name }}:latest

    - name: Remove the container.
      docker_container:
        name: '{{ container_name }}'
        state: absent
```

The post-tasks clean up unnecessary cruft inside the container (trimming down the size of the committed image), commit the Docker container to an image (tagged `a4d/hubot-slack:latest`), and remove the running container.

When building from a `Dockerfile`, you can set things like the `USER` (the user used to run the `CMD` or `ENTRYPOINT` in the container) and `CMD` (the defaults for an executing container) directly. In our case, since we're not building from a `Dockerfile`, we set these options using `docker commit`'s `-c` or `--change` option.

Now that we have the main scaffolding in place for building a Docker container, committing an image from that container, and tearing down the container, it's time to add the 'meat' to our playbook---the role that installs Hubot and its Slack adapter.

#### Building the `hubot-slack` role

As with any role, the easiest way to scaffold the necessary files is using the `ansible-galaxy` command. Create a `hubot-slack` role in a `roles` subdirectory with:

{lang="text",linenos=off}
```
ansible-galaxy role init hubot-slack
```

You can delete some unneeded role directories, namely `files`, `handlers`, `templates`, `tests`, and `vars`. If you want, fill in the metadata fields inside `meta/main.yml` (this is only needed if you're publishing the role on Ansible Galaxy or if you need to have other roles defined as dependencies, though).

Since Hubot isn't too hard to install, we can do everything we need inside `tasks/main.yml`. The first thing we need to do is ensure all the required dependencies for generating our bot are present:

{lang="text"}
```
---
- name: Install dependencies.
  package:
    name: sudo
    state: present

- name: Install required Node.js packages.
  npm:
    name: "{{ item }}"
    state: present
    global: yes
  with_items:
    - yo
    - generator-hubot
```

Because we want to be able to run certain commands as a `hubot` user later, we'll need `sudo` present so Ansible can `become` the `hubot` user. Then we'll install some require dependencies---`yo` and `generator-hubot`, which are used to build the bot. Node.js is already present inside the container, since we chose to build the container based off the `node:14` base image.

{lang="text",starting-line-number=16}
```
- name: Ensure hubot user exists.
  user:
    name: hubot
    create_home: yes
    home: "{{ hubot_home }}"
```

It's best to run Hubot inside an isolated directory, using a dedicated user account, so we set up a `hubot` user account with its own home directory. To make the Hubot role easier to adapt, a variable is used for the `hubot` user's home directory. We'll define that later in `defaults/main.yml`.

{lang="text",starting-line-number=22}
```
- name: Generate hubot.
  command: >
    yo hubot
    --owner="{{ hubot_owner }}"
    --name="{{ hubot_name }}"
    --description="{{ hubot_description }}"
    --adapter=slack
    --defaults
    chdir={{ hubot_home }}
  become: yes
  become_user: hubot
```

The `yo hubot` command scaffolds all the code necessary to run Hubot, and all the options passed in tell the generator to run non-interactively. We will define the default role `hubot_` vars in this command later in `defaults/main.yml`.

{lang="text",starting-line-number=34}
```
- name: Remove certain scripts from external-scripts.json.
  lineinfile:
    path: "{{ hubot_home }}/external-scripts.json"
    regexp: "{{ item }}"
    state: absent
  with_items:
    - 'redis-brain'
    - 'heroku'
  become: yes
  become_user: hubot

- name: Remove the hubot-scripts.json file.
  file:
    path: "{{ hubot_home }}/hubot-scripts.json"
    state: absent
```

There are a couple cleanup tasks which make sure Hubot runs properly in this isolated container. In the `lineinfile` task, the persistent Redis connection plugin and Heroku support are removed, since they are not needed. Also, the unused `hubot-scripts.json` file is removed to prevent errors during Hubot startup.

The final step in creating the `hubot-slack` role is to add default values for the variables we're using in the role, so put the following inside `defaults/main.yml`:

{lang="text"}
```
---
hubot_home: /home/hubot
hubot_owner: Ansible for DevOps
hubot_name: a4dbot
hubot_description: Ansible for DevOps test bot.
```

#### Building and running the Hubot Slack bot container

You should now have a directory containing the `main.yml` Ansible playbook and a `hubot-slack` role inside the `roles` directory. To build the container image, make sure Docker is running, and run:

{lang="text",linenos=off}
```
ansible-playbook main.yml
```

Once the playbook completes, run `docker images` to verify the `a4d/hubot-slack` image was created:

{lang="text",linenos=off}
```
$ docker images
REPOSITORY          TAG                 IMAGE ID            SIZE
a4d/hubot-slack     latest              142db74437da        804MB
node                8                   55791187f71c        673MB
```

Before you can run an instance of the new container image and have your bot in your Slack channels, you have to get an API token from Slack. Follow the instructions in Slack's guide, [Slack Developer Kit for Hubot](https://slackapi.github.io/hubot-slack/), and get an API token.

Then run the following command to run an instance of Hubot attached to your Slack channel (replace `TOKEN` with your bot's Slack API token):

{lang="text",linenos=off}
```
docker run -d --name hubot -e HUBOT_SLACK_TOKEN=TOKEN a4d/hubot-slack
```

The container should start, and you should see a new active member in your Slack team! In Slack, you can invite the bot to channels, converse directly, etc. (send a message with `help` to the bot to get all available commands).

If something went wrong, use `docker logs hubot` to find out what happened.

Once you're finished playing around with Hubot, you can kill and remove the container with `docker rm -f hubot`.

### Summary

You can use Ansible to build containers many different ways, depending on how you want to architect your container build pipeline. Using Ansible with the `docker` connection plugin allows you to treat a Docker container much like any other server in your fleet.

Some parts of an Ansible-based container build pipeline require a little more verbosity, but in the end, you can do things like use the exact same Ansible roles for VMs and bare metal servers as you do a Docker container, making your overall infrastructure maintenance easier. Instead of maintaining legacy servers using Ansible playbooks, and Docker containers using Dockerfiles, you can do everything with Ansible!

The entire [Docker Hubot Slack bot example](https://github.com/geerlingguy/ansible-for-devops/tree/master/docker-hubot) is available on GitHub, if you'd like to clone it and try it locally.

## Summary

The examples shown here barely scratch the surface of what makes Docker (and container-based application deployment in general) a fascinating and useful application deployment tool. Docker and other container-based tools are still in their infancy, so there are dozens of ways manage the building, running, and linking of containers. Ansible is a solid contender for managing your entire container-based application lifecycle (_and_ the infrastructure on which it runs).

{lang="text",linenos=off}
```
 _________________________________________
/ Any sufficiently advanced technology is \
| indistinguishable from magic.           |
\ (Arthur C. Clarke)                      /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
