# Notes

## Publishing process

See README file inside the `ansible-for-devops publicity/Published Editions` directory.

## Editing notes:

  - Spellcheck.
  - Search for "that" in text.
  - Search for `...` in code examples and make it consistent.
  - Ensure cowsay is in every chapter summary.
  - Look through all code samples and fix line-wrapped lines.
  - Search for "—" (em-dash) in entire book and replace with `---`.
  - Search for "its" and "it's" and ensure proper grammatical usage.
  - Remove parentheses that are meaningless.
  - Search for 'ansible' (lower) and make sure non-CLI usage is capitalized.
  - Search for 'simple' and 'simply', since I overuse these words.
  - Search for ' can' to find uses where it's removal makes sentences stronger.
  - Search for proper names (companies, software, etc.) and make sure they're capitalized.
  - Search for ' a the' and fix those instances.
  - Search for "PLAY RECAP" and make sure code blocks are 74 lines (70 max without indent).

## Thoughts on writing

  - [I self-published a learn-to-code book and made nearly $5k in pre-orders](https://news.ycombinator.com/item?id=9847965)
  - [My Book Marketing Process](http://www.mooreds.com/wordpress/archives/1594)
  - [Zero to 95,688: How I wrote Game Programming Patterns](http://journal.stuffwithstuff.com/2014/04/22/zero-to-95688-how-i-wrote-game-programming-patterns/)
  - [The Last Starving Author Has Died](http://www.luckyisgood.com/starving-authors-begone/)

## Improvements/new chapter ideas

  - VPN/Bastion/Jump host usage with Ansible (SSH)
  - High Performance / Scalable Ansible:
    - Profiling roles / tasks with callback plugins (see Sam Doran's blog post)
    - https://www.jeffgeerling.com/blog/2017/slow-ansible-playbook-check-ansiblecfg
    - `synchronize` vs `copy`
  - Networking (routers? other stuff?)
  - Windows and Ansible (maybe?)
  - Security and Secret management
    - SSH private key management and security
    - Sudo auth via SSH keys (http://blather.michaelwlucas.com/archives/1106)
  - Playbooks, Roles, and Variables - organization for large teams and large projects
