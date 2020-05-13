# Introduction

## In the beginning, there were sysadmins

Since the beginning of networked computing, deploying and managing servers reliably and efficiently has been a challenge. Historically, system administrators were walled off from the developers and users who interact with the systems they administer, and they managed servers by hand, installing software, changing configurations, and administering services on individual servers.

As data centers grew, and hosted applications became more complex, administrators realized they couldn't scale their manual systems management as fast as the applications they were enabling. That's why server provisioning and configuration management tools came to flourish.

Server virtualization brought large-scale infrastructure management to the fore, and the number of servers managed by one admin (or by a small team of admins), has grown by an order of magnitude. Instead of deploying, patching, and destroying every server by hand, admins now are expected to bring up new servers, either automatically or with minimal intervention. Large-scale IT deployments now may involve hundreds or thousands of servers; in many of the largest environments, server provisioning, configuration, and decommissioning are fully automated.

## Modern infrastructure management

As the systems that run applications become an ever more complex and integral part of the software they run, application developers themselves have begun to integrate their work more fully with operations personnel. In many companies, development and operations work is integrated. Indeed, this integration is a requirement for modern test-driven application design.

As a software developer by trade, and a sysadmin by necessity, I have seen the power in uniting development and operations---more commonly referred to now as DevOps or Site Reliability Engineering. When developers begin to think of infrastructure as *part of their application,* stability and performance become normative. When sysadmins (most of whom have intermediate to advanced knowledge of the applications and languages being used on servers they manage) work tightly with developers, development velocity is improved, and more time is spent doing 'fun' activities like performance tuning, experimentation, and getting things done, and less time putting out fires.

W> *DevOps* is a loaded word; some people argue using the word to identify both the *movement* of development and operations working more closely to automate infrastructure-related processes, and the *personnel* who skew slightly more towards the system administration side of the equation, dilutes the word's meaning. I think the word has come to be a rallying cry for the employees who are dragging their startups, small businesses, and enterprises into a new era of infrastructure growth and stability. I'm not too concerned that the term has become more of a catch-all for modern infrastructure management. My advice: spend less time arguing over the definition of the word, and more time making it mean something *to you*.

## Ansible and Red Hat

Ansible was released in 2012 by Michael DeHaan ([@laserllama](https://twitter.com/laserllama) on Twitter), a developer who has been working with configuration management and infrastructure orchestration in one form or another for many years. Through his work with Puppet Labs and Red Hat (where he worked on [Cobbler](http://cobbler.github.io/), a configuration management tool, Func, a tool for communicating commands to remote servers, and [some other projects](https://www.ansible.com/blog/2013/12/08/the-origins-of-ansible)), he experienced the trials and tribulations of many different organizations and individual sysadmins on their quest to simplify and automate their infrastructure management operations.

Additionally, Michael found [many shops were using separate tools](http://highscalability.com/blog/2012/4/18/ansible-a-simple-model-driven-configuration-management-and-c.html) for configuration management (Puppet, Chef, cfengine), server deployment (Capistrano, Fabric), and ad-hoc task execution (Func, plain SSH), and wanted to see if there was a better way. Ansible wraps up all three of these features into one tool, and does it in a way that's actually *simpler* and more consistent than any of the other task-specific tools!

Ansible aims to be:

  1. **Clear** - Ansible uses a simple syntax (YAML) and is easy for anyone (developers, sysadmins, managers) to understand. APIs are simple and sensible.
  2. **Fast** - Fast to learn, fast to set up---especially considering you don't need to install extra agents or daemons on all your servers!
  3. **Complete** - Ansible does three things in one, and does them very well. Ansible's 'batteries included' approach means you have everything you need in one complete package.
  4. **Efficient** - No extra software on your servers means more resources for your applications. Also, since Ansible modules work via JSON, Ansible is extensible with modules written in a programming language you already know.
  5. **Secure** - Ansible uses SSH, and requires no extra open ports or potentially-vulnerable daemons on your servers.

Ansible also has a lighter side that gives the project a little personality. As an example, Ansible's major releases are named after Led Zeppelin songs (e.g. 2.0 was named after 1973's "Over the Hills and Far Away", 1.x releases were named after Van Halen songs). Additionally, Ansible uses `cowsay`, if installed, to wrap output in an ASCII cow's speech bubble (this behavior can be disabled in Ansible's configuration).

[Ansible, Inc.](https://www.ansible.com/) was founded by Saïd Ziouani ([@SaidZiouani](https://twitter.com/SaidZiouani) on Twitter), Michael DeHaan, and Tim Gerla, and acquired by Red Hat in 2015. The Ansible team oversees core Ansible development and provides services (such as [Ansible Consulting](https://www.ansible.com/products/consulting)) and extra tooling (such as [Ansible Tower](https://www.ansible.com/tower)) to organizations using Ansible. Hundreds of individual developers have contributed patches to Ansible, and Ansible is the most starred infrastructure management tool on GitHub (with over 33,000 stars as of this writing).

In October 2015, Red Hat acquired Ansible, Inc., and has proven itself to be a good steward and promoter of Ansible. I see no indication of this changing in the future.

## Ansible Examples

There are many Ansible examples (playbooks, roles, infrastructure, configuration, etc.) throughout this book. Most of the examples are in the [Ansible for DevOps GitHub repository](https://github.com/geerlingguy/ansible-for-devops), so you can browse the code in its final state while you're reading the book. Some of the line numbering may not match the book *exactly* (especially if you're reading an older version of the book!), but I will try my best to keep everything synchronized over time.

## Other resources

We'll explore all aspects of using Ansible to provision and manage your infrastructure in this book, but there's no substitute for the wealth of documentation and community interaction that make Ansible great. Check out the links below to find out more about Ansible and discover the community:

  - [Ansible Documentation](https://docs.ansible.com/ansible/) - Covers all Ansible options in depth. There are few open source projects with documentation as clear and thorough.
  - [Ansible Glossary](https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html) - If there's ever a term in this book you don't seem to fully understand, check the glossary.
  - [The Bullhorn](https://us19.campaign-archive.com/home/?u=56d874e027110e35dea0e03c1&id=d6635f5420) - Ansible's official newsletter.
  - [Ansible Mailing List](https://groups.google.com/forum/#!forum/ansible-project) - Discuss Ansible and submit questions with Ansible's community via this Google group.
  - [Ansible on GitHub](https://github.com/ansible/ansible) - The official Ansible code repository, where the magic happens.
  - [Ansible Example Playbooks on GitHub](https://github.com/ansible/ansible-examples) - Many examples for common server configurations.
  - [Getting Started with Ansible](https://www.ansible.com/resources/get-started) - A simple guide to Ansible's community and resources.
  - [Ansible Blog](https://www.ansible.com/blog)

I'd like to especially highlight Ansible's documentation (the first resource listed above); one of Ansible's greatest strengths is its well-written and extremely relevant documentation, containing a large number of relevant examples and continuously-updated guides. Very few projects---open source or not---have documentation as thorough, yet easy-to-read. This book is meant as a supplement to, not a replacement for, Ansible's documentation!
