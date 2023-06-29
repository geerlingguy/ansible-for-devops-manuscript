# Preface

Growing up, I had access to a world that not many kids ever get to enter. At the local radio stations where my dad was chief engineer, I was fortunate to see networks and IT infrastructure up close: Novell servers and old Mac and Windows workstations in the '90s; Microsoft and Linux-based servers; and everything in between. Best of all, he brought home decommissioned servers and copies of Linux burned to CD.

I began working with Linux and small-scale infrastructures before I started high school, and my passion for infrastructure grew as I built a Cat5 wired network and a small rack of networking equipment for a local grade school. When I started developing full-time, what was once a hobby became a necessary part of my job, so I invested more time in managing infrastructure efficiently. Over the past ten years, I've gone from manually booting and configuring physical and virtual servers; to using relatively complex shell scripts to provision and configure servers; to using configuration management tools to manage thousands of cloud servers.

When I began converting my infrastructure to code, some of the best tools for testing, provisioning, and managing my servers were still in their infancy, but they have since matured into fully-featured, robust tools that I use every day. Vagrant is an excellent tool for managing local virtual machines to mimic real-world infrastructure locally (or in the cloud), and Ansible --- the subject of this book --- is an excellent tool for provisioning servers, managing their configuration, and deploying applications, even on my local workstation!

These tools are still improving, and I'm excited for what the future holds. The time I invest in learning new infrastructure tools well will be helpful for years to come.

In these pages, I'll share with you all I've learned about Ansible: my favorite tool for server provisioning, configuration management, and application deployment. I hope you enjoy reading this book as much as I did writing it!

--- Jeff Geerling, 2015

## Second Edition

I've published 23 major revisions to the book since the original 1.0 release in 2015. After major rewrites (and three new chapters) in 2019 and 2020 to reflect Ansible's changing architecture, I decided to publish the new content as a '2nd edition'.

I will continue to publish revisions in the future, to keep this book relevant for as long as possible! Please visit the book's website, at www.ansiblefordevops.com, for the latest updates, or to subscribe to be notified of Ansible and book news!

--- Jeff Geerling, 2020

## Who is this book for?

Many of the developers and sysadmins I work with are at least moderately comfortable administering a Linux server via SSH, and manage between 1-100 servers, whether bare metal, virtualized, or using containers.

Some of these people have a little experience with configuration management tools (usually with Puppet or Chef), and maybe a little experience with deployments and continuous integration using tools like Jenkins, Capistrano, or Fabric. I am writing this book for these friends who, I think, are representative of most people who have heard of and/or are beginning to use Ansible.

If you are interested in both development and operations, and have at least a passing familiarity with managing a server via the command line, this book should provide you with an intermediate- to expert-level understanding of Ansible and how you can use it to manage your infrastructure.

## Typographic conventions

Ansible uses a simple syntax (YAML) and simple command-line tools (using common POSIX conventions) for all its powerful abilities. Code samples and commands will be highlighted throughout the book either inline (for example: `ansible [command]`), or in a code block (with or without line numbers) like:

{lang="text"}
    ---
    # This is the beginning of a YAML file.

Some lines of YAML and other code examples require more than 70 characters per line, resulting in the code wrapping to a new line. Wrapping code is indicated by a `\` at the end of the line of code. For example:

{lang="text"}
    # The line of code wraps due to the extremely long URL.
    wget http://www.example.com/really/really/really/long/path/in/the/url/causes/the/line/to/wrap

When using the code, don't copy the `\` character, and make sure you don't use a newline between the first line with the trailing `\` and the next line.

Links to pertinent resources and websites are added inline, like the following link to [Ansible](https://www.ansible.com/), and can be viewed directly by clicking on them in eBook formats, or by following the URL in the footnotes.

Sometimes, asides are added to highlight further information about a specific topic:

I> Informational asides will provide extra information.

W> Warning asides will warn about common pitfalls and how to avoid them.

T> Tip asides will give tips for deepening your understanding or optimizing your use of Ansible.

When displaying commands run in a terminal session, if the commands are run under your normal/non-root user account, the commands will be prefixed by the dollar sign (`$`). If the commands are run as the root user, they will be prefixed with the pound sign (`#`).

## Please help improve this book!

New revisions of this book are published on a regular basis (see current book publication stats below). If you think a particular section needs improvement or find something missing, please post an issue in the [Ansible for DevOps issue queue](https://github.com/geerlingguy/ansible-for-devops/issues) (on GitHub) or contact me via Twitter ([@geerlingguy](https://twitter.com/geerlingguy)).

All known issues with Ansible for DevOps will be aggregated on the book's online [Errata](https://www.ansiblefordevops.com/errata) page.

### Current Published Book Version Information

  - **Current book version**: 2.2
  - **Current Ansible version as of last publication**: 8.0.0 (core 2.15.0)
  - **Current Date as of last publication**: June 17, 2023

## About the Author

Jeff Geerling is a developer who has worked in programming and reliability engineering for companies with anywhere between one to thousands of servers. He also manages many virtual servers for services offered by Midwestern Mac, LLC and has been using Ansible to manage infrastructure since early 2013.
